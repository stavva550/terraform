#!/bin/bash

dnf update -y
dnf install -y httpd

systemctl enable httpd
systemctl start httpd

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4)

PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Amazon Linux 2023</title>
</head>
<body>
    <h1>Welcome to Linux</h1>
    <h2>Apache is running on Amazon Linux 2023</h2>
    <p><strong>Private IP:</strong> $PRIVATE_IP</p>
    <p><strong>Public IP:</strong> $PUBLIC_IP</p>
</body>
</html>
EOF