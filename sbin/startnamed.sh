#!/bin/sh
# +-----------------------------------------------------------------------+
# |       Author: Cheng Wenfeng   <277546922@qq.com>                      |
# +-----------------------------------------------------------------------+
#
wkdir=$(cd $(dirname $0); pwd)
if [ ! -f $wkdir/main.py ] ;then
   wkdir=$(cd $(dirname $0)/../; pwd)
fi
PATH=$PATH:$wkdir/sbin
confdir="$wkdir/plugins/named"
pidfile="$wkdir/plugins/named/run/named.pid"

which named-sdb >/dev/null 2>&1
if [ $? -eq 0 ] ;then
   binname="named-sdb"
   binpath=$(which named-sdb)
else
   binname="named"
   binpath=$(which named)
fi

# clear core.*
rm -rf $confdir/run/core.* >/dev/null 2>&1

case "$1" in
  start)
        echo -en "Starting DNSServer:\t\t"
        mkdir -p $confdir/log $confdir/run >/dev/null 2>&1
        $(which named-checkconf) $confdir/named.conf || (echo "check conf err" ; exit 1)
        $wkdir/sbin/start-stop-daemon --start --background -m --pidfile $pidfile --exec $binpath -- -n 1 -c $confdir/named.conf
        RETVAL=$?
        #echo
        if [ $RETVAL -eq 0 ] ;then
           echo "Done..."
        else
           echo "Failed"
        fi
        ;;
  stop)
        echo -en "Stoping DNSServer:\t\t"
        #killall $binIIpath
        $wkdir/sbin/start-stop-daemon --stop  --name $binname >/dev/null 2>&1
        RETVAL=$?
        if [ -f $pidfile ];then
           kill -9 $(cat $pidfile) >/dev/null 2>&1
        fi
        if [ $RETVAL -eq 0 ] ;then
           echo "Done..."
        else
           echo "Failed"
        fi
        ;;
  status)
        for pid in  $( ps ax|grep named |grep -v 'grep'|awk '{print $1}');do
            echo $pid
        done
        ;;
  restart)
        $0 stop
        $0 start
        RETVAL=$?
        ;;
  *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 2
esac
