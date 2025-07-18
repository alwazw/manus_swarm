# Complete Self-Hosted Infrastructure Deployment Guide

## 🎯 **Overview**

This repository contains a comprehensive self-hosted infrastructure stack that completely replaces cloud services like OneDrive, iCloud, and Google Drive while providing enterprise-grade monitoring, security, and management capabilities.

## 🏗️ **Architecture Overview**

### **Service Categories (8 Stacks)**
1. **proxy.yml** - Traefik reverse proxy with SSL
2. **security.yml** - Authentik SSO + security tools
3. **media.yml** - Nextcloud + file sync + media services
4. **monitoring.yml** - Prometheus + Grafana + exporters
5. **logging.yml** - Loki + Promtail + log management
6. **notifications.yml** - ntfy + alert management
7. **backup.yml** - Automated backup solutions
8. **registry.yml** - Harbor container registry

### **Domain Structure**
- **Primary**: visionvation.com
- **Secondary**: wazzan.us
- **Authentication**: https://visionvation.com/login
- **Dashboard**: https://apps.visionvation.com
- **Services**: https://[service].visionvation.com

## 📁 **Directory Structure**

```
/mnt/media/
├── photos/           # Photo storage and sync
├── videos/           # Video files
├── tv_series/        # TV show library
├── movies/           # Movie library
├── documents/        # Document storage and sync
├── music/            # Music library
├── books/            # E-book library
├── downloads/        # Download directory
├── backups/          # Local backup storage
└── nextcloud_data/   # Nextcloud data directory
```

## 🚀 **Quick Start Deployment**

### **Prerequisites**
```bash
# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Initialize Docker Swarm
docker swarm init
```

### **1. Clone and Setup**
```bash
git clone https://github.com/alwazw/manus_swarm.git
cd manus_swarm

# Copy customized environment file
cp .env.alwazw .env

# Create media directories
sudo mkdir -p /mnt/media/{photos,videos,tv_series,movies,documents,music,books,downloads,backups,nextcloud_data}
sudo chown -R $USER:$USER /mnt/media
```

### **2. Deploy Core Infrastructure**
```bash
# Deploy in order (dependencies matter)
docker compose -f proxy.yml up -d
docker compose -f security.yml up -d
docker compose -f media.yml up -d
docker compose -f monitoring.yml up -d
docker compose -f logging.yml up -d
docker compose -f notifications.yml up -d
docker compose -f backup.yml up -d
docker compose -f registry.yml up -d
```

### **3. Deploy All Services (Alternative)**
```bash
# Deploy everything at once
docker compose \
  -f proxy.yml \
  -f security.yml \
  -f media.yml \
  -f monitoring.yml \
  -f logging.yml \
  -f notifications.yml \
  -f backup.yml \
  -f registry.yml \
  up -d
```

## 🔧 **Configuration**

### **Environment Variables**
The `.env.alwazw` file contains all necessary configuration:
- User credentials and domains
- Media directory paths
- Service passwords
- SSL/TLS settings
- Monitoring configuration

### **Domain Configuration**
Update your DNS records to point to your server:
```
A     visionvation.com           -> YOUR_SERVER_IP
A     *.visionvation.com         -> YOUR_SERVER_IP
A     wazzan.us                  -> YOUR_SERVER_IP
A     *.wazzan.us                -> YOUR_SERVER_IP
```

## 🔐 **User Accounts**

### **Primary User**
- **Username**: alwazw
- **Email**: wafic@wazzan.us
- **Password**: WaficWazzan!2

### **Test User**
- **Username**: manus
- **Email**: manus@wazzan.us
- **Password**: Manus!2

## 🌐 **Service Access**

### **Local Access**
- **Authentication**: https://HOST_IP/login
- **Dashboard**: https://apps.HOST_IP
- **Services**: https://[service].HOST_IP

### **External Access**
- **Authentication**: https://visionvation.com/login
- **Dashboard**: https://apps.visionvation.com
- **Services**: https://[service].visionvation.com

### **Service URLs**
| Service | Local | External |
|---------|-------|----------|
| **Authentik** | https://HOST_IP/login | https://visionvation.com/login |
| **Heimdall** | https://apps.HOST_IP | https://apps.visionvation.com |
| **Nextcloud** | https://nextcloud.HOST_IP | https://nextcloud.visionvation.com |
| **Grafana** | https://grafana.HOST_IP | https://grafana.visionvation.com |
| **Prometheus** | https://prometheus.HOST_IP | https://prometheus.visionvation.com |
| **Harbor** | https://registry.HOST_IP | https://registry.visionvation.com |
| **Portainer** | https://portainer.HOST_IP | https://portainer.visionvation.com |
| **pgAdmin** | https://pgadmin.HOST_IP | https://pgadmin.visionvation.com |
| **Plex** | https://plex.HOST_IP | https://plex.visionvation.com |
| **Home Assistant** | https://home.HOST_IP | https://home.visionvation.com |
| **n8n** | https://automation.HOST_IP | https://automation.visionvation.com |
| **Vaultwarden** | https://vault.HOST_IP | https://vault.visionvation.com |
| **ntfy** | https://notifications.HOST_IP | https://notifications.visionvation.com |

