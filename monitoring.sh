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