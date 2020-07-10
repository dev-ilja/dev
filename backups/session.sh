set -x

curl -k -j -b cookies -D headers -c cookies -u Administrator:test https://localhost:8443/api/v1/configuration/connector --trace-ascii first.log -o out.txt
csrf=`sed $'s/\r$//' headers | sed -n "s/X-CSRF-Token: \(.*\)/\1/p"`
grep JSESSION cookies
grep description out.txt
curl -k -b cookies -D headers -H "X-CSRF-Token: $csrf"  https://localhost:8443/api/v1/configuration/connector --trace-ascii second.log -o out.txt
grep JSESSION cookies
grep description out.txt

