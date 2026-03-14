#!/bin/bash
# This script runs automatically when an EC2 instance boots
# It installs everything needed to run the Flask app

# Update the OS
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip

# Install Flask and dependencies
pip3 install flask mysql-connector-python requests

# Create the app directory
mkdir -p /home/ec2-user/app

# Write the Flask app to the instance
cat > /home/ec2-user/app/app.py << 'APPEOF'
$(cat app/app.py)
APPEOF

# Set environment variables for the Flask app
# These are injected by Terraform via the launch template
cat > /etc/environment << EOF
DB_HOST=${db_host}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
OPENWEATHER_API_KEY=${api_key}
EOF

# Load environment variables
source /etc/environment

# Create a systemd service so Flask starts automatically on reboot
cat > /etc/systemd/system/zamweather.service << EOF
[Unit]
Description=ZamWeather Flask App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app
EnvironmentFile=/etc/environment
ExecStart=/usr/bin/python3 /home/ec2-user/app/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable zamweather
systemctl start zamweather
