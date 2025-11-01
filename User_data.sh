#!/bin/bash
# ====== Update System ======
sudo apt update -y
sudo apt upgrade -y

# ====== Install Java & Maven ======
sudo apt install -y openjdk-21-jdk maven git

# ====== Clone Your GitHub Repo ======
cd /home/ubuntu
git clone https://github.com/Trainings-TechEazy/test-repo-for-devops.git
cd test-repo-for-devops

# ====== Build the Spring Boot Application ======
mvn clean package -DskipTests

# ====== Create Systemd Service File ======
sudo bash -c 'cat > /etc/systemd/system/app.service <<EOF
[Unit]
Description=Spring Boot App
After=network.target

[Service]
User=ubuntu
ExecStart=/usr/bin/java -jar /home/ubuntu/test-repo-for-devops/target/hellomvc-0.0.1-SNAPSHOT.jar
SuccessExitStatus=143
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF'

# ====== Change Permissions ======
sudo chmod 644 /etc/systemd/system/app.service

# ====== Enable Non-root to Use Port 80 ======
sudo setcap 'cap_net_bind_service=+ep' /usr/lib/jvm/java-21-openjdk-amd64/bin/java

# ====== Reload Daemon and Start App ======
sudo systemctl daemon-reload
sudo systemctl enable app
sudo systemctl start app

# ====== Wait and Verify ======
sleep 10
curl localhost:80/hello || echo "Application deployed, verify via browser"