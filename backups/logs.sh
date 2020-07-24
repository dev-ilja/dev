#!/bin/sh
#set -x


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

rm cookies
curl -k -s -D headers -b cookies -c cookies https://$target > /dev/null
curl -k -s -D headers -b cookies -c cookies -L https://$target/j_security_check -d 'j_username=Administrator' -d 'j_password=test' > /dev/null

csrf=`sed $'s/\r$//' headers | sed -n "s/X-CSRF-Token: \(.*\)/\1/p"`
#echo "using $csrf"

printf "set log "
curl -k -b cookies -D headers -H "X-CSRF-Token: $csrf" https://$target/logAndTrace -X POST -d "action=setLogSettings" -d "sccLogLevel=$level" -d "otherLogLevel"="3" -d 'cpicTraceLevel=0' -d 'payloadTrace=false'
printf "\nset ssl "
curl -k -b cookies -D headers -H "X-CSRF-Token: $csrf" https://$target/admin -X POST -d "action=modifyPropsIni" -d "sslTrace=$tls"
printf "\n"