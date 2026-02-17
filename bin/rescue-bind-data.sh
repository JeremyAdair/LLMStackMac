#!/usr/bin/env bash
set -Eeuo pipefail

# Recover data from older container filesystems into new host bind mounts.
# Safe by default: no deletes, no overwrite unless explicitly approved.

PROJECT="${PROJECT:-llm-stack}"
INCLUDE_SERVICES="${INCLUDE_SERVICES:-}"
DRY_RUN="${DRY_RUN:-0}"
NONINTERACTIVE="${NONINTERACTIVE:-0}"
LOG_FILE="${LOG_FILE:-./rescue-bind-data-$(date +%Y%m%d-%H%M%S).log}"
TMP_ROOT="${TMP_ROOT:-$(mktemp -d)}"

cleanup() { rm -rf "$TMP_ROOT" >/dev/null 2>&1 || true; }
trap cleanup EXIT

log() {
  printf '%s %s\n' "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing command '$1'"; exit 1; }
}

normalize_host_path() {
  local p="$1"
  if [[ "$p" =~ ^[A-Za-z]:[\\/].* ]]; then
    if command -v wslpath >/dev/null 2>&1; then
      wslpath -u "$p"
      return
    elif command -v cygpath >/dev/null 2>&1; then
      cygpath -u "$p"
      return
    fi
  fi
  echo "$p"
}

service_allowed() {
  local svc="$1"
  if [[ -z "$INCLUDE_SERVICES" ]]; then
    return 0
  fi
  IFS=',' read -ra arr <<< "$INCLUDE_SERVICES"
  for x in "${arr[@]}"; do
    [[ "$svc" == "$x" ]] && return 0
  done
  return 1
}

get_service_name() {
  docker inspect --format '{{ index .Config.Labels "com.docker.compose.service" }}' "$1" 2>/dev/null || true
}

get_mounts() {
  docker inspect --format '{{range .Mounts}}{{printf "%s|%s|%s\n" .Type .Destination .Source}}{{end}}' "$1" 2>/dev/null || true
}

has_any_mount_at_dest() {
  local cid="$1" dest="$2"
  local t d s
  while IFS='|' read -r t d s; do
    [[ "$d" == "$dest" ]] && return 0
  done < <(get_mounts "$cid")
  return 1
}

find_donor_container() {
  local service="$1" current_id="$2" dest="$3"
  local cid svc
  for cid in "${ALL_IDS[@]}"; do
    [[ "$cid" == "$current_id" ]] && continue
    svc="$(get_service_name "$cid")"
    [[ "$svc" != "$service" ]] && continue
    if ! has_any_mount_at_dest "$cid" "$dest"; then
      echo "$cid"
      return 0
    fi
  done
  return 1
}

count_conflicts() {
  local src="$1" dst="$2"
  local c=0 rel f
  while IFS= read -r -d '' f; do
    rel="${f#$src/}"
    [[ -e "$dst/$rel" ]] && ((c++))
  done < <(find "$src" -type f -print0)
  echo "$c"
}

merge_copy() {
  local src="$1" dst="$2" overwrite="$3"
  mkdir -p "$dst"
  if [[ "$DRY_RUN" == "1" ]]; then
    log "[DRY-RUN] Would merge '$src' -> '$dst' overwrite=$overwrite"
    return 0
  fi
  if command -v rsync >/dev/null 2>&1; then
    if [[ "$overwrite" == "yes" ]]; then
      rsync -a --info=NAME,STATS "$src"/ "$dst"/ | tee -a "$LOG_FILE"
    else
      rsync -a --ignore-existing --info=NAME,STATS "$src"/ "$dst"/ | tee -a "$LOG_FILE"
    fi
  else
    if [[ "$overwrite" == "yes" ]]; then
      cp -a "$src"/. "$dst"/
    else
      cp -an "$src"/. "$dst"/
    fi
  fi
}

require_cmd docker

log "Starting rescue. project=$PROJECT dry_run=$DRY_RUN noninteractive=$NONINTERACTIVE log=$LOG_FILE"

mapfile -t ALL_IDS < <(docker ps -a --filter "label=com.docker.compose.project=$PROJECT" --format '{{.ID}}')
if [[ "${#ALL_IDS[@]}" -eq 0 ]]; then
  log "No containers found for project '$PROJECT'."
  exit 0
fi

declare -A CURRENT_BY_SERVICE
for cid in "${ALL_IDS[@]}"; do
  svc="$(get_service_name "$cid")"
  [[ -z "$svc" ]] && continue
  if [[ -z "${CURRENT_BY_SERVICE[$svc]+x}" ]]; then
    CURRENT_BY_SERVICE[$svc]="$cid"
  fi
done

for service in "${!CURRENT_BY_SERVICE[@]}"; do
  if ! service_allowed "$service"; then
    log "Skipping service '$service' (filter)"
    continue
  fi
  current_id="${CURRENT_BY_SERVICE[$service]}"
  log "---- Service: $service (current=$current_id) ----"
  found_bind=0
  while IFS='|' read -r mtype mdest msrc; do
    [[ "$mtype" != "bind" ]] && continue
    found_bind=1
    host_raw="$msrc"
    host_path="$(normalize_host_path "$host_raw")"
    container_path="$mdest"
    log "Bind: host='$host_raw' local='$host_path' container='$container_path'"

    if ! donor_id="$(find_donor_container "$service" "$current_id" "$container_path")"; then
      log "No donor found for $service:$container_path"
      continue
    fi
    log "Donor: $donor_id"

    mkdir -p "$host_path"
    stage_dir="$TMP_ROOT/${service}_$(echo "$container_path" | tr '/:' '__')"
    mkdir -p "$stage_dir"

    if [[ "$DRY_RUN" == "1" ]]; then
      log "[DRY-RUN] docker cp '$donor_id:$container_path/.' '$stage_dir/'"
      continue
    fi

    if ! docker cp "$donor_id:$container_path/." "$stage_dir/" 2>>"$LOG_FILE"; then
      log "WARN: docker cp failed for $donor_id:$container_path"
      continue
    fi

    if [[ -z "$(find "$stage_dir" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
      log "Donor path empty: $container_path"
      continue
    fi

    conflicts="$(count_conflicts "$stage_dir" "$host_path")"
    overwrite="no"
    if [[ "$conflicts" -gt 0 ]]; then
      if [[ "$NONINTERACTIVE" == "1" ]]; then
        log "Conflicts=$conflicts at '$host_path' (noninteractive -> overwrite=no)"
      else
        if read -r -p "[$service:$container_path] $conflicts conflict(s). Overwrite? [y/N] " ans; then
          if [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]; then
            overwrite="yes"
          fi
        else
          log "No input available; default overwrite=no"
        fi
      fi
    fi

    log "Merging data overwrite=$overwrite"
    merge_copy "$stage_dir" "$host_path" "$overwrite"
    log "Merge complete: $host_path"
  done < <(get_mounts "$current_id")
  [[ "$found_bind" -eq 0 ]] && log "No bind mounts on current container for service '$service'"
done

log "Rescue completed."

