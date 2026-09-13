# nftables-rsyslog-iptables
Detect load events w/ nftables, log w/ rsyslog and block w/ iptables.  

After provisioning:  
```
sudo systemctl restart nftables.service
sudo systemctl status nftables.service
sudo systemctl restart rsyslog
sudo systemctl status rsyslog
```
Log viewing:  
```
# dedupe for readability
$ gawk '!seen[$0]++' /var/log/nftables-burst.log
2026-06-28 11:04:45 nftables: burst SRC=3.245.xxx.xxx
2026-06-28 11:04:46 nftables: burst SRC=3.245.xxx.xxx
2026-06-28 11:04:47 nftables: burst SRC=3.245.xxx.xxx
2026-06-28 11:04:48 nftables: burst SRC=3.245.xxx.xxx
2026-06-28 11:04:49 nftables: burst SRC=3.245.xxx.xxx

# clear logs
$ sudo truncate --size 0 /var/log/nftables-burst.log
```
  
## Use case?
Detect unbehaved bots, add them to ```cidr_list.txt``` and run ```sudo ./iptable-rules.sh``` and enjoy silent logs. You can inspect the generated table with the command ```sudo nft list ruleset``` being applied to ingress level, the most efficient level.  
```
$ whois -h whois.cymru.com " -v 66.132.172.36"
AS      | IP               | BGP Prefix          | CC | Registry | Allocated  | AS Name
398324  | 66.132.172.36    | 66.132.172.0/24     | US | arin     | 2024-05-14 | CENSYS-ARIN-01 - Censys, Inc., US
```
This gives you the full CIDR notation range. If you have too many rules that look almost similar, you may:  
```https://manpages.debian.org/unstable/aggregate/aggregate.1.en.html```
  
## And the other rules?
Protection from DDoS attacks:  
```https://people.netfilter.org/hawk/presentations/devconf2014/iptables-ddos-mitigation_JesperBrouer.pdf```
  
## License
Licensed under the WTFPL license.
