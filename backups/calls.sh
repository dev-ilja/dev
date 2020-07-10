if [ -z $1 ]; then
   target=localhost:8443
else
   target=$1
fi 
echo "Target is $target"

echo "set password"
curl -i -k -H 'Content-Type: application/json' -d '{"oldPassword"="manage", "newPassword"="test"}'  -u Administrator:manage -X PUT https://$target/api/v1/configuration/connector/authentication/basic

echo "set role"
curl -i -k -H 'Content-Type: application/json' -d '"master"'  -u Administrator:test -X POST https://$target/api/v1/configuration/connector/haRole

echo "get"
curl -i -k -u Administrator:test https://$target/api/v1/configuration/connector

echo "set ha enabled"
curl -i -k -H 'Content-Type: application/json' -d '{"haEnabled":true}'  -u Administrator:test -X PUT https://$target/api/v1/configuration/connector/ha/master

echo "upload backup"
curl -i -k -u Administrator:test https://$target/api/v1/configuration/backup  -X PUT -F password=test -F backup=@scc_backup.2.12.4.zip --trace-ascii log.txt

curl -i -k -u Administrator:test https://localhost:8443/api/v1/configuration/connector -X PUT  -H 'Content-Type: application/json' -d '{"description":"set by rest"}'


curl -k -u Administrator:test https://localhost:8443/api/v1/configuration/backup -X POST -H 'Content-Type: application/json' -d '{"password":"test"}' -o backup.2.12.3.test.zip
