#!/usr/bin/env bash
set -euo pipefail
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
running_file="${tmp_dir}/running.txt"
stats_file="${tmp_dir}/stats.tsv"
loaded_file="${tmp_dir}/loaded.txt"
models_file="${tmp_dir}/models.txt"
stack_file="${tmp_dir}/stack.txt"
stack_all_file="${tmp_dir}/stack_all.txt"

docker ps -a --format '{{.Names}}\t{{.Label "com.docker.compose.service"}}\t{{.Status}}' \
  > "${containers_file}" 2>/dev/null || true
docker ps --format '{{.Names}}' > "${running_file}" 2>/dev/null || true
docker stats --no-stream --format '{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}' \
  > "${stats_file}" 2>/dev/null || true

# LLM stack container universe (all states).
awk -F '\t' '$1 ~ /^llm-/ {print $1}' "${containers_file}" | sort -u > "${stack_all_file}"

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

format_mem_mb() {
  local mb="${1:-0}"
  awk -v mb="${mb}" 'BEGIN {
    if (mb >= 1024) {
      printf "%.2fgb", mb/1024
    } else {
      printf "%.1fmb", mb
    }
  }'
}

print_3col() {
  local file="$1"
  local width="${2:-44}"
  if [[ ! -s "${file}" ]]; then
    echo 'none'
    return 0
  fi
  awk -v cols=3 -v width="${width}" '
    { items[NR]=$0 }
    END {
      n=NR
      rows=int((n + cols - 1)/cols)
      for (r=1; r<=rows; r++) {
        for (c=0; c<cols; c++) {
          idx=r + c*rows
          if (idx<=n) {
            printf "%-*s", width, items[idx]
          }
        }
        printf "\n"
      }
    }
  ' "${file}"
}

total_count="$(wc -l < "${stack_all_file}" | tr -d ' ')"
online_count="$(awk -F '\t' '$1 ~ /^llm-/ {c++} END {print c+0}' "${stats_file}")"
offline_count="$(awk -F '\t' '$1 ~ /^llm-/ && ($3 ~ /^Restarting/ || $3 ~ /^Dead/ || $3 ~ /^Exited \\([1-9][0-9]*\\)/) {c++} END {print c+0}' "${containers_file}")"
on_demand_count=$((total_count - online_count - offline_count))
if [[ "${on_demand_count}" -lt 0 ]]; then
  on_demand_count=0
fi

total_cpu="$(awk -F '\t' '
  $1 ~ /^llm-/ {
    gsub(/%/, "", $2)
    if ($2 ~ /^[0-9]+(\\.[0-9]+)?$/) cpu += $2
  }
  END { printf "%.1f%%", cpu+0 }
' "${stats_file}")"

total_mem_mb="$(awk -F '\t' '
  function to_mb(v, n) {
    gsub(/ /, "", v)
    sub(/\/.*$/, "", v)
    if (v ~ /GiB$/) { sub(/GiB$/, "", v); return v*1024 }
    if (v ~ /MiB$/) { sub(/MiB$/, "", v); return v+0 }
    if (v ~ /KiB$/) { sub(/KiB$/, "", v); return v/1024 }
    if (v ~ /GB$/)  { sub(/GB$/,  "", v); return v*1024 }
    if (v ~ /MB$/)  { sub(/MB$/,  "", v); return v+0 }
    if (v ~ /KB$/)  { sub(/KB$/,  "", v); return v/1024 }
    if (v ~ /B$/)   { sub(/B$/,   "", v); return v/(1024*1024) }
    return 0
  }
  $1 ~ /^llm-/ { mem += to_mb($3) }
  END { printf "%.3f", mem+0 }
' "${stats_file}")"
total_mem="$(format_mem_mb "${total_mem_mb}")"

printf 'STACK TOTAL\n'
printf '%s\n' '--------------------------------'
printf 'Total Containers: %s\n' "${total_count}"
printf 'Online: %s\n' "${online_count}"
printf 'On-Demand (idle): %s\n' "${on_demand_count}"
printf 'Offline (errored): %s\n' "${offline_count}"
printf 'Total CPU: %s\n' "${total_cpu}"
printf 'Total MEM: %s\n' "${total_mem}"

printf '\n'
printf 'STACK HEALTH\n'
printf '%s\n' '--------------------------------'
while IFS= read -r cname; do
  [[ -n "${cname}" ]] || continue
  cpu="$(get_cpu_for_container "${cname}")"
  mem="$(get_mem_for_container "${cname}")"
  [[ -z "${cpu}" ]] && cpu="0%"
  [[ -z "${mem}" ]] && mem="n/a"
  printf '%-22.22s %-7s cpu:%-4.4s mem:%-8.8s\n' "${cname}" "ONLINE" "${cpu}" "${mem}" >> "${stack_file}"
done < "${running_file}"

print_3col "${stack_file}" 48

printf '\nMODELS\n'
printf '%s\n' '--------------------------------'
if ! command -v ollama >/dev/null 2>&1; then
  echo 'ollama         UNAVAILABLE'
  exit 0
fi

while IFS=$'\t' read -r mname mstatus; do
  [[ -n "${mname}" ]] || continue
  echo "${mname}" >> "${loaded_file}"
  printf '%-28s %s\n' "${mname}" "${mstatus}" >> "${models_file}"
done < <(ollama ps 2>/dev/null | awk 'NR>1 && NF>0 {print $1"\tloaded"}' || true)

idle_printed=0
idle_total=0
while IFS= read -r mname; do
  [[ -n "${mname}" ]] || continue
  if ! grep -Fxq "${mname}" "${loaded_file}" 2>/dev/null; then
    idle_total=$((idle_total + 1))
    printf '%-28s %s\n' "${mname}" "idle" >> "${models_file}"
    idle_printed=$((idle_printed + 1))
  fi
done < <(ollama list 2>/dev/null | awk 'NR>1 && NF>0 {print $1}' || true)

print_3col "${models_file}" 38
