#!/usr/bin/env sh
# flush
/usr/sbin/iptables -t raw -F
/usr/sbin/iptables -t raw -X
/usr/sbin/iptables -F
/usr/sbin/iptables -X
while read line; do
    case $line in
        #([0-9]*) /usr/sbin/iptables -A INPUT -i enx001e063686b2 -p tcp -m tcp -s $line -j DROP;;
		#([0-9]*) /usr/sbin/nft add rule netdev filter ingress ip saddr $line drop
		#([0-9]*) /usr/sbin/nft add rule netdev filter ingress ip saddr $line tcp dport { 80, 443 } drop
		([0-9]*) /usr/sbin/nft add rule netdev filter ingress ip saddr $line meta l4proto . th dport { tcp . 8080, tcp . 1443, tcp . 64738, udp . 64738 } drop
    esac
done < /home/ran/cidr_list.txt
# limit conns on port 80
/usr/sbin/iptables -A INPUT -i enx001e063686b2 -p tcp -m tcp --dport 8080 -m state --state NEW -m recent --set --name DEFAULT --mask 255.255.0.0 --rsource
/usr/sbin/iptables -A INPUT -i enx001e063686b2 -p tcp -m tcp --dport 8080 -m state --state NEW -m recent --update --seconds 60 --hitcount 2 --name DEFAULT --mask 255.255.0.0 --rsource -j DROP
# prevent syn, syn-ack, ack flooding
/usr/sbin/iptables -t raw -I PREROUTING -i enx001e063686b2 -p tcp -m tcp --syn --dport 1443 -j CT --notrack
/usr/sbin/iptables -A INPUT -i enx001e063686b2 -p tcp -m tcp --dport 1443 -m state --state INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
/usr/sbin/iptables -A INPUT -i enx001e063686b2 -p tcp -m tcp --dport 1443 -m state --state INVALID -j DROP
# confirm rules
/usr/sbin/iptables -S
/usr/sbin/iptables -L -n -t raw
# run in loose mode, etc.
/usr/sbin/sysctl -w net/netfilter/nf_conntrack_tcp_loose=0
/usr/sbin/sysctl -w net/ipv4/tcp_timestamps=1
/usr/sbin/sysctl -w net/netfilter/nf_conntrack_max=2000000
/usr/bin/sh -c 'echo 2000000 > /sys/module/nf_conntrack/parameters/hashsize'
exit 0
