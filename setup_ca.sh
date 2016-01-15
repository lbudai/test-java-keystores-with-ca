#!/bin/bash

set -e
set -x

source config/ca_config_options.cfg

start_dir=$PWD
WDIR=$start_dir/certs
CADIR=$WDIR/ca

function setup_ca_env {
  mkdir -p $CADIR/private $CADIR/certs $CADIR/conf
  cp config/config.cnf $CADIR/conf/caconfig.cnf
  eval "sed -e s@TEMPLATE_DIR@${CADIR}@g config/config.cnf > $CADIR/conf/caconfig.cnf"
  echo '01' > $CADIR/serial
  touch $CADIR/index.txt
}

function create_ca_cert {
  openssl req -new -x509 -extensions v3_ca      \
  -newkey rsa:$KEYSIZE                          \
  -keyout $CADIR/private/cakey.pem              \
  -out $CADIR/certs/cacert.pem                  \
  -days $VALIDITY                               \
  -config $CADIR/conf/caconfig.cnf              \
  -passout pass:$PASSWORD                       \
  -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORG/OU=$ORG_UNIT/CN=$CN/emailAddress=$MAIL"
}

function main {
  setup_ca_env
  create_ca_cert
}

main
