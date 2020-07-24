#!/bin/sh
set -x

if [ $# -eq 0 ]; then
	echo "Usage: ./shadow connect|disconnect|wipe|conf|info -t target"
	exit 1
fi

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
         connect)
             connect=1
             ;;
         disconnect)
             disconnect=1
             ;;
         wipe)
             wipe=1
             ;;
         conf)
             conf=1
             ;;
         state)
             state=1
             ;;
        *)
             break;
      esac
      shift
done

if [ -z "$target" ]; then
   target=localhost:7443
fi

echo "Target is $target, subaccount name is $sa"

auth="Administrator:test"


if [[ "$connect" == "1" ]]; then
    echo ">>> connect on $target"
    
    curl -k -D headers -u $auth https://$target/api/v1/configuration/connector/ha/shadow/state -X POST \
        -H 'Content-Type: application/json' \
        -d '{"op":"CONNECT", "user": "Administrator", "password":"test"}'
    echo ""    
    grep "HTTP" headers
    grep "Location" headers
fi

if [[ "$disconnect" == "1" ]]; then
    echo ">>> disconnect on $target"
    
    curl -k -D headers -u $auth https://$target/api/v1/configuration/connector/ha/shadow/state -X POST \
        -H 'Content-Type: application/json' \
        -d '{"op":"DISCONNECT"}'
    echo ""    
    grep "HTTP" headers
    grep "Location" headers

    curl -k -u $auth https://$target/api/v1/configuration/ha/shadow/state -X GET \
        -H 'Accept: application/json' 
fi

if [[ "$wipe" == "1" ]]; then
    echo ">>> wipe state & config on $target"
    
    curl -k -D headers -u $auth https://$target/api/v1/configuration/connector/ha/shadow/state -X DELETE \
        -H 'Content-Type: application/json' 
    echo ""    
    grep "HTTP" headers
    grep "Location" headers
    
    curl -k -u $auth https://$target/api/v1/configuration/connector/ha/shadow/config -X GET \
        -H 'Accept: application/json' 
fi

if [[ "$conf" == "1" ]]; then
    echo ">>> config on $target"
    
    curl -k -D headers -u $auth https://$target/api/v1/configuration/connector/ha/shadow/config -X PUT \
        -H 'Content-Type: application/json'  -H 'Accept: application/json' \
        -d '{"masterHost":"localhost", "masterPort": "8443", "checkIntervalInSeconds":10, "takeoverDelayInSeconds":10}'
    echo ""    
    grep "HTTP" headers
    grep "Location" headers

    curl -k -u $auth https://$target/api/v1/configuration/connector/ha/shadow/config -X GET \
        -H 'Accept: application/json' 
fi

if [[ "$state" == "1" ]]; then
    curl -k -u $auth https://$target/api/v1/configuration/connector/ha/shadow/state -X GET \
        -H 'Accept: application/json' 
fi
