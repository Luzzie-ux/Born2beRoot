#!/usr/bin/bash

# Architecture
arch=$(uname -a)

# Physical CPU
fcpu=$(grep -c "physical id" /proc/cpuinfo)

# Virtual CPU
vcpu=$(grep -c processor /proc/cpuinfo)

# RAM usage
free=$(free -m | grep -i mem)
ram_use=$(echo "$free" | awk '{print $3}')
ram_total=$(echo "$free" | awk '{print $2}')
ram=$(echo "$free" | awk '{printf "%2.f", $3/$2*100}')

# Disk usage
df=$(df -m | grep -i dev | grep -v boot)
mem_use=$(echo "$df" | awk '{use += $3} END {print use}')
mem_total=$(echo "$df" | awk '{total += $2} END {print total}')
ptmem=$((mem_total / 1024))
mem=$(((mem_use * 100 / mem_total)))

# CPU usage
load=$(vmstat 1 2 | tail -1 | awk '{print $15}')
cpu_info=$(expr 100 - $load)
cpu=$(printf "%.1f%%" $cpu_info)

# Last Boot
reboot=$(who -b | awk '{print $3 " " $4}')

# Whether LVM is active or not
ls=$(lsblk | grep -i lvm | wc -l)
if [ $ls -gt 0 ]
    then lvm="yes"
else 
    lvm="no"
fi

# The number of active connections
net=$(ss -ta | grep ESTAB | wc -l)

# The number of users using the server
usr=$(users | wc -w)

# The IPv4 address and MAC address
ip=$(hostname -I)
mac=$(ip link | grep -i link/ether | awk '{print $2}')

# The number of commands executed with the sudo program
sudo=$(journalctl _COMM=sudo | grep -i COMMAND | wc -l)

# Print information
wall "  Architecture: $arch
    Physical CPU: $fcpu
    vCPU: $vcpu
    RAM usage: $ram_use/${ram_total}MB ($ram%)
    Disk usage: $mem_use/${ptmem}GB ($mem%)
    CPU load: $cpu
    Last boot: $reboot
    LVM use: $lvm
    TCP Connections: $net ESTABLISHED
    User log: $usr
    Network: $ip ($mac)
    Sudo: $sudo cmd"

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
