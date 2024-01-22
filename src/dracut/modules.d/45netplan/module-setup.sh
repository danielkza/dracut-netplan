#!/usr/bin/bash
# shellcheck disable=SC2154

check() {
  [[ "${1}" = "-d" ]] && return 0
  command -v netplan >/dev/null || return 1

  local _f
  for _f in /etc/netplan/*.yaml; do
    return 0
  done

  echo "No files in /etc/netplan" >&2
  return 1
}

depends() {
  local renderer
  renderer=$(netplan get renderer)
  case "$renderer" in
  NetworkManager)
    echo network-manager ;;
  networkd)
    echo systemd-networkd ;;
  esac
}

install() {
  inst_multiple -o -H "/etc/netplan/*.yaml"

  local tmp_root=$(mktemp -d --tmpdir dracut-netplan.XXXX)
  mkdir -p "${tmp_root}/etc/netplan"
  cp "${initdir}/etc/netplan"/*.yaml "${tmp_root}/etc/netplan/"

  netplan --debug generate --root-dir "${tmp_root}"

  local src dst
  while read -r src; do
    if [ "$(basename "$src")" == netplan-ovs-cleanup.service ]; then
      continue
    fi

    dst=$(sed "s!^${tmp_root}/run!${initdir}/etc!" <<< "$src")
    [ "$src" != "$dst" ] || continue

    mkdir -p $(dirname "$dst")
    inst_simple -H "$src" "$dst"
  done < <(find "${tmp_root}/run" -not -type d)

  if [ $? -eq 0 ]; then
    echo "rd.neednet=1" > "${initdir}/etc/cmdline.d/10-netplan-net.conf"
  fi
}
