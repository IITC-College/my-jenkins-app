#!/bin/bash
set -e

echo "=== Updating system ==="
dnf update -y

echo "=== Installing required tools ==="
dnf install -y git wget curl unzip

#######################################
# Install Docker
#######################################
echo "=== Installing Docker ==="
dnf install -y docker

systemctl enable docker
systemctl start docker

echo "=== Adding ec2-user & jenkins to docker group ==="
usermod -aG docker ec2-user

#######################################
# Install Java 17 (safe for Jenkins)
#######################################
echo "=== Installing Java 17 ==="
dnf install -y java-17-amazon-corretto

#######################################
# Install Jenkins + Repo Setup
#######################################
echo "=== Adding Jenkins Repo ==="
curl -fsSL https://pkg.jenkins.io/redhat-stable/jenkins.io.key | tee /etc/pki/rpm-gpg/RPM-GPG-KEY-jenkins
curl -fsSL https://pkg.jenkins.io/redhat-stable/jenkins.repo | tee /etc/yum.repos.d/jenkins.repo

echo "=== Installing Jenkins ==="
dnf install -y jenkins

systemctl enable jenkins
systemctl start jenkins

#######################################
# Fix Docker socket permissions for Jenkins
#######################################
echo "=== Fixing Docker socket permissions ==="
chmod 666 /var/run/docker.sock || true
usermod -aG docker jenkins

#######################################
# Cleanup Docker garbage automatically
#######################################
echo "=== Configuring daily Docker autoremove ==="
/bin/cat <<EOM > /etc/cron.daily/docker-clean
#!/bin/bash
docker system prune -af --volumes >/dev/null 2>&1
EOM
chmod +x /etc/cron.daily/docker-clean

#######################################
# Optional: Install Node.js (LTS)
#######################################
echo "=== Installing Node 20 LTS ==="
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs

#######################################
# Grow filesystem (AL2023 auto-expands on reboot)
#######################################
echo "=== Expanding filesystem ==="
growpart /dev/nvme0n1 4 || true
xfs_growfs -d / || true

#######################################
# Final reboot
#######################################
echo "=== Setup complete. Rebooting... ==="
reboot
