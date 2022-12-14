#!/bin/sh
# USE OPENSSL VERSION 1.1.1
# IT MIGHT NOT WORK WITH OPENSSL VERSION 3

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <collector FQDN> <device FQDN>"
    exit 1
fi

(
cat <<EOF
[req]
distinguished_name = req_distinguished_name
prompt = no
[req_distinguished_name]
C = US
ST = California
L = San Jose
O = Cisco
OU = MDT
CN = cisco.com
EOF
) > ca.cnf

openssl genrsa -out ${1}-ca.key > /dev/null 2>&1
openssl req -x509 -new -nodes -key ${1}-ca.key -days 365 -out ${1}-ca.crt -config ca.cnf > /dev/null 2>&1

openssl genrsa -out ${2}-ca.key > /dev/null 2>&1
openssl req -x509 -new -nodes -key ${2}-ca.key -days 365 -out ${2}-ca.crt -config ca.cnf > /dev/null 2>&1

rm ca.cnf

(
cat <<EOF
[req]
distinguished_name = req_distinguished_name
prompt = no
req_extensions = v3_req

[req_distinguished_name]
C = US
ST = California
L = San Jose
O = Cisco
OU = MDT
CN = ${1}

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${1}
EOF
) > ${1}.cnf

openssl genrsa -out ${1}.key > /dev/null 2>&1
openssl req -new -key ${1}.key -out ${1}.csr -config ${1}.cnf
openssl x509 -req -in ${1}.csr -CA ${1}-ca.crt -CAkey ${1}-ca.key -CAcreateserial -out ${1}.crt > /dev/null 2>&1

rm ${1}.cnf

(
cat <<EOF
[req]
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
C = CA
ST = Ontario
L = Ottawa
O = Cisco
OU = MDT
CN = ${2}
EOF
) > ${2}.cnf

openssl genrsa -des3 -out ${2}.key -passout pass:admin > /dev/null 2>&1
openssl req -new -key ${2}.key -out ${2}.csr -config ${2}.cnf -passin pass:admin
openssl x509 -req -in ${2}.csr -CA ${1}-ca.crt -CAkey ${1}-ca.key -CAcreateserial -out ${2}-${1}-ca.crt > /dev/null 2>&1
openssl x509 -req -in ${2}.csr -CA ${2}-ca.crt -CAkey ${2}-ca.key -CAcreateserial -out ${2}-${2}-ca.crt > /dev/null 2>&1

rm ${2}.cnf

cat <<EOF
Configure trustpoints using the following:

crypto pki import <trustpoint name 1> pem terminal password admin
 <paste contents of ${1}-ca.crt>
 <paste contents of ${2}.key>
 <paste contents of ${2}-${1}-ca.crt
crypto pki import <trustpoint name 2> pem terminal password admin
 <paste contents of ${2}-ca.crt>
 <paste contents of ${2}.key>
 <paste contents of ${2}-${2}-ca.crt>

Configure telemetry using the following:

telemetry protocol grpc profile <profile name>
 ca-trustpoint <trustpoint name 1>
 id-trustpoint <trustpoint name 2>
telemetry receiver protocol <receiver name>
 host name ${1} <collector port>
 protocol grpc-tls profile <profile name>
EOF



