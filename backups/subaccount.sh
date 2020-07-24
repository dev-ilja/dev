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
         create)
             op="create"
             ;;
         remove)
             op="remove"
             ;;
        -sa|--subaccount)
            if [ "$2" ]; then
                 sa=$2
                 echo "subaccount $sa"
                 shift
             else
                 echo "Error: no value for subaccount"
                 exit 1
             fi
             ;;         
        *)
             break;
      esac
      shift
done

if [ -z "$sa" ]; then
	echo "Usage: ./subaccount.sh create|remove -sa subaccount -t target"
	exit 1
fi

if [ -z "$target" ]; then
   target=localhost:8443
fi

echo "Target is $target, subaccount name is $sa"

auth="Administrator:test"


if [[ $op == "create" ]]; then
    echo ">>> create subaccount $sa on $target"
    chost="staging.hanavlab.ondemand.com"
    csa="dfrvy56720"
    cu="P1942921378"
    cp="Welcome2017"
    dn="staging"
    
    curl -k -D headers -u $auth https://$target/api/v1/configuration/subaccounts -X POST \
        -H 'Accept: application/json'  -H 'Content-Type: application/json' \
        -d '{"regionHost":"'$chost'", "subaccount": "'$csa'", "cloudUser":"'$cu'", "cloudPassword":"'$cp'", "displayName":"'$dn'"}'
    echo ""    
    grep "HTTP" headers
    grep "Location" headers
fi

if [[ $op == "remove" ]]; then
    echo ">>> remove subaccount $sa on $target"
    chost="staging.hanavlab.ondemand.com"
    csa="dfrvy56720"
    curl -k -D headers -u $auth https://$target/api/v1/configuration/subaccounts/$chost/$csa -X DELETE
    echo ""    
    grep "HTTP" headers
    curl -k  -D headers -u $auth https://$target/api/v1/configuration/subaccounts/$chost/$csa -X GET -H 'Accept: application/json'
    echo ""    
    grep "HTTP" headers
    
fi