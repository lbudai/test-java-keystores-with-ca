# generate Java keystore files

## setup CA
 * openssl configuration is in `config/config.cnf`
 * certificate parameters are in `config/ca_config_options.cfg`
 * `./setup_ca.sh`

## generate server certificate signed by CA
 * configuration is in `config/server_config_options.cfg`
 * `./setup_java_server_certs.sh`

## generate client certificate signed by CA
 * configuration is in `config/client_config_options.cfg`
 * `./setup_java_client_certs.sh`


`certs` directory will contain the generated certificates.
