#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Please, execute as root"
	exit 1
fi

echo "===== SERVER STATS ====="

# OS Version
echo ">> OS Version:"
cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '""'
echo ""

# Uptime
echo ">> Uptime:"
uptime -p
echo ""

#Load Average
echo ">> Load Average:"
uptime | awk -F'load average: ' '{print $2}'
echo ""

# Logged in users
echo ">> Logged in users:"
who | wc -l
echo ""

# CPU Usage
echo ">> Total CPU usage:"
top -bn1 | grep "Cpu(s)" | \
	awk '{print "Used: " $2 + $4 "% | Idle: " $8 "%"}'

# Memory Usage
echo ">> Memory Usage:"
free -h | awk '/Mem:/ {
	used=$3; free=$4; total=$2;
	percent=($3/$2)*100;
	printf("Used: %s | Free: %s | Total: %s | Usage: %.2f%%\n", used, free, total, percent
}'
echo ""

# Disk Usage
echo ">> Disk Usage:"
df -h --total | grep total | \
awk '{print "Used: " $3 " | Free: " $4 " | Total: " $2 " | Usage: " $5}'
echo ""

# Top 5 CPU-consuming processes
echo ">> Top 5 CPU-consuming processes:"
ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6
echo ""

# Top 5 Memory-consuming processes
echo ">> Top 5 Memory-consuming processes:"
ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 6
echo ""

#Stretch goal: Failed login attempts
echo ">> Failed login attempts (last 24h):"
journalctl _COMM=sshd --since "24 hours ago" | grep "Failed password" | wc -l
echo ""

echo "===== End of Report ====="
