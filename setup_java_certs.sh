#!/bin/bash

set -e
set -x

START_DIR=$PWD
WDIR=$START_DIR/certs
CADIR=$WDIR/ca

function create_cert {
  keytool -genkey                   \
          -alias $ALIAS             \
          -keystore $ALIAS.jks      \
          -storepass $PASSWORD      \
          -keypass $PASSWORD        \
          -keyalg RSA               \
          -keysize $KEYSIZE         \
          -validity $VALIDITY       \
          -ext san=dns:$HOST,ip:$IP \
          -dname "CN=${CN}, OU=${ORG_UNIT}, L=${LOCALITY}, S=${STATE}, C=${COUNTRY}" 
}

function request_sign {
  keytool -certreq                  \
          -alias $ALIAS             \
          -keystore $ALIAS.jks      \
          -keyalg RSA               \
          -file $ALIAS.csr          \
          -ext san=dns:$HOST,ip:$IP \
          -storepass $PASSWORD
}

function sign {
  echo 'y' > sign_response.txt
  echo 'y' >> sign_response.txt
  < sign_response.txt openssl ca -in $ALIAS.csr -notext -out $ALIAS-signed.crt -config $CADIR/conf/caconfig.cnf -extensions v3_req -passin pass:$PASSWORD 
  rm sign_response.txt
  rm $ALIAS.csr
}

function import_ca_cert_into_keystore {
  openssl x509 -in $CADIR/certs/cacert.pem -out cacert-noheaders.pem
  
  echo 'yes' > import_response.txt

  < import_response.txt         \
    keytool -import             \
          -keystore $ALIAS.jks  \
          -storepass $PASSWORD  \
          -alias myca           \
          -trustcacerts         \
          -file cacert-noheaders.pem

  rm import_response.txt
  rm cacert-noheaders.pem
}

function import_signed_cert_into_keystore {
  openssl x509 -in $ALIAS-signed.crt -out $ALIAS-signed-noheaders.crt
  
  echo 'yes' > import_response.txt

  < import_response.txt         \
    keytool -importcert         \
          -keystore $ALIAS.jks  \
          -storepass $PASSWORD  \
          -alias $ALIAS         \
          -file $ALIAS-signed.crt
  
  rm import_response.txt
  rm $ALIAS-signed-noheaders.crt
}

function main {
  cd $WDIR
  mkdir -p $TARGET_DIR
  cd $TARGET_DIR
  create_cert
  request_sign
  sign
  import_ca_cert_into_keystore
  import_signed_cert_into_keystore
  cd $START_DIR
}

main
