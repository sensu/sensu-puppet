Certificates used for testing Sensu Go with SSL

```
vagrant up sensu-backend
vagrant ssh sensu-backend
sudo su -
cp /vagrant/tests/ssl/openssl.cnf /etc/pki/tls/
openssl req -newkey rsa:2048 -nodes -keyout /root/ssl/ca_key.pem -x509 -days 365 -out /root/ssl/ca.pem -subj "/CN=localhost"
cp /root/ssl/ca_key.pem /etc/pki/CA/private/cakey.pem
cp /root/ssl/ca.pem /etc/pki/CA/cacert.pem
touch /etc/pki/CA/index.txt
cp /root/ssl/ca.srl /etc/pki/CA/serial
openssl req -newkey rsa:2048 -nodes -keyout /root/ssl/key.pem -out /root/ssl/localhost.csr -subj "/CN=localhost"
openssl ca -policy policy_anything -out /root/ssl/cert.pem -config /etc/pki/tls/openssl.cnf -extensions v3_req -infiles /root/ssl/localhost.csr
cp /root/ssl/* /vagrant/tests/ssl/
```
