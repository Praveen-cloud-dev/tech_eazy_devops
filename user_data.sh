#!/bin/bash
set -e

LOGFILE="/var/log/app-startup.log"
exec >> $LOGFILE 2>&1

echo "[INFO] Starting user data script..."

########################################
# Install dependencies
########################################
yum update -y
yum install -y java-17-amazon-corretto-headless aws-cli unzip curl amazon-cloudwatch-agent

echo "[INFO] Installed Java, AWS CLI, CloudWatch Agent."

########################################
# Create application directory
########################################
APP_DIR="/opt/app"
mkdir -p $APP_DIR
cd $APP_DIR
echo "[INFO] Created app dir at $APP_DIR"

########################################
# Download app artifact
########################################
echo "[INFO] Downloading app.jar from S3..."
if aws s3 cp s3://${artifact_bucket}/app.jar $APP_DIR/app.jar; then
    echo "[SUCCESS] app.jar downloaded."
else
    echo "[ERROR] Failed to download app.jar."
fi

########################################
# Create systemd service for Java app
########################################
echo "[INFO] Creating systemd service..."

cat <<EOF >/etc/systemd/system/app.service
[Unit]
Description=Java Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/app
ExecStart=/usr/bin/java -Dlogging.file.name=/opt/app/app.log -jar /opt/app/app.jar
Restart=on-failure
RestartSec=5
StandardOutput=append:/opt/app/app.log
StandardError=append:/opt/app/app.log

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable app.service
systemctl start app.service || echo "[ERROR] Failed to start Java app."

echo "[INFO] Java App started via systemd."

########################################
# CloudWatch Agent configuration
########################################
echo "[INFO] Configuring CloudWatch Agent..."

cat <<EOF >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "cpu": {
        "measurement": ["cpu_usage_idle"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

echo "[INFO] CloudWatch Agent started."

########################################
# Log Sync to S3 (every 2 minutes)
########################################
echo "[INFO] Creating log sync cron..."

cat <<EOF >/opt/app/sync-logs.sh
#!/bin/bash
aws s3 sync /opt/app s3://${logs_bucket}/\$(hostname)/ --exclude "*" --include "*.log"
EOF

chmod +x /opt/app/sync-logs.sh

(crontab -l 2>/dev/null; echo "*/2 * * * * /opt/app/sync-logs.sh") | crontab -

echo "[INFO] Cron job added to sync logs."

########################################
# Completed
########################################
echo "[SUCCESS] User data script completed."
