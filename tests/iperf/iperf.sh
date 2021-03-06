#!/bin/sh -e

set -x

# iperf.lava must be redirected to a iperf host in the same network
if ! opkg list_installed |grep -q iperf ; then
    opkg update
    opkg install iperf
fi

echo "whitelisting domain lava from rebinding protections"
uci add_list dhcp.@dnsmasq[0].rebind_domain=lava
/etc/init.d/dnsmasq reload

iperf -c iperf.lava -f m >/tmp/iperf.output

cat /tmp/iperf.output
MBIT=$(tail -n1 /tmp/iperf.output | awk '{ print $7 }')

lava-test-case iperf-result --result pass --measurement "$MBIT" --units Mbits/sec
