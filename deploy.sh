#!/bin/bash
apt-get -y update
apt-get -y install htop curl nginx letsencrypt inotify-tools python-pip

pip install awscli

systemctl stop nginx

add-apt-repository -y ppa:certbot/certbot
apt-get -y update
apt-get -y install certbot

# setup hostname
sudo bash -c 'echo "${domain}" > /etc/hostname && hostname -F /etc/hostname'

# install docker
# get docker gpg key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# add repository
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# update repo
apt-get update -y

# install docker
apt-get install -y docker-ce

# allow ubuntu user to use docker without sudoing
sudo groupadd docker
sudo usermod -aG docker ubuntu

# check install
docker run hello-world > /home/ubuntu/docker-status.log

# obtain certifcate
certbot certonly -d ${domain} --standalone --email ${email} --agree-tos -n

# configure nginx
unlink /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-available/${domain} <<EOF
server {
    listen 80;
    server_name ${domain};
    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }
    access_log /var/log/nginx/${domain}.access.log;
    error_log /var/log/nginx/${domain}.error.log;
}
server {
   listen 443;
   server_name ${domain};
   client_max_body_size 1024000m;
   ssl on;
   #ssl_dhparam /etc/nginx/ssl/dhparams.pem;
   ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;
   ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;
   ssl_session_timeout 5m;
   ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
   ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
   ssl_prefer_server_ciphers on;
   ssl_session_cache shared:SSL:10m;
    location / {
        proxy_set_header        Host    \$host;
        proxy_set_header        X-Real-IP       \$remote_addr;
        proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass http://127.0.0.1:9000;
    }
    access_log /var/log/nginx/${domain}.access.log;
    error_log /var/log/nginx/${domain}.error.log;
}
EOF

ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/
echo "server_tokens off;" > /etc/nginx/conf.d/hide_token.conf

systemctl restart nginx

# install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version > /home/ubuntu/docker-status.log

# docker run -p 9000:9000 minio/minio server /data
# write docker-compose
cat > /home/ubuntu/docker-compose.yml <<EOF
version: '2'

services:
  minio:
    image: minio/minio
    volumes:
      - /data:/data
    ports:
      - 9000:9000
    command: server /data
EOF

cat > /usr/local/bin/s3-minio-sync <<EOF
#!/bin/sh

inotifywait -q -e modify,move,create,delete -m --format '%w %e %f' -r /data | \
while read directory event file; do
  echo "\$${directory} \$${event} \$(date) \$${file}"
  #echo "should sync \$${directory}\$${file} to s3://${bucket}/\$${directory#/data/}\$${file}"
  aws s3 sync \$${directory} s3://${bucket}/\$${directory#/data/}
done
EOF
chmod +x /usr/local/bin/s3-minio-sync

cat > /etc/systemd/system/s3sync.service <<EOF
[Unit]
Description=S3 - Minio synchronization

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/tmp
Environment=PATH=/bin:/usr/bin:/usr/local/bin:/home/ubuntu/.local/bin
ExecStart=/usr/local/bin/s3-minio-sync
Restart=on-failure
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

service s3sync restart

chown ubuntu. -R /home/ubuntu
# su -c "cd /home/ubuntu && docker-compose up -d" ubuntu
