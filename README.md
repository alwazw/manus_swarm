# 🚀 **Self-Hosted Infrastructure Stack**

Complete cloud replacement with enterprise-grade security, monitoring, and authentication.

## ⚡ **Quick Start (One Command)**

```bash
# 1. Clone repository
git clone https://github.com/alwazw/manus_swarm.git
cd manus_swarm

# 2. Configure environment
cp .env.example .env
# Edit .env with your domains and passwords

# 3. Deploy everything
docker compose -f full-stack.yml up -d
```

**That's it!** Your complete infrastructure is now running.

---

## 🌐 **Access Your Services**

After deployment, access your services at:

| **Service** | **URL** | **Purpose** |
|-------------|---------|-------------|
| **🔐 Login** | `https://yourdomain.com/login` | Authentik SSO Authentication |
| **🏠 Dashboard** | `https://apps.yourdomain.com` | Heimdall Application Dashboard |
| **☁️ Files** | `https://nextcloud.yourdomain.com` | Nextcloud File Storage |
| **📸 Photos** | `https://photos.yourdomain.com` | PhotoPrism Photo Management |
| **🎬 Media** | `https://plex.yourdomain.com` | Plex Media Server |
| **📊 Analytics** | `https://grafana.yourdomain.com` | Grafana Dashboards |
| **🔧 Management** | `https://portainer.yourdomain.com` | Container Management |
| **🔄 Sync** | `https://sync.yourdomain.com` | File Synchronization |
| **📱 Notifications** | `https://ntfy.yourdomain.com` | Push Notifications |

---

## 🔧 **What You Get**

### **☁️ Complete Cloud Replacement**
- **File Storage & Sync** - Replace OneDrive/Google Drive
- **Photo Management** - Replace Google Photos/iCloud Photos  
- **Media Streaming** - Replace Netflix/Spotify subscriptions
- **Document Collaboration** - Replace Office 365/Google Workspace

### **🔒 Enterprise Security**
- **Single Sign-On (SSO)** - Authentik authentication for all services
- **SSL/TLS Encryption** - Automatic certificates via Let's Encrypt
- **Access Control** - Fine-grained permissions and user management
- **Security Monitoring** - Real-time threat detection and alerting

### **📊 Professional Monitoring**
- **Real-time Dashboards** - Grafana analytics and visualization
- **Metrics Collection** - Prometheus monitoring stack
- **Log Aggregation** - Centralized logging with Loki
- **Performance Monitoring** - Container and host metrics

### **🌐 Professional Infrastructure**
- **Reverse Proxy** - Traefik with automatic SSL
- **Container Orchestration** - Docker Compose management
- **Backup & Recovery** - Automated data protection
- **High Availability** - Production-ready configuration

---

## 📋 **Requirements**

- **OS**: Ubuntu 20.04+ (or any Docker-compatible Linux)
- **CPU**: 4+ cores recommended
- **RAM**: 8GB+ recommended  
- **Storage**: 100GB+ available space
- **Network**: Stable internet connection
- **Domains**: 2 domains pointed to your server (optional for local use)

---

## ⚙️ **Configuration**

### **1. Environment Setup**

Copy and edit the environment file:

```bash
cp .env.example .env
nano .env
```

**Required Variables:**
```bash
# Domains
DOMAIN=yourdomain.com
DOMAIN_ALT=youralternatedomain.com

# User Information  
USER_NAME=alwazw
ACME_EMAIL=your-email@domain.com

# Media Storage Path
MEDIA_PATH=/mnt/media

# Database Passwords
POSTGRES_PASSWORD=your-secure-password
REDIS_PASSWORD=your-redis-password

# Service Passwords
GRAFANA_PASSWORD=your-grafana-password
NEXTCLOUD_ADMIN_PASSWORD=your-nextcloud-password
PHOTOPRISM_ADMIN_PASSWORD=your-photoprism-password

# Authentik Configuration
AUTHENTIK_SECRET_KEY=your-secret-key-here
AUTHENTIK_POSTGRES_PASSWORD=your-authentik-db-password

# Cloudflare Tunnel (Optional)
CLOUDFLARE_TUNNEL_TOKEN=your-tunnel-token
```

### **2. Directory Structure**

Create media directories:
```bash
sudo mkdir -p /mnt/media/{photos,videos,movies,tv_series,music,documents}
sudo chown -R $USER:$USER /mnt/media
```

### **3. Domain Configuration (Optional)**

For external access, configure your domains to point to your server:
- `yourdomain.com` → Your server IP
- `*.yourdomain.com` → Your server IP (wildcard)

---

## 🚀 **Deployment**

### **Standard Deployment**
```bash
docker compose -f full-stack.yml up -d
```

