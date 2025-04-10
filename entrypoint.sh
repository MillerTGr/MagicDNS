#!/usr/bin/env bash

set -e

DNSMASQ_TMPL="/etc/dnsmasq.conf.template"
NGINX_TMPL="/etc/nginx/nginx.conf.template"

DNSMASQ_CFG="/etc/dnsmasq.conf"
NGINX_CFG="/etc/nginx/nginx.conf"

MAIN_IPV4="${MAIN_IPV4:-127.0.0.1}"
MAIN_IPV6="${MAIN_IPV6:-::1}"
DOMAINS="${DOMAINS:-}"

echo "=> Generating /etc/dnsmasq.conf from template..."
cp "$DNSMASQ_TMPL" "$DNSMASQ_CFG"

sed -i "s|{MAIN_IPV4}|${MAIN_IPV4}|g" "$DNSMASQ_CFG"
sed -i "s|{MAIN_IPV6}|${MAIN_IPV6}|g" "$DNSMASQ_CFG"

if [ -n "$DOMAINS" ]; then
  IFS=',' read -ra domains_arr <<< "$DOMAINS"
  for domain in "${domains_arr[@]}"; do
    domain_trimmed="$(echo "$domain" | xargs)"
    echo "address=/${domain_trimmed}/${MAIN_IPV4}" >> "$DNSMASQ_CFG"
    echo "address=/${domain_trimmed}/${MAIN_IPV6}" >> "$DNSMASQ_CFG"
  done
fi

echo "=> Generating /etc/nginx/nginx.conf from template..."
cp "$NGINX_TMPL" "$NGINX_CFG"

echo "=> Starting supervisord..."
exec "$@"
