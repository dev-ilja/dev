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
         sys)
             type="systemCertificate"
             ;;
         ppca)
             type="ppCaCertificate"
             ;;
         *)
             break;
      esac
      shift
done


echo "type is $type"
if [ -z "$type" ]; then
	echo "use sys|ppca " 
	exit 1
fi

echo "run script for $type"

if [ -z "$target" ]; then
   target=localhost:8443
fi

echo "Target is $target"

auth="Administrator:test"

echo ">>> get $type"
curl -i -k -u $auth https://$target/api/v1/configuration/connector/onPremise/$type -H 'Accept: application/json'

echo ">>> create selfsigned $type"
curl -i -k -u $auth https://$target/api/v1/configuration/connector/onPremise/$type -X POST -H 'Content-Type: application/json' -d '{"type":"selfsigned", "subjectDN":"CN=selfsigned"}'

echo ">>> get $type"
curl -i -k -u $auth https://$target/api/v1/configuration/connector/onPremise/$type -H 'Accept: application/json'

echo ">>> delete $type"
curl -i -k -u $auth https://$target/api/v1/configuration/connector/onPremise/$type -X DELETE

echo ">>> get $type"
curl -i -k -u $auth https://$target/api/v1/configuration/connector/onPremise/$type -H 'Accept: application/json'

echo "\n>>> upload $type"
curl -i -k -u $auth https://$target/api/v1/configuration/connector/onPremise/$type -X PUT -F 'password=test123' -F pkcs12=@selfhugo.p12

echo ">>> get $type"
curl -i -k -u $auth https://$target/api/v1/configuration/connector/onPremise/$type -H 'Accept: application/json'

echo ">>> delete $type"
curl -i -k -u $auth https://$target/api/v1/configuration/connector/onPremise/$type -X DELETE

echo ">>>crearte csr $type"
curl -k -u $auth https://$target/api/v1/configuration/connector/onPremise/$type -X POST -H 'Content-Type: application/json' -d '{"type":"csr", "subjectDN":"CN=csr,O=shell"}' -o csr.pem

if [ -z "ca.ks" ]; then
	keytool -genkeypair -keyalg RSA -keysize 1024 -alias mykey -dname "cn=very trusted, o=shell script, c=mac" -validity 365 -keystore ca.ks -keypass testit -storepass testit
fi

keytool -gencert -rfc -infile csr.pem -outfile signedcsr.pem -alias mykey -keystore ca.ks -keypass testit -storepass testit
keytool -exportcert -rfc -file ca.pem -alias mykey -keystore ca.ks -keypass testit -storepass testit
cat signedcsr.pem ca.pem > signedchain.pem

curl -i -k -u $auth https://$target/api/v1/configuration/connector/onPremise/$type -X PATCH -F signedCertificate=@signedcsr.pem -F caCertificateChain=@ca.pem