### **Check Status**
```bash
docker compose -f full-stack.yml ps
```

### **View Logs**
```bash
docker compose -f full-stack.yml logs -f [service-name]
```

### **Stop Services**
```bash
docker compose -f full-stack.yml down
```

### **Update Services**
```bash
docker compose -f full-stack.yml pull
docker compose -f full-stack.yml up -d
```

---

## 🔐 **Authentication Flow**

1. **Visit** `https://yourdomain.com/login`
2. **Login** with Authentik SSO
3. **Redirected** to `https://apps.yourdomain.com` (Heimdall)
4. **Access** any service with automatic SSO

### **Default Accounts**

**Admin Account:**
- Username: `admin`
- Email: `wafic@wazzan.us`  
- Password: `WaficWazzan!2`

**User Account:**
- Username: `manus`
- Email: `manus@wazzan.us`
- Password: `Manus!2`

---

## 📁 **Project Structure**

```
manus_swarm/
├── full-stack.yml          # Complete deployment file
├── .env                    # Environment configuration
├── .env.example           # Environment template
├── README.md              # This file
├── config/                # Service configurations
│   ├── traefik/          # Reverse proxy config
│   ├── prometheus/       # Monitoring config
│   └── grafana/          # Dashboard config
├── docs/                  # Documentation
├── scripts/               # Deployment scripts
└── secrets/               # Secret files
```

---

## 🛠️ **Troubleshooting**

### **Common Issues**

**Services not starting:**
```bash
docker compose -f full-stack.yml logs [service-name]
```

**Permission issues:**
```bash
sudo chown -R $USER:$USER /mnt/media
sudo chmod -R 755 /mnt/media
```

**SSL certificate issues:**
```bash
# Check Traefik logs
docker compose -f full-stack.yml logs traefik
```

**Database connection issues:**
```bash
# Check database status
docker compose -f full-stack.yml exec postgres pg_isready
```

### **Reset Everything**
```bash
docker compose -f full-stack.yml down -v
docker system prune -a
docker compose -f full-stack.yml up -d
```

---

## 📚 **Documentation**

- **[Cloudflare Tunnel Setup](docs/CLOUDFLARE-TUNNEL-SETUP.md)** - External access configuration
- **[GitHub Setup Guide](docs/GITHUB_SETUP.md)** - Repository management
- **[Stack Analysis](docs/stack-expansion-analysis.md)** - Architecture details
- **[Volume Explanation](docs/volume-explanation.md)** - Data storage guide

---

## 🎯 **What This Replaces**

| **Cloud Service** | **Self-Hosted Alternative** | **Annual Savings** |
|-------------------|------------------------------|-------------------|
| OneDrive (1TB) | Nextcloud | $70/year |
| Google Photos | PhotoPrism | $100/year |
| Netflix | Plex + Media | $180/year |
| Spotify | Plex Music | $120/year |
| Dropbox Pro | Syncthing | $120/year |
| Office 365 | Nextcloud Office | $100/year |
| **Total Savings** | | **$690+/year** |

---

## 🔄 **Backup & Recovery**

### **Backup Data**
```bash
# Backup all volumes
docker run --rm -v manus_swarm_postgres-data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-backup.tar.gz -C /data .

# Backup media files
tar czf media-backup.tar.gz /mnt/media
```

### **Restore Data**
```bash
# Restore volumes
docker run --rm -v manus_swarm_postgres-data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres-backup.tar.gz -C /data

# Restore media
tar xzf media-backup.tar.gz -C /
```

---

## 🚀 **Scaling & Expansion**

### **Add More Services**
Edit `full-stack.yml` and add new services following the existing patterns.

### **Multi-Server Deployment**
For production clusters, consider migrating to:
- **Docker Swarm Mode** - Multi-node orchestration
- **Kubernetes (k3s)** - Advanced container orchestration
- **Nomad** - Alternative orchestration platform

---

## 🤝 **Support**

- **Issues**: [GitHub Issues](https://github.com/alwazw/manus_swarm/issues)
- **Discussions**: [GitHub Discussions](https://github.com/alwazw/manus_swarm/discussions)
- **Documentation**: [docs/](docs/) directory

---

## 📄 **License**

This project is open source and available under the [MIT License](LICENSE).

---

## 🎉 **Success!**

You now have a complete, enterprise-grade, self-hosted infrastructure that:

✅ **Replaces all major cloud services**  
✅ **Provides enterprise security and monitoring**  
✅ **Saves $690+ annually in subscriptions**  
✅ **Gives you complete data control and privacy**  
✅ **Scales with your needs**  

**Welcome to your new self-hosted cloud empire!** 🚀

---

*Last updated: July 18, 2025*

