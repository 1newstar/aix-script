#!/bin/ksh -x
MYNAME=$(basename $0)
SERVICE_INTERFACE=en0
  SERVICE_NETMASK=255.255.255.0
eval $(echo $(basename $0) | awk -F"[_\.]" '{print "WPAR="$1";ACTION="$2}')

lswpar ${WPAR} >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo WPAR ${WPAR} is not defined here. Exiting.
	exit 1
fi

function set_network
{
set -x
	case $(uname -m) in
		#DCA
		00F71FDABCDE)
			case ${WPAR} in
				email01)
					IP=10.0.0.1
				;;
				email02)
					IP=10.0.0.2
				;;
			esac
		;;
		#DCB
		00F72FDABCDE)
			case ${WPAR} in
				email01)
					IP=10.1.0.1
				;;
				email02)
					IP=10.1.0.2
				;;
			esac
		;;
		*)
			echo UNKNOWN
		;;
	esac
	currentIP=$(lswpar -Ncq ${WPAR} | awk -F : '$2=="'${SERVICE_INTERFACE}'" {print $3}')
	if [ "${currentIP}" != "${IP}" ]; then
		for cIP in ${currentIP}; do
			chwpar -N -K address=${cIP} ${WPAR}
		done
		chwpar -N interface=${SERVICE_INTERFACE} address=${IP} netmask=${SERVICE_NETMASK} ${WPAR}
	fi
}

case ${ACTION:-NONE} in
	start)
		set_network
		startwpar -v ${WPAR}
	;;
	stop)
		stopwpar -F -N ${WPAR}
	;;
	mon)
		[ "$(lswpar -c -q ${WPAR} | cut -d : -f2)" == "A" ] || exit 1
		WPARIP=$(lswpar -q -c -N ${WPAR} | grep 172.25 | cut -d : -f3)
		ping -c1 -w1 ${WPARIP} >/dev/null 2>&1 || exit 1
		[ $(ps -ef -@ ${WPAR} | grep -c imap) -eq 0 ] && exit 1
		[ $(ps -ef -@ ${WPAR} | grep -c qmail-smtpd) -eq 0 ] && exit 1
		[ $(ps -ef -@ ${WPAR} | grep -c qmail-send) -eq 0 ] && exit 1
	;;
	*)
		echo "Undefined operation ${ACTION}"
		exit 1
	;;
esac
exit 0

