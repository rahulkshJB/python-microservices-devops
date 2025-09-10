#!/bin/bash
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create a docker-compose file [cite: 82]
cat <<EOF > /home/ec2-user/docker-compose.yml
services:
  backend:
    image: pavansyadav/python-backend:latest
    ports: ["5000:5000"]
    environment:
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=password123
      - POSTGRES_DB=app_db
    depends_on: [db, logger]
  frontend:
    image: pavansyadav/python-frontend:latest
    ports: ["8080:80"]
    depends_on: [backend]
  logger:
    image: pavansyadav/python-logger:latest
    ports: ["5002:5002"]
  db:
    image: postgres:13
    environment:
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=password123
      - POSTGRES_DB=app_db
    volumes:
      - postgres_data:/var/lib/postgresql/data/
volumes:
  postgres_data:
EOF

# Run docker-compose [cite: 82]
cd /home/ec2-user
sudo /usr/local/bin/docker-compose up -d