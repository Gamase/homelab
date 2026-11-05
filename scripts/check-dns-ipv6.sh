#!/bin/bash
# Revisa que AdGuard responda por IPv6 y avisa a Kuma.
# Si Totalplay cambia el prefijo IPv6, esta dirección deja de responder
# y Kuma avisa: hay que actualizar la IPv6 de AdGuard en el router.
ADGUARD_V6="2806:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx"
. "$HOME/.config/homelab/push.env"; PUSH_URL="$PUSH_DNS_IPV6"

if dig @"$ADGUARD_V6" google.com +short +time=3 +tries=2 | grep -q .; then
  curl -fsS --max-time 10 "$PUSH_URL" > /dev/null
fi
