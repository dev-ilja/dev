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
         master)
             type="master"
             ;;
         shadow)
             type="shadow"
             ;;
         *)
             break;
      esac
      shift
done

if [ -z "$type" ]; then
   echo "./init.sh -t localhost:7443 master|shadow"
   exit 1
fi

echo "run script for $type"

if [ -z "$target" ]; then
	if [ $type = "master" ]; then   
		target="localhost:8443"
	else
		target="localhost:7443"
	fi
fi

echo "Target is $target"

auth="Administrator:test"



echo "--- set password"
curl -i -k -H 'Content-Type: application/json' -d '{"oldPassword"="manage", "newPassword"="test"}'  -u Administrator:manage -X PUT https://$target/api/v1/configuration/connector/authentication/basic

echo "--- set role $type"
curl -i -k -H 'Content-Type: application/json' -d "\"$type\""  -u $auth -X POST https://$target/api/v1/configuration/connector/haRole

echo "--- get connector"
curl -i -k -u $auth https://$target/api/v1/configuration/connector
echo ""

if [[ $type = "master" ]]; then

echo "--- set ha enabled"
curl -i -k -H 'Content-Type: application/json' -d '{"haEnabled":true}'  -u $auth -X PUT https://$target/api/v1/configuration/connector/ha/master/config
echo ""

else

curl -i -k -u $auth -X PUT https://$target/api/v1/configuration/connector/ha/shadow/config -H 'Content-Type: application/json' -d '{"masterHost":"localhost", "masterPort":"8443", "ownHost":"localhost", "checkIntervalInSeconds":30, "takeoverDelayInSeconds":10, "connectTimeoutInMillis":1000, "requestTimeoutInMillis":12000}'

fi

