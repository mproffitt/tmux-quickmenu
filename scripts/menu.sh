#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="${CURRENT_DIR}/menu.sh"
PWD=$(pwd)

id=$RANDOM
pstdin="${TMPDIR:-/tmp}/ltb-pstdin-$id"

cleanup() {
  rm -f ${pstdin}
  exit 0
}
trap 'cleanup' EXIT SIGINT SIGTERM SIGHUP

question() {
  mkfifo "${pstdin}"

  tmux display-popup -h 5% -w 25% -b rounded -T " $1 " -E bash -c 'trap "echo > '${pstdin}';exit 0;" EXIT SIGINT SIGTERM SIGHUP; set -f; read -erp "> " ans </dev/tty && echo "${ans}" > '${pstdin} &
}

sternscript='{
  ns="-n "; po=""; ex=""; l=0;
  for (i=1;i<=NF;i++) {
    if ($i=="-A") {
      ns=$i; l=i+1; break
    } else if ($i==".") {
      ns=""; l=i+1; break 
    } else if ($i~/.*,$/) {
      ns=ns$i
    } else {
      if ($i) {
        ns=ns$i; l=i+1; break
      }
    }
  }
  po=$l;

  for (i=l+1; i<=NF; i++) {
    ex=ex" "$i
  }

  if (ns) {
    gsub(/^[ \t]+/,"",ns);
    printf("%s ", ns);
  }

  gsub(/^[ \t]+/,"",po);
  printf("\047%s\047", po);
  if (ex) {
    gsub(/^[ \t]+/,"",ex);
    printf(" -i \047%s\047", ex);
  }
}'

tmuxcmd='tmux display-popup -h 70% -w 70% -b rounded -E'

cmds=(
  "c:lazycli"
  "d:lazydocker"
  "h:htop"
  "g:lazygit"
  "k:k9s"
  "n:nvtop"
  "s:stern"
)

show_menu() {
  tmux display-menu -T "#[align=centre fg=green] Quick commands " -x R -y P \
    "" \
    "Htop" h "run 'bash -c \"source ${SCRIPT} && run_cmd h ${PWD}\"'" \
    "k9s" k "run 'bash -c \"source ${SCRIPT} && run_cmd k ${PWD}\"'" \
    "Lazy cli" c "run 'bash -c \"source ${SCRIPT} && run_cmd c ${PWD}\"'" \
    "Lazy docker" d "run 'bash -c \"source ${SCRIPT} && run_cmd d ${PWD}\"'" \
    "Lazy git" g "run 'bash -c \"source ${SCRIPT} && run_cmd g ${PWD}\"'" \
    "Lazy Journal" j "run 'bash -c \"source ${SCRIPT} && run_cmd j ${PWD}\"'" \
    "Midnight Commander" m "run 'bash -c \"source ${SCRIPT} && run_cmd m ${PWD}\"'" \
    "NvTop" n "run 'bash -c \"source ${SCRIPT} && run_cmd n ${PWD}\"'" \
    "Stern" s "run 'bash -c \"source ${SCRIPT} && run_cmd s ${PWD}\"'" \
    "" \
    "Close menu" q ""
}

run_cmd() {
  case "$1" in
  h) $tmuxcmd bash -c 'cd '$2' && htop' ;;
  g) $tmuxcmd bash -c 'cd '$2' && lazygit' ;;
  d) $tmuxcmd bash -c 'cd '$2' && lazydocker' ;;
  j) $tmuxcmd bash -c 'cd '$2' && lazyjournal' ;;
  k) $tmuxcmd bash -c 'cd '$2' && TERM=xterm-256color k9s' ;;
  m) $tmuxcmd bash -c 'cd '$2' && mc' ;;
  n) $tmuxcmd bash -c 'cd '$2' && nvtop' ;;
  s)
    question "ns pod expression" "\-A all namespaces\n. current kube context namespace\n"
    ans=$(awk "${sternscript}" <<<$(cat ${pstdin}))
    if [ ! -z "${ans}" ]; then
      $tmuxcmd -T " stern ${ans}" bash -c "stern ${ans} -o ppextjson | jq -C | less -r"
    fi
    ;;
  *)
    question " enter command to run "
    ans=$(cat ${pstdin})
    if [ "${ans}" != "null" ]; then
      $tmuxcmd -T "${ans}" bash -c "cd $2 && lazycli '${ans}'"
    fi
    ;;
  esac
  # always exit 0 from this script for
  # tmux cmd to exit cleanly
  exit 0
}
