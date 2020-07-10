#!/bin/sh
set -x


while :; do
    case $1 in
        -t|--target)
            if [ "$2" ]; then
                 target=$2
                 echo "Use target $target"
                 shift
             else
                 echo "Error: no value in target"
                 exit 1
             fi
             ;;
         tls|TLS)
             tls="true"
             ;;
         debug)
             level="5"
             ;;
         info)
             level="3"
             ;;
         *)
             break;
      esac
      shift
done


if [ -z "$target" ]; then
   target=localhost:8443
fi

if [ -z "$level" ]; then
	level="3"
fi

if [ -z "$tls" ]; then
	tls="false"
fi

echo "set log to $level on $target with TLS $tls"

auth="Administrator:test"


curl -i -k -u Administrator:test https://$target/logAndTrace -X POST -F "action=setLogSettings" -F "sccLogLevel=$level" -F "therLogLevel"="3" -F 'cpicTraceLevel=0' -F 'payloadTrace=false'
curl -i -k -u Administrator:test https://$target/admin -X POST -F "action=modifyPropsIni" -F "sslTrace=$tls"
