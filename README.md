# mirtf
Mikrotik IP Reputation Threats Firewall

Gran any kind of Blacklist / IP Reputation lists / Other's lists, I use:

IPSum from https://github.com/stamparm/maltrail - https://github.com/stamparm/ipsum

Malware Patrol

Firehol Level 1, level2, (level3 and level4 multiple false positives, even Google's DNS and Github was in there)

Dshield

ET block / compromised

Spamhaus

CyberCrime

CIArmy lists

Blocklist.de

Talos Intelligence

Binary Defense

Emerging Threats

Greenshow 

Bruteforce lists and others maybe (check lists.txt)



I don't like executing "prepared" from others .rsc scripts. So I gathered those lists, then sorted them, uniq them, removed IPs and subnets that I use
(10.0.0.0/8 , 192.168.1.0/24 and my own ISP dynamic IP pools) and created a list of them. Unique and sorted.
Then this list is modified to mikrotik format. Leaving of course the raw IP list intact for any other use (ipset / firewalld / csf / whatever). 

Just add a cron every "x" hours and set a location for the output file. I set it in a public_html folder in my LAN so mikrotiks can grab it from there directly.
