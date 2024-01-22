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

setup_nm_connections() {
  local nm_conn_dir=/etc/NetworkManager/system-connections

  local _f found=0
  for _f in "${initdir}/run/NetworkManager/system-connections"/*.nmconnection; do
    mkdir -p "${initdir}/${nm_conn_dir}/"
    mv "$_f" "${initdir}/${nm_conn_dir}/"

    found=1
  done

  [ $found -eq 1 ]
}

setup_networkd_connections() {
  local sd_conn_dir=/etc/systemd/network

  local _f found=0
  for _f in "${initdir}/run/systemd/network"/*.*; do
    mkdir -p "${initdir}/${sd_conn_dir}/"
    mv "$_f" "${initdir}/${sd_conn_dir}/"

    found=1
  done

  [ $found -eq 1 ]
}

install() {
  inst_multiple -o -H "/etc/netplan/*.yaml"
  netplan generate --root-dir "${initdir}"

  renderer=$(netplan get renderer)
  case "$renderer" in
  NetworkManager)
    setup_nm_connections ;;
  networkd)
    setup_networkd_connections ;;
  esac

  if [ $? -eq 0 ]; then
    echo "rd.neednet=1" > "${initdir}/etc/cmdline.d/10-netplan-net.conf"
  fi
}
