#!/usr/bin/env bash
set -euo pipefail

services=(open-webui qdrant redis flowise node-red)
tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

normalize_mem() {
  local raw="${1:-}"
  raw="${raw%%/*}"
  raw="${raw// /}"
  raw="${raw/MiB/mb}"
  raw="${raw/GiB/gb}"
  raw="${raw/KiB/kb}"
  raw="${raw/B/b}"
  printf '%s' "${raw}"
}

cpu_as_int() {
  local raw="${1:-0%}"
  raw="${raw%%%}"
  if [[ "${raw}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    awk -v v="${raw}" 'BEGIN { printf "%d%%", (v + 0.5) }'
  else
    printf '0%%'
  fi
}

containers_file="${tmp_dir}/containers.tsv"
stats_file="${tmp_dir}/stats.tsv"
loaded_file="${tmp_dir}/loaded.txt"

docker ps -a --format '{{.Names}}\t{{.Label "com.docker.compose.service"}}\t{{.Status}}' \
  > "${containers_file}" 2>/dev/null || true
docker stats --no-stream --format '{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}' \
  > "${stats_file}" 2>/dev/null || true

get_container_for_service() {
  local svc="$1"
  awk -F '\t' -v s="${svc}" '$2==s {print $1; exit}' "${containers_file}"
}

get_cpu_for_container() {
  local cname="$1"
  local cpu
  cpu="$(awk -F '\t' -v c="${cname}" '$1==c {print $2; exit}' "${stats_file}")"
  [[ -n "${cpu}" ]] && cpu_as_int "${cpu}" || true
}

get_mem_for_container() {
  local cname="$1"
  local mem
  mem="$(awk -F '\t' -v c="${cname}" '$1==c {print $3; exit}' "${stats_file}")"
  [[ -n "${mem}" ]] && normalize_mem "${mem}" || true
}

printf 'STACK HEALTH\n'
printf '%s\n' '--------------------------------'
for svc in "${services[@]}"; do
  cname="$(get_container_for_service "${svc}")"
  if [[ -z "${cname}" ]]; then
    printf '%-14s %-10s\n' "${svc}" "OFFLINE"
    continue
  fi

  state="OFFLINE"
  if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "${cname}"; then
    state="ONLINE"
  fi

  cpu="$(get_cpu_for_container "${cname}")"
  mem="$(get_mem_for_container "${cname}")"

  details=""
  case "${svc}" in
    open-webui|flowise|node-red)
      [[ -n "${cpu}" ]] && details="cpu: ${cpu}"
      ;;
    qdrant|redis)
      [[ -n "${mem}" ]] && details="mem: ${mem}"
      ;;
  esac

  if [[ -z "${details}" ]]; then
    if [[ -n "${cpu}" ]]; then
      details="cpu: ${cpu}"
    elif [[ -n "${mem}" ]]; then
      details="mem: ${mem}"
    fi
  fi

  printf '%-14s %-10s' "${svc}" "${state}"
  [[ -n "${details}" ]] && printf ' %s' "${details}"
  printf '\n'
done

printf '\nMODELS\n'
printf '%s\n' '--------------------------------'
if ! command -v ollama >/dev/null 2>&1; then
  echo 'ollama         UNAVAILABLE'
  exit 0
fi

while IFS=$'\t' read -r mname mstatus; do
  [[ -n "${mname}" ]] || continue
  echo "${mname}" >> "${loaded_file}"
  printf '%-14s %s\n' "${mname}" "${mstatus}"
done < <(ollama ps 2>/dev/null | awk 'NR>1 && NF>0 {print $1"\tloaded"}' || true)

idle_printed=0
idle_total=0
idle_max=8
while IFS= read -r mname; do
  [[ -n "${mname}" ]] || continue
  if ! grep -Fxq "${mname}" "${loaded_file}" 2>/dev/null; then
    idle_total=$((idle_total + 1))
    if [[ "${idle_printed}" -lt "${idle_max}" ]]; then
      printf '%-14s %s\n' "${mname}" "idle"
      idle_printed=$((idle_printed + 1))
    fi
  fi
done < <(ollama list 2>/dev/null | awk 'NR>1 && NF>0 {print $1}' || true)

if [[ "${idle_total}" -gt "${idle_printed}" ]]; then
  echo "... (+$((idle_total - idle_printed)) more idle)"
fi

if [[ ! -s "${loaded_file}" && "${idle_total}" -eq 0 ]]; then
  echo 'none           none'
fi
