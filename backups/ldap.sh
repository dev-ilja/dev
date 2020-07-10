#!/bin/sh


if [ -z $1 ]; then
   target=localhost:8443
else
   target=$1
fi
echo "Target is $target"


echo "--- set ldap "
curl -i -k -H 'Content-Type: application/json' -u Administrator:test -X PUT https://$target/api/v1/configuration/connector/authentication/ldap \
 -d '{"enable":true, "configuration":{"hosts":[{"host":"wdflbmd15468", "port":"10389", "isSecure":false}], "config":"roleBase=\"ou=groups,dc=scc\" roleName=\"cn\" roleSearch=\"(uniqueMember={0})\" userBase=\"ou=users,dc=scc\" userSearch=\"(uid={0})\"", "user":"uid=admin,ou=system", "password":"test"}}'
echo ""

echo "disable LDAP with "
curl -i -k -H 'Content-Type: application/json' -u sccadmin:test -X PUT https://$target/api/v1/configuration/connector/authentication/ldap -d '{"enable":false}'
