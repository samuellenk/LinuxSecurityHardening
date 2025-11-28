#!/usr/bin/env bash

# standard ipv4 rules
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT;
iptables -A INPUT -p tcp --dport ssh -j ACCEPT;
iptables -P INPUT DROP;
iptables -I INPUT 1 -i lo -j ACCEPT;
# standard ipv6 rules
ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT;
ip6tables -A INPUT -p tcp --dport ssh -j ACCEPT;
ip6tables -P INPUT DROP;
ip6tables -I INPUT 1 -i lo -j ACCEPT;
# ssh rules
iptables -I INPUT -p tcp --dport 22 -m state --state NEW -m recent --set;
iptables -I INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 10 --hitcount 10 -j DROP;
ip6tables -I INPUT -p tcp --dport 22 -m state --state NEW -m recent --set;
ip6tables -I INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 10 --hitcount 10 -j DROP:
