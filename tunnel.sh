#!/bin/bash

# ref:
# https://icloudnative.io/posts/linux-circumvent/#%E7%BC%96%E5%86%99%E8%B7%AF%E7%94%B1%E8%A1%A8%E5%90%AF%E5%8A%A8%E5%92%8C%E7%BB%88%E6%AD%A2%E8%84%9A%E6%9C%AC

cd `dirname $0`

if [ $# == 0 ]
then
op="show"
else
op=$1
fi
# echo "op: ${op}"

SOCKS_SERVER=127.0.0.1
SOCKS_PORT=1080
# GATEWAY_IP=$(ip route | grep default | awk '{print $3}' | head -n 1)
GATEWAY_IP=192.168.1.1
TUN_NETWORK_DEV=tun1
TUN_NETWORK_PREFIX3=192.168.100
CN_RULES_FILE="/etc/tunnel/cn_rules.conf"

start_tunnel() {
    # set -x

    # netif
    ip tuntap del dev ${TUN_NETWORK_DEV} mode tun
    ip tuntap add dev ${TUN_NETWORK_DEV} mode tun
    ip addr add ${TUN_NETWORK_PREFIX3}.1/24 dev ${TUN_NETWORK_DEV}
    ip link set $TUN_NETWORK_DEV up

    # socks server
    ip route add $SOCKS_SERVER via $GATEWAY_IP

    # cn rules
    for i in $(cat ${CN_RULES_FILE})
    do
    ip route add $i via $GATEWAY_IP
    done

    # default rules
    ip route del default via ${GATEWAY_IP}
    ip route add 0.0.0.0/1 via ${TUN_NETWORK_PREFIX3}.1
    ip route add 128.0.0.0/1 via ${TUN_NETWORK_PREFIX3}.1
  
    echo "route start !"
    echo "start tun2socks !"
    trap stop_tunnel INT TERM
    badvpn-tun2socks --tundev "$TUN_NETWORK_DEV" --netif-ipaddr "${TUN_NETWORK_PREFIX3}.2" --netif-netmask 255.255.255.0 --socks-server-addr "${SOCKS_SERVER}:${SOCKS_PORT}"
    TUN2SOCKS_PID="$!"

    wait $TUN2SOCKS_PID
}

stop_tunnel() {
    # cancel cn rules
    for i in $(cat ${CN_RULES_FILE})
    do
    ip route del $i via $GATEWAY_IP
    done

    # remove socks server
    ip route del $SOCKS_SERVER via $GATEWAY_IP

    # restore default rules
    ip route del 0.0.0.0/1 via ${TUN_NETWORK_PREFIX3}.1
    ip route del 128.0.0.0/1 via ${TUN_NETWORK_PREFIX3}.1
    ip route add default via $GATEWAY_IP

    # disable tun
    ip link set $TUN_NETWORK_DEV down
    ip addr del ${TUN_NETWORK_PREFIX3}.1/24 dev $TUN_NETWORK_DEV
    ip tuntap del dev $TUN_NETWORK_DEV mode tun

    echo "route stop !"
}

case $op in 
    show)
        set +x
        echo "envs:"
        echo "socks server: ${SOCKS_SERVER}:${SOCKS_PORT}"
        echo "gw: ${GATEWAY_IP}"
        echo "${TUN_NETWORK_DEV}: ${TUN_NETWORK_PREFIX3}"
        echo ""
    
        curl ip.bi
        ;;
    start)
        start_tunnel
        ;;
    stop)
        stop_tunnel
        ;;
    reload)
        stop_tunnel
        start_tunnel
        ;;
    restart)
        stop_tunnel
        start_tunnel
        ;;
    *)
        echo "wrong params"
        ;;
esac

set +x
