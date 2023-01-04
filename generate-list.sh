#!/bin/bash
SCRIPT_PATH="${BASH_SOURCE:-$0}"
ABS_SCRIPT_PATH="$(realpath "${SCRIPT_PATH}")"
workdir="$(dirname "${ABS_SCRIPT_PATH}")"
tmpdir="$workdir/tmp"

######################################################
#SETTINGS
list="blacklist"
#File with cleaned & formatted ip addresses
infile="$tmpdir/FULL.list"
#Where to put rsc script
outfile="/var/www/html/threats/blacklist.rsc"
######################################################

mkdir -p $tmpdir
cd $workdir
rm -fr $tmpdir/*

# Get the "normal" lists in tmp dir (tmp)
wget -c -i $workdir/lists.txt -P $tmpdir

cd $tmpdir

# Get weird lists needs editing (IPSUM / MalwararePatrol) directly from this script

curl --compressed https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt 2>/dev/null | grep -v "#" | grep -v -E "\s[1-2]$" | cut -f 1 > ipsum.txt

wget "https://lists.malwarepatrol.net/cgi/getfile?receipt=253404548925&product=33&list=dansguardian" -O malwarepatrol.ip
grep -Eo '^(([1-9]{0,1}[0-9]{0,2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]{0,1}[0-9]{0,2}|2[0-4][0-9]|25[0-5])(\/)?([1-2][0-9]|3[0-2]|[0-9]\n)' malwarepatrol.ip > malware.IPs
rm -fr malwarepatrol.ip

# Remove comments, spaces, tabs, 10.x subnet, 192.x subnet (we use them in VPNs and Locally) per list. Just in case.

sed -i '/^10./d' $tmpdir/*
sed -i '/^192./d' $tmpdir/*
sed -i "s/[;].*//" $tmpdir/*
sed -i "s/[#].*//" $tmpdir/*
sed -i '/:/d' $tmpdir/*
sed -i '/^$/d' $tmpdir/*
sed -i "s/^[ \t]*//" $tmpdir/*
sed -i "s/\s+//g" $tmpdir/*
# Better remove all leading and trailing whitespace from end of each line
sed -i "s/^[ \t]*//;s/[ \t]*$//" $tmpdir/*


# Sort what's left
sort * -u > $tmpdir/FULL.list

# clean up the full list
# remove subnets that might be ours (dynamic IPs/our ISP IPs/Local subnets) - comments - empty lines from our Sorted list (FULL.list)

sed -i '/^10./d' $tmpdir/FULL.list
sed -i '/^192./d' $tmpdir/FULL.list
sed -i '/^#/d' $tmpdir/FULL.list
sed -i '/^0.0.0/d' $tmpdir/FULL.list
sed -i '/^[[:space:]]*$/d' $tmpdir/FULL.list
sed -i '/^2.84./d' $tmpdir/FULL.list
sed -i '/^2.85./d' $tmpdir/FULL.list
sed -i '/^2.86./d' $tmpdir/FULL.list
sed -i '/^2.87./d' $tmpdir/FULL.list
sed -i '/^178.146./d' $tmpdir/FULL.list
sed -i '/^178.147./d' $tmpdir/FULL.list
sed -i '/^79.128./d' $tmpdir/FULL.list
sed -i '/^79.129./d' $tmpdir/FULL.list
sed -i '/^79.130./d' $tmpdir/FULL.list
sed -i '/^79.131./d' $tmpdir/FULL.list
sed -i '/^85.72./d' $tmpdir/FULL.list
sed -i '/^85.73./d' $tmpdir/FULL.list
sed -i '/^85.74./d' $tmpdir/FULL.list
sed -i '/^85.75./d' $tmpdir/FULL.list
sed -i '/^87.202./d' $tmpdir/FULL.list
sed -i '/^87.203./d' $tmpdir/FULL.list
sed -i '/^94.64./d' $tmpdir/FULL.list
sed -i '/^94.65./d' $tmpdir/FULL.list
sed -i '/^94.66./d' $tmpdir/FULL.list
sed -i '/^94.67./d' $tmpdir/FULL.list
sed -i '/^94.68./d' $tmpdir/FULL.list
sed -i '/^94.69./d' $tmpdir/FULL.list
sed -i '/^94.70./d' $tmpdir/FULL.list
sed -i '/^94.71./d' $tmpdir/FULL.list


# Assemble the list in mikrotik format now.
# Clear the file just in case
echo > $outfile

# We need to drop all previous IPs in this address list because mikrotik does not check for duplicates (and they may be removed from file)
# Integrated in mikrotik script - leaving it here for reminder
# echo /ip firewall address-list remove [find where list="blacklist"] > $outfile


#Build rsc file
for line in $(cat $infile); do
  echo /ip firewall address-list add address="$line" list="$list" >> $outfile
done

sort -u -o $outfile $outfile
