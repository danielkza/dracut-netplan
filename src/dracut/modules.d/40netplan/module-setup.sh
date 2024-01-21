#!/usr/bin/bash
# shellcheck disable=SC2154

check() {
  [[ "${1}" = "-d" ]] && return 0
  command -v netplan >/dev/null || return 1

  local f
  for f in /etc/netplan/*.yaml; do
    return 0
  fi

  echo "No files in /etc/netplan" >&2
  return 1
}

depends() {
  local renderer=$(netplan get renderer)
  case "$renderer" in
  NetworkManager)
    echo network-manager ;;
  networkd)
    echo systemd-networkd ;;
  esac
}

install() {
  inst "/usr/lib/netplan/generate"
  inst_multiple -o -H "/etc/netplan/*.yaml"

  inst_hook initqueue 95 "${moddir}/netplan-generate.sh"
}
