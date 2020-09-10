# This is a custom Nagios plugin I have written to read a file with an IP Adress in it's name (Ex: $logloc/192.168.1.100.ok) and based on the timestamp of the file decide if the correspondig host (192.168.1.100) is up and running.
# This was written as a part of a project that intergrates a python script / MQTT / and nodered.
# For more info visit my blog at www.chindemax.com
 
#!/bin/bash
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

usage1="Usage: $0 -L <log_location> -I <ip_address> -w <warn_if_no_ping_in_last_mins> -c <critical_if_no_ping_in_last_mins>"
exitstatus=$STATE_WARNING #default
while test -n "$1"; do
    case "$1" in
        -c)
            crit=$2
            shift
            ;;
        -w)
            warn=$2
            shift
            ;;
        -I)
            ipaddr=$2
            shift
            ;;
        -L)
            logloc=$2
            shift
            ;;
        -h)
            echo $usage1;
            echo
            exit $STATE_UNKNOWN
            ;;
        *)
            echo "Unknown argument: $1"
            echo $usage1;
            echo
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

if [ $(find $logloc/$ipaddr.ok -mmin -$warn | wc -l) -gt 0 ]; then
        echo "$ipaddr - OK (signaled within $warn mins)"
        exit $STATE_OK
fi

if [ $(find $logloc/$ipaddr.ok -mmin -$crit | wc -l) -gt 0 ]; then
        echo "$ipaddr - WARNING (signaled within $crit mins)"
        exit $STATE_WARNING
fi

echo "$ipaddr - CRITICAL (no signal within $crit mins)"
exit $STATE_CRITICAL
