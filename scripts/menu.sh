#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="${CURRENT_DIR}/menu.sh"
CWD=$(pwd)

id=$RANDOM
pstdin="${TMPDIR:-/tmp}/ltb-pstdin-$id"

questioncmd=""
read -r -d '' questioncmd <<EOF
trap "echo > '${pstdin}'; exit 0;" EXIT SIGINT SIGTERM SIGHUP;
set -f; read -erp "> " ans </dev/tty && \
  echo "\${ans}" > ${pstdin}
EOF

readonly sternscript='{
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

cleanup() {
  rm -f ${pstdin}
  exit 0
}

question() {
  mkfifo "${pstdin}"

  tmux display-popup -h 5% -w 25% -b rounded -T " $1 " -E bash -c "${questioncmd}" &
}

clicmd="bash -c \"source ${SCRIPT} && run_cmd %s ${CWD}\""
getclicmd() {
  sed "s/%s/$1/" <<<"${clicmd}"
}

show_menu() {
  tmux display-menu -b rounded -T "#[align=centre fg=green] Quick commands " -x C -y P \
    "" \
    "k9s" k "run '$(getclicmd k)'" \
    "ktop" o "run '$(getclicmd o)'" \
    "stern" s "run '$(getclicmd s)'" \
    "eks node viewer" e "run '$(getclicmd e)'" \
    "" \
    "lazy git" g "run '$(getclicmd g)'" \
    "tig" t "run '$(getclicmd t)'" \
    "" \
    "lazy docker" d "run '$(getclicmd d)'" \
    "lazy journal" j "run '$(getclicmd j)'" \
    "" \
    "bandwhich || ntap" b "run '$(getclicmd b)'" \
    "mtr" m "run '$(getclicmd m)'" \
    "" \
    "htop" h "run '$(getclicmd h)'" \
    "kmon" v "run '$(getclicmd v)'" \
    "ncdu" u "run '$(getclicmd u)'" \
    "nvtop" n "run '$(getclicmd n)'" \
    "" \
    "Midnight Commander" f "run '$(getclicmd f)'" \
    "" \
    "Close menu" q ""
}

trap 'cleanup' EXIT SIGINT SIGTERM SIGHUP

run_cmd() {
  case "$1" in
  b) $tmuxcmd bash -c 'cd '$2' && bandwhich || ntap' ;;
  e) $tmuxcmd bash -c 'cd '$2' && eks-node-viewer' ;;
  h) $tmuxcmd bash -c 'cd '$2' && htop' ;;
  g) $tmuxcmd bash -c 'cd '$2' && lazygit' ;;
  d) $tmuxcmd bash -c 'cd '$2' && lazydocker' ;;
  j) $tmuxcmd bash -c 'cd '$2' && lazyjournal' ;;
  # K9s cannot work in truecolor mode cleanly so force 256color
  k) $tmuxcmd bash -c 'cd '$2' && TERM=xterm-256color k9s' ;;
  m)
    question "ip address"
    ans=$(cat "${pstdin}")
    $tmuxcmd bash -c "cd $2 && mtr ${ans}"
    ;;
  f) $tmuxcmd bash -c 'cd '$2' && mc' ;;
  n) $tmuxcmd bash -c 'cd '$2' && nvtop' ;;
  o) $tmuxcmd bash -c 'cd '$2' && TERM=xterm-256color kubectl ktop' ;;
  s)
    question "[ns,] pod expression" "\-A all namespaces\n. current kube context namespace\n"
    an=$(cat ${pstdin})
    if [ ! -z "${an}" ]; then
      ans=$(awk "${sternscript}" <<<"${an}")
      $tmuxcmd -T " stern ${ans} " bash -c "stern ${ans} -o ppextjson | jq -C | less -r"
    fi
    ;;
  t) $tmuxcmd bash -c 'cd '$2' && tig' ;;
  u) $tmuxcmd bash -c 'cd '$2' && ncdu' ;;
  v) $tmuxcmd bash -c 'cd '$2' && kmon' ;;
  *)
    question " enter command to run "
    ans=$(cat "${pstdin}")
    if [ "${ans}" != "null" ]; then
      $tmuxcmd -T "${ans}" bash -c "cd $2 && lazycli '${ans}'"
    fi
    ;;
  esac
  # always exit 0 from this script for
  # tmux cmd to exit cleanly
  exit 0
}
