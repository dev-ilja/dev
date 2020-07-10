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
         selfsigned)
             op="selfsigned"
             ;;
         csr)
             op="csr"
             ;;
         signedcsr)
             op="signedcsr"
             ;;
        -f|--file)
            if [ "$2" ]; then
                 file=$2
                 echo "Use backup file name $file"
                 shift
             else
                 echo "Error: no value in target"
                 exit 1
             fi
             ;;         
        -s|--subject)
            if [ "$2" ]; then
                 subjectDN=$2
                 echo "Use subject $subjectDN"
                 shift
             else
                 echo "Error: no value in $subjectDN"
                 exit 1
             fi
             ;;         
        *)
             break;
      esac
      shift
done

if [ -z "$op" ]; then
	echo "Usage: ./certui.sh selfsigned|csr|signedcsr -f signedcsrfile -t target"
	exit 1
fi

if [ -z "$subjectDN" ]; then
    subjectDN='CN=selfsigned,O=shell'
	echo "Use $subjectDN as subject"
fi

if [ -z "$target" ]; then
   target=localhost:8443
fi

echo "Target is $target, file name is $file, subject is $subjectDN"

auth="Administrator:test"


if [[ $op == "selfsigned" ]]; then
echo ">>> create selfsigned"
curl -i -k -u $auth https://$target/api/v1/configuration/connector/ui/uiCertificate -X POST -H 'Content-Type: application/json' -d '{"type":"selfsigned", "subjectDN":"'$subjectDN'"}'
fi