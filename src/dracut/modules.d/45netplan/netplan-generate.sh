#!/bin/sh


if getargbool 0 rd.debug; then
  export G_MESSAGES_DEBUG=all
fi

/usr/lib/netplan/generate

mkdir -p /run/NetworkManager/initrd
touch /run/NetworkManager/initrd/neednet
