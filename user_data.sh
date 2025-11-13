#!/bin/bash
set -xe

# Update OS packages
yum update -y

# Install Java 17 (Amazon Corretto) and awscli
yum install -y java-17-amazon-corretto-headless unzip awscli

# Create app directory
mkdir -p /opt/app
cd /opt/app

# Download the jar from S3 (explicit region is not needed if role has permissions)
aws s3 cp s3://${artifact_bucket}/app.jar /opt/app/app.jar --region ${aws_region}

# If download failed, exit (makes debugging visible in cloud-init logs)
if [ ! -f /opt/app/app.jar ]; then
  echo "ERROR: app.jar not found after download" >> /var/log/user-data-error.log
  exit 1
fi

chmod 755 /opt/app/app.jar

# Create a systemd service for the app
cat <<'SERVICE' > /etc/systemd/system/app.service
[Unit]
Description=Spring Boot Application
After=network.target

[Service]
User=root
ExecStart=/usr/bin/java -jar /opt/app/app.jar
Restart=always
RestartSec=5
StandardOutput=append:/opt/app/app.log
StandardError=append:/opt/app/app.log

[Install]
WantedBy=multi-user.target
SERVICE

# Start service
systemctl daemon-reload
systemctl enable app
systemctl start app

# Create log sync script to sync logs to S3
cat <<'EOF' > /opt/app/sync-logs.sh
#!/bin/bash
aws s3 sync /opt/app s3://${logs_bucket}/$(hostname)/ --region ${aws_region}
EOF

chmod +x /opt/app/sync-logs.sh

# Add cron job to sync logs every 2 minutes
(crontab -l 2>/dev/null; echo "*/2 * * * * /opt/app/sync-logs.sh") | crontab -