## 📊 **Monitoring & Observability**

### **Grafana Dashboards**
- **Infrastructure Overview**: System metrics, container stats
- **Application Metrics**: Service-specific monitoring
- **Log Analysis**: Centralized log viewing and analysis
- **Security Dashboard**: Vulnerability scans, security events

### **Alerting**
- **Mobile Notifications**: via ntfy
- **Email Alerts**: Critical system events
- **Webhook Integration**: Custom alert handling

## 🔒 **Security Features**

### **Single Sign-On (SSO)**
- **Authentik**: Centralized authentication for all services
- **OAuth2/OIDC**: Modern authentication protocols
- **Multi-Factor Authentication**: Available (disabled by default)

### **Security Scanning**
- **Trivy**: Container vulnerability scanning
- **Falco**: Runtime security monitoring
- **ClamAV**: Antivirus scanning

### **Access Control**
- **Role-based Access**: Different permissions per user
- **Network Segmentation**: Isolated service networks
- **SSL/TLS**: Automatic certificate management

## 💾 **Backup & Recovery**

### **Automated Backups**
- **Schedule**: Daily at 2 AM
- **Retention**: 30 days
- **Scope**: All Docker volumes and media files

### **Backup Locations**
- **Local**: /mnt/media/backups
- **Remote**: Configurable (S3, FTP, etc.)

### **Recovery Procedures**
```bash
# Stop services
docker compose down

# Restore from backup
./scripts/restore-backup.sh BACKUP_DATE

# Restart services
docker compose up -d
```

## 🔄 **File Synchronization**

### **Nextcloud Features**
- **File Sync**: Desktop and mobile clients
- **Photo Backup**: Automatic phone photo upload
- **Document Collaboration**: Online editing
- **Calendar & Contacts**: Personal information management

### **Syncthing (Alternative)**
- **Peer-to-Peer**: Direct device synchronization
- **No Central Server**: Decentralized approach
- **Real-time Sync**: Instant file updates

## 🛠️ **Maintenance**

### **Health Checks**
```bash
# Check all services
docker ps

# View service logs
docker compose logs [service_name]

# Check resource usage
docker stats
```

### **Updates**
```bash
# Update all containers
docker compose pull
docker compose up -d

# Update specific service
docker compose pull [service_name]
docker compose up -d [service_name]
```

### **Scaling**
```bash
# Scale specific service
docker service scale [service_name]=3

# View service status
docker service ls
```

## 🐛 **Troubleshooting**

### **Common Issues**

#### **SSL Certificate Issues**
```bash
# Check Traefik logs
docker compose logs traefik

# Force certificate renewal
docker exec traefik traefik --certificatesresolvers.letsencrypt.acme.caserver=https://acme-v02.api.letsencrypt.org/directory
```

#### **Nextcloud Domain Issues**
```bash
# Update trusted domains
docker exec -it nextcloud php occ config:system:set trusted_domains 1 --value=nextcloud.visionvation.com
```

#### **Authentication Issues**
```bash
# Reset Authentik admin password
docker exec -it authentik-server ak create_admin_group
docker exec -it authentik-server ak create_admin_user
```

### **Log Locations**
- **Application Logs**: Centralized in Loki
- **System Logs**: /var/log/
- **Docker Logs**: docker compose logs [service]

## 📚 **Additional Resources**

### **Documentation**
- [Traefik Configuration](docs/traefik.md)
- [Authentik Setup](docs/authentik.md)
- [Nextcloud Configuration](docs/nextcloud.md)
- [Monitoring Setup](docs/monitoring.md)

### **Scripts**
- `scripts/deploy.sh` - Full deployment script
- `scripts/backup.sh` - Manual backup script
- `scripts/restore.sh` - Restore from backup
- `scripts/update.sh` - Update all services

## 🎯 **Production Considerations**

### **Hardware Requirements**
- **CPU**: 4+ cores
- **RAM**: 16+ GB
- **Storage**: 500+ GB SSD
- **Network**: Stable internet connection

### **Security Hardening**
- Regular security updates
- Firewall configuration
- Intrusion detection
- Regular backup testing

### **Scaling**
- Multi-node Docker Swarm
- Load balancing
- Database clustering
- Distributed storage

## 📞 **Support**

For issues and questions:
1. Check the troubleshooting section
2. Review service logs
3. Consult individual service documentation
4. Create GitHub issue with detailed information

---

**This infrastructure provides a complete replacement for cloud services while maintaining enterprise-grade security, monitoring, and management capabilities.** 🚀

