#!/bin/sh
#Enable JFFS2 and place script in /jffs/ then run on startup in web interface.
#You can check the log from http://192.168.1.1/user/wol.html
 
#debugging
#set -xv
 
INTERVAL=5
NUMP=3
OLD=""
PORT=80
TARGET=192.168.1.1
INTERFACE=br-lan
MAC=00:00:00:00:00:00
WOL=/usr/bin/etherwake
LOGFILE="/www/wol/index.html"
LOGPROG="logread" # default: dmesg
 
echo "<meta http-equiv=\"refresh\" content=\"10\">" > $LOGFILE
echo "AUTO WOL Script started at" `date` "<br>" >> $LOGFILE
 
wake_up () {
	PORT=$1
	TARGET=$2
	BROADCAST=$3
	MAC=$4
	NEW=`$LOGPROG | awk '/WOL_LOG/ && /DST='"$TARGET"'/ && /DPT='"$PORT"'/ {print }' | tail -1`
	SRC=`$LOGPROG | awk -F'[=| ]' '/WOL_LOG/ && /DST='"$TARGET"'/ && /DPT='"$PORT"'/ {print }' | tail -1`
	LINE=`$LOGPROG | awk '/WOL_LOG/ && /DST='"$TARGET"'/ && /DPT='"$PORT"'/'`
	if [ "$NEW" != "" -a "$NEW" != "$OLD" ]; then
		if ping -qc $NUMP $TARGET >/dev/null; then
			echo "NOWAKE $TARGET was accessed by $SRC and is already alive at" `date` "<br>">> $LOGFILE
		else
			echo "WAKE $SRC causes wake on lan at" `date` "<br>">> $LOGFILE
			$WOL -i $BROADCAST $MAC >> $LOGFILE
			echo "<br>" >> $LOGFILE
			sleep 5
		fi
		OLD=$NEW
	fi
}
 
while sleep $INTERVAL; do
wake_up $PORT $TARGET $INTERFACE $MAC;
done
