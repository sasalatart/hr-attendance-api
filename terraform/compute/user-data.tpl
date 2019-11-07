#! /bin/bash

sudo yum update -y
sudo dd if=/dev/zero of=/var/swapfile bs=1M count=1024
sudo mkswap /var/swapfile
sudo swapon /var/swapfile
sudo echo "/var/swapfile swap swap defaults 0 0" >> /etc/fstab
yum install -y docker
sudo usermod -aG docker ec2-user
service docker start
echo "${docker_password}" | docker login -u "${docker_username}" --password-stdin
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
