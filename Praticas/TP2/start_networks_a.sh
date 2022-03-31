#!/bin/bash

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 192.168.88.101 -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -j ACCEPT
sudo iptables -A FORWARD -i eth1 -j ACCEPT