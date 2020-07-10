keytool -genkeypair -keyalg RSA -keysize 4096 -alias mykey -dname "cn=Self Hugo, o=shell script, c=mac" -validity 365 -keystore selfhugo.p12 -keypass test123 -storepass test123 -storetype pkcs12 -v
