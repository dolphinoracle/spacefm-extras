#!/bin/bash

$fm_import
CONFIG="$fm_cmd_data"

PASSFILE="${CONFIG}/pass"
USERFILE="${CONFIG}/user"
POPULATE="${fm_cmd_dir}/populatedrop"

SERVERS="${CONFIG}/servers"
IPADDRESS="${CONFIG}/ip"
DROPDISK="${CONFIG}/disks"
SELECTEDDISK="${CONFIG}/selecteddisk"
CURRENTSERVER="${CONFIG}/currentserver"
PORTNUM="${CONFIG}/portnum"
PORTNUMSSH="${CONFIG}/portnumssh"
PORTNUMFTP="${CONFIG}/portnumftp"
PORTNUMSMB="${CONFIG}/portnumsmb"
PORTNUMDAV="${CONFIG}/portnumdav"

mkdir -p "$CONFIG" &>/dev/null

export IPADDRESS
export SERVERS
export DROPDISK
export SELECTEDDISK
export CURRENTSERVER
export PORTNUM
export PORTNUMSSH
export PORTNUMFTP
export PORTNUMSMB
export PORTNUMDAV

if [ ! -e $IPADDRESS ];then
	echo "127.0.0.0" > $IPADDRESS
fi

if [ ! -e $PASSFILE ];then
	: > $PASSFILE
fi

if [ ! -e $USERFILE ];then
	whoami>"$USERFILE"
fi

if [ ! -e $SERVERS ];then
	echo " " > $SERVERS
fi

if [ ! -e $DROPDISK ];then
	echo " " > $DROPDISK
fi

if [ ! -e $SELECTEDDISK ];then
	echo " " > $SELECTEDDISK
fi

if [ ! -e $CURRENTSERVER ];then
	echo " " > $CURRENTSERVER
fi

if [ ! -e $PORTNUMSSH ];then
	echo "22" > $PORTNUMSSH
fi

if [ ! -e $PORTNUMFTP ];then
	echo "21" > $PORTNUMFTP
fi

if [ ! -e $PORTNUMSMB ];then
	echo "445" > $PORTNUMSMB
fi

if [ ! -e $PORTNUMDAV ];then
	echo "8888" > $PORTNUMDAV
fi

cp "$PORTNUMSMB" "$PORTNUM"

eval "$(spacefm -g --hbox --radio "FTP" "0" disable drop1 %v disable drop2 %v -- cp "$PORTNUMFTP" "$PORTNUM" -- disable freebutton1 %v -- --radio "SSH" "0" disable drop1 %v -- disable drop2 %v -- disable freebutton1 %v -- cp "$PORTNUMSSH" "$PORTNUM" -- --radio "DAV" "0" disable drop1 %v -- disable drop2 %v -- disable freebutton1 %v -- $POPULATE 'portnumdav' --radio "SMB" "1" enable drop1 %v -- enable drop2 %v -- enable freebutton1 %v -- cp "$PORTNUMSMB" "$PORTNUM" -- --close-box -- enable freebutton1 -- --label "IP Address" --hbox --free-button "Scan" -- $POPULATE 'server' --drop "@$SERVERS" "@$CURRENTSERVER" -- $POPULATE 'lookup' %v  --input  @$IPADDRESS -- $POPULATE 'disks' %v --close-box --label "Mount Point" --drop @$DROPDISK "@$SELECTEDDISK" --label "User Name" --input "@$USERFILE" --label "Password" --password @$PASSFILE --label "Port: " --input "@$PORTNUM" --button Mount:gtk-apply --button Cancel:gtk-cancel)"

IP="$dialog_input1"
MP="$dialog_drop2"
USER="$dialog_input2"
PW="$dialog_password1"
PORT="$dialog_input3"

if [ X"$dialog_radio1" = "X1" ];then
	TYPE="FTP"
fi

if [ X"$dialog_radio2" = "X1" ];then
	TYPE="SSH"
fi

if [ X"$dialog_radio3" = "X1" ];then
	TYPE="DAV"
fi

if [ X"$dialog_radio4" = "X1" ];then
	TYPE="SMB"
fi

if [ "X$USER" != "X" ];then
	SMBOPTIONS="-o username=$USER,password=$PW,uid=$UID,port=$PORT"
	FTPOPTIONS="${USER}:${PW}"
else
	SMBOPTIONS=""
	FTPOPTIONS=""
fi

if [ "X$dialog_pressed" = "Xbutton1" ] && [ $TYPE = "SMB" ];then
	echo "udevil mount -t cifs  $SMBOPTIONS //$IP/$MP" >>/tmp/mountshare.debug.log
	udevil mount -t cifs  $SMBOPTIONS //$IP/$MP
fi

if [ "X$dialog_pressed" = "Xbutton1" ] && [ $TYPE = "FTP" ];then
	echo "udevil mount -t curlftpfs ftp://$FTPOPTIONS@$IP" >>/tmp/mountshare.debug.log
	udevil mount -t curlftpfs ftp://$FTPOPTIONS@$IP
fi

if [ "X$dialog_pressed" = "Xbutton1" ] && [ $TYPE = "SSH" ];then
	echo "echo ${PW}|udevil mount -t sshfs $IP -o port=$PORT,password_stdin" >>/tmp/mountshare.debug.log
	echo ${PW}|udevil mount -t sshfs $IP -o port=$PORT,password_stdin
fi

if [ "X$dialog_pressed" = "Xbutton1" ] && [ $TYPE = "DAV" ];then
	echo "echo -e "$USER\n$PW\n"|udevil mount -t davfs http://$IP:$PORT" >>/tmp/mountshare.debug.log
	echo -e "$USER\n$PW\n"|udevil mount -t davfs http://$IP:$PORT
fi

echo -n "$PW" > "$PASSFILE"
echo -n "$USER" > "$USERFILE"
echo -n "$IP" > "$IPADDRESS"
echo -n "$MP" > "$SELECTEDDISK"

case $TYPE in
	"FTP")
		echo -n "$PORT" > "$PORTNUMFTP"
		;;	
	"SSH")
		echo -n "$PORT" > "$PORTNUMSSH"
		;;	
	"SMB")
		echo -n "$PORT" > "$PORTNUMSMB"
		;;	
	"DAV")
		echo -n "$PORT" > "$PORTNUMDAV"
		;;	
esac

exit $?

