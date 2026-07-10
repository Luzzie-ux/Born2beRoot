#!/usr/bin/bash

# This Bash script must display all the following information every 10 minutes:

# •The architecture of the OS and kernel version.
architecture=(uname -a)

# •The number of physical processors.
p_core=

# •The number of virtual processors.
v_core=

# •The currently available RAM on your server and its utilization rate as a percentage.
ram=

# •The currently available storage on your server and its utilization rate as a percentage.
mem=

# •The current CPU utilization rate as a percentage.
cpu=

# •The date and time of the last reboot.
reboot=

# •Whether LVM is active or not.
lvm=

# •The number of active connections.
net=

# •The number of users using the server.
usrs=

# •The IPv4 address of your server and its MAC (Media Access Control) address.
ip=
mac=

# •The number of commands executed with the sudo program.
sudo=

# Example:
# Broadcast message from root@wil (tty1) (Sun Apr 25 15:45:00 2021):
# Architecture: Linux wil 4.19.0-16-amd64 #1 SMP Debian 4.19.181-1 (2021-03-19) x86_64 GNU/Linux
# Physical CPU: 1
# vCPU: 1
# Memory Usage: 74/987MB (7.50%)
# Disk Usage: 1009/2Gb (49%)
# CPU load: 6.7%
# Last boot: 2021-04-25 14:45
# LVM use: yes
# TCP Connections: 1 ESTABLISHED
# User log: 1
# Network: IP 10.0.2.15 (08:00:27:51:9b:a5)
# Sudo: 42 cmd