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
         restore)
             op="restore"
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
        -p)
            if [ "$2" ]; then
                 pass=$2
                 echo "Use backup file pass $pass"
                 shift
             else
                 echo "Error: no value in target"
                 exit 1
             fi
             ;;         
        *)
             break;
      esac
      shift
done

if [ -z "$op" ]; then
	echo "Usage: ./backup.sh create|restore -f backupfile -p pass -t target"
	exit 1
fi

if [ -z "$file" ]; then
	echo "use backup.zip" 
	file="backup.zip"
fi

if [ -z "$pass" ]; then
	echo "use test as password for backup file" 
	pass="test"
fi

if [ -z "$target" ]; then
   target=localhost:8443
fi

echo "Target is $target, backup file name is $file"

auth="Administrator:test"


if [[ $op == "create" ]]; then
    echo ">>> create backup from $target, file $file, password $pass"
    curl -k -u $auth https://$target/api/v1/configuration/backup -X POST -H 'Content-Type: application/json' -d "{\"password\":\"$pass\"}" -o $file
    ls -al $file
fi

if [[ $op == "restore" ]]; then
	curl -i -k -c cookie -D headers -u $auth https://$target/api/v1/configuration/connector
	echo ""
    sed $'s/\r$//' headers > headers.unix
    csrf=`sed -n "s/X-CSRF-Token: \(.*\)/\1/p" headers.unix`
	
    echo ">>> restore backup on $target, file $file, password $pass, csrf $csrf"
    curl -i -k -b cookie -c cookie https://$target/api/v1/configuration/backup -H "X-CSRF-Token: $csrf" -X PUT -F 'password=$pass' -F backup=@$file --trace-ascii restore.log

#    echo " curl -i -k -u $auth https://$target/api/v1/configuration/backup -X PUT -F 'password=$pass' -F backup=@$file"
#    curl -i -k -b cookie -c cookie -u $auth https://$target/api/v1/configuration/backup -X PUT -F 'password=$pass' -F backup=@$file --trace-ascii restore.log
fi


