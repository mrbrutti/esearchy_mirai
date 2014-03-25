# remove old certs in case the exists.
rm ../certs/drone_server_ssl.crt
rm ../certs/drone_server_ssl.key

# Generate private key
openssl genrsa -des3 -out drone_server.key 2048
# Generate CSR
openssl req -new -key drone_server.key -out drone_server.csr
# If you do not want to write your secret every time delete passphrase. 
cp drone_server.key drone_server.key.org
openssl rsa -in drone_server.key.org -out drone_server.key

# Generate Self-signed Certificate. 
openssl x509 -req -days 365 -in drone_server.csr -signkey drone_server.key -out drone_server.crt

# Move certs to cert directory.
mv drone_server.crt ../certs/drone_server_ssl.crt
mv drone_server.key ../certs/drone_server_ssl.key