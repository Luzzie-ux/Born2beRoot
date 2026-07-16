*This project has been created as part of the 42 curriculum by rodrpere*

# Table of contents

1. [Introduction](#introduction)
	1. [Description](#description)
	2. [Instalation](#instalation)
	3. [Resources](#resources)
2. [Installing the VM](#installing-the-vm)
	1. [Debian ISO](#debian-iso)
	2. [Virtual Box](#virtual-box)
3. [Installing Debian](#installing-debian)
	1. [Settings](#settings)
	2. [Partitions](#partitions)
4. [VM Setup](#vm-setup)
	1. [Sudo](#sudo-config)
	2. [SSH](#ssh-config)
	3. [UFW](#ufw-config)
	4. [Script](#script)
5. [Bonus Service](#bonus-service)
	1. [LightTPD](#lighttpd)
	2. [MariaDB](#mariadb)
	3. [PHP](#php)
	4. [WordPress](#wordpress)
	5. [F2B](#fail2ban)

# Introduction

*You can do anything you want to do, because this is your world*

## Description

Born2beRoot is a system administration project whose goal is to build a small, secure server from scratch inside a virtual machine, without any graphical interface, and to configure it according to a strict set of rules covering partitioning, users, password policy, `sudo`, SSH, the firewall and a monitoring script.

The chosen operating system for this project is **Debian** (latest stable release, no testing/unstable branch). Debian was preferred over Rocky Linux mainly because of its lighter setup for a first system administration project, its very large documentation base, and its `apt`/`AppArmor` stack, which is simpler to configure correctly than `dnf`/`SELinux` for someone new to server administration.

**Debian vs Rocky Linux**
Debian uses the `apt`/`dpkg` package system, has an extremely large community and package repository, and ships with `AppArmor`, a path-based Mandatory Access Control (MAC) system. Rocky Linux is a RHEL-compatible distribution using `dnf`/`rpm`, generally favoured in enterprise environments, and ships with `SELinux`, a label-based MAC system that is more granular but also more complex to configure. Both are valid choices for this project; Debian was chosen for its gentler learning curve.

**AppArmor vs SELinux**
`AppArmor` restricts what a program can do by attaching a security profile to it based on file paths, making it easier to read and to write custom profiles. `SELinux` labels every file, process and port with a security context and enforces access based on those labels, which is more powerful and precise but also considerably harder to configure and debug for newcomers.

**UFW vs firewalld**
`UFW` (Uncomplicated Firewall) is a simplified front-end for `iptables`/`nftables`, aimed at being easy to read and quick to configure with commands like `ufw allow 4242`. `firewalld` (used on Rocky) works with the concept of *zones* and services, and reloads rules dynamically without dropping existing connections. Both were used here (or would be used, depending on the chosen OS) to leave only port `4242` reachable.

**VirtualBox vs UTM**
`VirtualBox` is a free, cross-platform (Windows/Linux/macOS Intel) hypervisor with a mature GUI and snapshot system. `UTM` is used instead on Apple Silicon (M1/M2/M3...) Macs, since VirtualBox does not support that architecture; it is based on QEMU and provides similar virtualization features with a native ARM-friendly interface. For this project, **VirtualBox** was used.

The main design choices made during the setup were:
- Two encrypted LVM partitions at minimum (see [Partitions](#partitions)), so that data at rest is protected even if the virtual disk is copied.
- A strict password and `sudo` policy (see [Sudo Config](#sudo-config)) to limit the impact of a compromised or guessed password.
- SSH restricted to a non-default port (`4242`) and to non-root logins only.
- A firewall (`UFW`) that only allows the SSH port.
- A dedicated non-root user, member of both the `sudo` and `user42` groups, used for daily administration instead of the root account.
- A `monitoring.sh` script broadcasting server health information to every terminal every 10 minutes via `cron` and `wall`.

## Instalation

1. Install VirtualBox (or UTM on Apple Silicon Macs) on the host machine.
2. Download the latest stable Debian netinstall ISO.
3. Create a new virtual machine and attach the ISO (see [Installing the VM](#installing-the-vm)).
4. Follow the Debian installer, choosing manual partitioning with LVM and disk encryption (see [Installing Debian](#installing-debian)).
5. Once installed, log in as root, then apply the configuration described in [VM Setup](#vm-setup): `sudo`, SSH, UFW, password policy and `monitoring.sh`.
6. Reboot and confirm the firewall, SSH and monitoring script are all active on startup.
7. Retrieve the SHA1 signature of the `.vdi` file and place it in `signature.txt` at the root of the repository, as required by the subject.

## Resources

- [Debian Documentation](https://www.debian.org/doc/)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [Arch Wiki - LVM](https://wiki.archlinux.org/title/LVM)
- [Sudo Manual](https://www.sudo.ws/docs/man/sudo.man/)
- [UFW Documentation - Ubuntu Community Help Wiki](https://help.ubuntu.com/community/UFW)
- [Debian AppArmor Wiki](https://wiki.debian.org/AppArmor)
- man pages: `man sudoers`, `man ufw`, `man crontab`, `man ss`, `man lsblk`

**Use of AI:** an AI assistant (Claude) was used only as a documentation/formatting helper for this README — organizing the required sections, wording the OS/security comparisons, and reviewing the clarity of the `monitoring.sh` explanations. It was not used to write the actual server configuration, the `sudoers` rules, or the `monitoring.sh` script logic, which were done by hand and validated locally before being described here.

# Installing the VM

## Debian ISO

The latest stable **Debian** netinstall ISO was downloaded directly from the official Debian website. The netinstall image was chosen (over the full DVD image) since only a minimal set of packages is required for a server with no graphical environment.

## Virtual Box

A new virtual machine was created in VirtualBox with the following base settings:
- Type: Linux / Debian (64-bit)
- RAM and CPU allocated according to the host machine's available resources
- A dynamically allocated virtual disk, later partitioned manually with LVM and encryption during installation
- Network adapter set to NAT (or Bridged, depending on the desired access), so port `4242` can be reached for SSH

# Installing Debian

## Settings

During the installer, the following choices were made:
- Language, location and keyboard layout set as needed
- Hostname set to the login followed by `42` (e.g. `rodrpere42`), as required by the subject
- A root password set following the password policy described below
- A first user is **not** created here, since the required user (with the login as username) is created manually afterwards and added to the `sudo` and `user42` groups
- Manual partitioning selected instead of the guided option, to allow LVM + encryption

## Partitions

The disk was partitioned manually, using **LVM on top of an encrypted partition (LUKS)**, so that at least two logical volumes are encrypted, as required. An example of the resulting layout:

```
~/ lsblk

NAME                	MAJ:MIN   RM  SIZE  RO TYPE  MOUNTPOINT
sda                   	   8:0    0    30G  0  disk
├─sda1               	   8:1    0   476M  0  part   /boot
├─sda2               	   8:2    0     1K  0  part
└─sda5                	   8:5    0  29.5G  0  part
  └─sda5_crypt       	 254:0    0  29.5G  0  crypt
	├─LVMGroup-root  	 254:1    0    10G  0  lvm   /
	├─LVMGroup-swap  	 254:2    0   2.3G  0  lvm   [SWAP]
	├─LVMGroup-home  	 254:3    0     5G  0  lvm   /home
	├─LVMGroup-var    	 254:4    0     3G  0  lvm   /var
	├─LVMGroup-srv   	 254:5    0     3G  0  lvm   /srv
	├─LVMGroup-tmp   	 254:6    0     3G  0  lvm   /tmp
	└─LVMGroup-var--log  254:7    0	    4G  0  lvm   /var/log
sr0						  11:0	  1  1024M  0  rom
```

`/boot` is kept outside the encrypted volume since GRUB needs to read it before the disk can be unlocked. Everything else (`/`, swap and `/home`) sits inside the LUKS-encrypted physical volume, itself split into logical volumes by LVM. Sizes were chosen to comfortably fit a minimal server install while avoiding wasted disk space.

# VM Setup

## Sudo Config

`sudo` was installed and configured through a dedicated file in `/etc/sudoers.d/`, instead of editing `/etc/sudoers` directly, to keep the configuration isolated and safe to edit with `visudo`.

```bash
# Auth has to be limited to 3 attempts
Defaults    passwd_tries=3
Defaults    badpass_message="[ERROR] INCORRECT PASSWORD, TRY AGAIN"

# Sudo uses log path
Defaults    logfile="/var/log/sudo/sudo_config"

# Sudo I/O actions
Defaults    log_input
Defaults    log_output

# Logs directory path
Defaults    iolog_dir="/var/log/sudo"

# TTY requirement
Defaults    requiretty

# Restricted paths for sudo
Defaults    secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

- `passwd_tries=3` limits authentication to 3 attempts before `sudo` fails.
- `badpass_message` shows a custom error message on a wrong password instead of the default one.
- `logfile` and `iolog_dir` make sure every `sudo` action (including full input/output) is logged inside `/var/log/sudo/`, as required.
- `log_input` / `log_output` record everything typed and displayed during a `sudo` session.
- `requiretty` forces `sudo` to only run when attached to a real TTY, which prevents some scripted/background privilege escalation.
- `secure_path` restricts the directories `sudo` will search for executables, preventing PATH-hijacking attacks.

### Sudo & Password Policies

Password aging rules were configured in `/etc/login.defs` and applied to existing users with `chage`:

```bash
sudo chage -M 30 -m 2 -W 7 <username>
```

- `-M 30`: the password expires every 30 days.
- `-m 2`: at least 2 days must pass between two password changes.
- `-W 7`: the user gets a warning 7 days before expiration.

The complexity rules (minimum length of 10, at least one uppercase, one lowercase and one digit, no more than 3 identical consecutive characters, password must not contain the username, and at least 7 new characters compared to the previous password) were enforced through `pam_pwquality` in `/etc/pam.d/common-password`, called from `/etc/security/pwquality.conf`. This last rule does not apply to the root password, per the subject. After configuring all of this, every account's password (including root's) was changed to comply with the new policy.

## SSH Config

The SSH server was configured in `/etc/ssh/sshd_config` with:

```bash
Port 4242
PermitRootLogin no
```

`sshd` then listens only on port `4242` and root logins over SSH are refused, forcing anyone connecting to use a standard user account and `sudo` afterwards, in line with the security requirements of the subject.

## UFW config

`UFW` was installed and configured to only allow SSH traffic on the custom port:

```bash
sudo apt install ufw
sudo ufw allow 4242
sudo ufw enable
sudo systemctl enable ufw
```

`ufw status` then shows a single allowed rule for port `4242` (both IPv4 and IPv6), and the firewall is enabled at boot, as required.

## Script

`monitoring.sh` is a Bash script that gathers and displays a summary of the server's status: architecture and kernel version, physical/virtual CPU count, RAM and disk usage with percentages, CPU load, last boot time, LVM status, active TCP connections, logged-in users, IPv4/MAC address, and the number of commands run through `sudo`. All of this information is broadcast to every open terminal using `wall`, so no manual polling is needed.

```bash
#!/usr/bin/bash

arch=$(uname -a)
fcpu=$(grep -c "physical id" /proc/cpuinfo)
vcpu=$(grep -c processor /proc/cpuinfo)

free=$(free -m | grep -i mem)
ram_use=$(echo "$free" | awk '{print $3}')
ram_total=$(echo "$free" | awk '{print $2}')
ram=$(echo "$free" | awk '{printf "%2.f", $3/$2*100}')

df=$(df -m | grep -i dev | grep -v boot)
mem_use=$(echo "$df" | awk '{use += $3} END {print use}')
mem_total=$(echo "$df" | awk '{total += $2} END {print total}')
ptmem=$((mem_total / 1024))
mem=$(((mem_use * 100 / mem_total)))

load=$(vmstat 1 2 | tail -1 | awk '{print $15}')
cpu_info=$(expr 100 - $load)
cpu=$(printf "%.1f%%" $cpu_info)

reboot=$(who -b | awk '{print $3 " " $4}')

ls=$(lsblk | grep -i lvm | wc -l)
if [ $ls -gt 0 ]
    then lvm="yes"
else
    lvm="no"
fi

net=$(ss -ta | grep ESTAB | wc -l)
usr=$(users | wc -w)

ip=$(hostname -I)
mac=$(ip link | grep -i link/ether | awk '{print $2}')

sudo=$(journalctl _COMM=sudo | grep -i COMMAND | wc -l)

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
```

Every field maps directly to a subject requirement: `arch`/kernel from `uname -a`, physical/virtual CPU counts from `/proc/cpuinfo`, RAM and disk usage from `free`/`df`, CPU load from `vmstat`, last boot from `who -b`, LVM detection from `lsblk`, active connections from `ss -ta`, logged-in users from `users`, network info from `hostname -I` / `ip link`, and the sudo command count from `journalctl`.

### Crontab

The script is executed automatically every 10 minutes through a system cron job:

```bash
sudo crontab -e
*/10 * * * * /usr/local/bin/monitoring.sh
```

Since `wall` is used instead of a permanent daemon, the job can be interrupted at any time (e.g. by commenting out or removing the crontab entry) without touching the script itself, exactly as requested during the peer review.

# Bonus Service

*This section documents the bonus services set up on top of the mandatory part: a WordPress website served through lighttpd, MariaDB and PHP, plus Fail2Ban as the extra service of choice.*

| Service   |       |               Link                      |
|-----------|-------|-----------------------------------------|
| LightTPD  |       | https://www.lighttpd.net/               |
| PHP       |       | https://www.php.net/                    |
| MariaDB   |       | https://mariadb.org/                    |
| Wordpress |       | https://wordpress.org/                  |
| F2B       |       | https://github.com/fail2ban/fail2ban    |

## Lighttpd

Lighttpd is a lightweight, low-memory-footprint HTTP server, well suited to a small VM with limited resources — this is why it was chosen over Apache2/NGINX (which are excluded by the subject anyway for the "service of your choice" slot).

```bash
sudo apt install lighttpd
sudo systemctl enable lighttpd
sudo systemctl start lighttpd
```

We install `lighttpd`, then enable and start it so it runs automatically on every boot. By default it serves static files from `/var/www/html`, which is where WordPress will be deployed.

To let lighttpd execute PHP files through FastCGI:

```bash
sudo lighttpd-enable-mod fastcgi
sudo lighttpd-enable-mod fastcgi-php
sudo systemctl restart lighttpd
```

This enables the `fastcgi` and `fastcgi-php` modules, then restarts the service so `.php` files are handed off to the PHP FastCGI process manager instead of being served as plain text.

## MariaDB

MariaDB is a database server originally made by the developer of MySQL, it is an open source software used for multiple purposes.

```bash
sudo apt install mariadb-server
sudo mariadb_secure_installation

# When prompted read the question and answer with these:
# Switch to unix_socket authentication? → N
# Change the root password? → N
# Remove anonymous users? → Y
# Disallow root login remotely? → Y
# Remove test database and access to it? → Y
# Reload privilege tables now? → Y
```

We don't switch to unix socket auth because we already have protected root. We don't change the root password because it's not really root, since we need to give it admin perms for WordPress. We remove anonymous users because they were only there for debugging purposes, just like the `test` database. We disallow remote root login to prevent anyone from connecting by guessing the password. We reload privilege tables to apply the new, more secure settings.

### Database

Once everything is set up to use MariaDB, we run the following command to bring up the MariaDB terminal:
`mariadb`

Now to create a database for our WordPress server we type:
```mariadb
CREATE DATABASE wp_database_name;
```
Remember that every command in MariaDB ends with a semicolon; if you forget it, the terminal will show a new line of arrows waiting for it.

Next we create a user inside the database and grant it access to the WordPress database:
```mariadb
CREATE USER 'username'@'localhost' IDENTIFIED BY '12345';

GRANT ALL PRIVILEGES ON wp_database_name.* TO 'username'@'localhost';
```

Now we reload the permissions so the changes take effect:
```mariadb
FLUSH PRIVILEGES;
```

Once everything is done, type `exit` to leave the MariaDB terminal. To check the databases at any point:
```mariadb
SHOW DATABASES;
```

## PHP

PHP is the scripting language WordPress is built on; it needs the FastCGI process manager (`php-fpm`) plus a few common extensions used by WordPress.

```bash
sudo apt install php php-fpm php-mysqli php-curl php-gd php-xml php-mbstring
sudo systemctl enable php8.4-fpm
sudo systemctl start php8.4-fpm
```

We install PHP with FPM (so it can be driven through FastCGI by lighttpd) along with the extensions WordPress relies on for database access, image handling, HTTP requests and text encoding, then enable and start the service so it survives reboots.

## Wordpress

WordPress is the content management system served by the stack above.

```bash
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo rm latest.tar.gz
sudo chown -R www-data:www-data /var/www/html/wordpress
```

We download the latest WordPress release straight into the web root, extract it, remove the archive, and give ownership to the `www-data` user/group so lighttpd (and PHP) can read and write the files it needs (uploads, cache, etc.).

Then, browsing to the server's IP finishes the setup through WordPress's own installation wizard, where the database name, database user and password created earlier are entered to complete `wp-config.php`.

## Fail2Ban

Fail2Ban was chosen as the extra service, since it directly reinforces the security work done in the mandatory part: it watches log files (SSH in particular) and automatically bans IPs that show malicious behaviour, such as repeated failed login attempts.

```bash
sudo apt install fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

We copy `jail.conf` to `jail.local` so local customizations survive package upgrades (`jail.conf` gets overwritten by updates, `jail.local` does not).

```ini
[sshd]
enabled = true
port    = 4242
maxretry = 3
bantime  = 3600
```

This jail watches the SSH service on our custom port `4242`, and bans an offending IP for one hour (`bantime = 3600` seconds) after 3 failed attempts (`maxretry = 3`), which nicely complements the `sudo` and SSH policies from the mandatory part.

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo fail2ban-client status sshd
```

Finally, the service is enabled and started so it's active at every boot, and its status can be checked at any time with `fail2ban-client status sshd` to see currently banned IPs and ban counts.