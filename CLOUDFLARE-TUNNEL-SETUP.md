# Cloudflare Tunnel Setup Guide

## 🌐 **Overview**

Using Cloudflare Tunnel eliminates the need for port forwarding and provides secure, encrypted access to your self-hosted services. All traffic goes through Cloudflare's network, providing DDoS protection and improved performance.

## 🚀 **Setup Process**

### **Step 1: Create Cloudflare Tunnel**

1. **Go to Cloudflare Zero Trust Dashboard**
   - Visit: https://one.dash.cloudflare.com/
   - Navigate to **Access** → **Tunnels**

2. **Create New Tunnel**
   - Click **"Create a tunnel"**
   - Choose **"Cloudflared"**
   - Name: `alwazw-stack-tunnel`
   - Click **"Save tunnel"**

3. **Install Connector**
   - Copy the tunnel token (starts with `eyJ...`)
   - Add to your `.env` file:
   ```bash
   CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiYWJjZGVmZ2hpams...
   ```

### **Step 2: Configure Domain Routing**

Add these public hostnames in the Cloudflare Tunnel dashboard:

#### **Primary Domain Routes (visionvation.com)**
```
# Authentication & Dashboard
visionvation.com/login          → http://traefik:80
apps.visionvation.com           → http://traefik:80

# Core Services
nextcloud.visionvation.com      → http://traefik:80
grafana.visionvation.com        → http://traefik:80
prometheus.visionvation.com     → http://traefik:80
notifications.visionvation.com  → http://traefik:80

# Media Services
plex.visionvation.com           → http://traefik:80
photos.visionvation.com         → http://traefik:80
immich.visionvation.com         → http://traefik:80
jellyfin.visionvation.com       → http://traefik:80

# Management Services
portainer.visionvation.com      → http://traefik:80
pgadmin.visionvation.com        → http://traefik:80
registry.visionvation.com       → http://traefik:80

# Sync & File Services
sync.visionvation.com           → http://traefik:80
files.visionvation.com          → http://traefik:80
backup.visionvation.com         → http://traefik:80

# Monitoring & Logs
loki.visionvation.com           → http://traefik:80
logs.visionvation.com           → http://traefik:80
uptime.visionvation.com         → http://traefik:80
alerts.visionvation.com         → http://traefik:80

# Security Services
trivy.visionvation.com          → http://traefik:80
falco.visionvation.com          → http://traefik:80

# Automation
automation.visionvation.com     → http://traefik:80
home.visionvation.com           → http://traefik:80

# Communication
chat.visionvation.com           → http://traefik:80
mail.visionvation.com           → http://traefik:80

# Password Manager
vault.visionvation.com          → http://traefik:80
```

#### **Secondary Domain Routes (wazzan.us)**
```
# Mirror all services on secondary domain
apps.wazzan.us                  → http://traefik:80
nextcloud.wazzan.us             → http://traefik:80
grafana.wazzan.us               → http://traefik:80
# ... (repeat all services)
```

### **Step 3: DNS Configuration**

In your Cloudflare DNS settings, ensure you have:

```
# Primary Domain
A     visionvation.com           → (Cloudflare will handle this)
CNAME *.visionvation.com         → visionvation.com

# Secondary Domain  
A     wazzan.us                  → (Cloudflare will handle this)
CNAME *.wazzan.us                → wazzan.us
```

### **Step 4: Deploy Tunnel**

```bash
# Add tunnel token to environment
echo "CLOUDFLARE_TUNNEL_TOKEN=your_token_here" >> .env

# Deploy tunnel service
docker compose -f cloudflare-tunnel.yml up -d

# Verify tunnel is connected
docker logs cloudflared
```

## 🔧 **Configuration Benefits**

### **Security Advantages**
- ✅ **No open ports** on your home router
- ✅ **DDoS protection** via Cloudflare
- ✅ **Encrypted tunnels** (TLS 1.3)
- ✅ **Access policies** can be applied
- ✅ **Zero Trust** security model

### **Performance Benefits**
- ✅ **Global CDN** acceleration
- ✅ **Automatic SSL** certificates
- ✅ **HTTP/2 and HTTP/3** support
- ✅ **Compression** and optimization
- ✅ **Caching** for static content

### **Management Benefits**
- ✅ **Single tunnel** for all services
- ✅ **Easy domain management** in dashboard
- ✅ **Traffic analytics** and monitoring
- ✅ **Access logs** and security insights

## 🛠️ **Advanced Configuration**

### **Access Policies (Optional)**
You can add authentication policies in Cloudflare Zero Trust:

1. **Go to Access** → **Applications**
2. **Create Application** for sensitive services
3. **Add policies** (email domain, IP restrictions, etc.)

Example policy for admin services:
```
Application: Admin Services
Domain: grafana.visionvation.com, prometheus.visionvation.com
Policy: Require email domain @wazzan.us
```

### **Tunnel Configuration File (Alternative)**
Instead of using tokens, you can use a config file:

```yaml
# config.yml
tunnel: your-tunnel-id
credentials-file: /etc/cloudflared/cert.json

ingress:
  - hostname: visionvation.com
    path: /login
    service: http://traefik:80
  - hostname: apps.visionvation.com
    service: http://traefik:80
  - hostname: nextcloud.visionvation.com
    service: http://traefik:80
  # ... more services
  - service: http_status:404
```

## 🔍 **Troubleshooting**

### **Common Issues**

1. **Tunnel not connecting**
   ```bash
   # Check logs
   docker logs cloudflared
   
   # Verify token
   echo $CLOUDFLARE_TUNNEL_TOKEN
   ```

2. **Service not accessible**
   - Verify Traefik labels are correct
   - Check if service is running: `docker ps`
   - Verify network connectivity: `docker network ls`

3. **SSL certificate issues**
   - Cloudflare handles SSL termination
   - Ensure Traefik is configured for HTTP (not HTTPS) backend

### **Testing Connectivity**

```bash
# Test internal connectivity
docker exec cloudflared ping traefik

# Test service resolution
curl -H "Host: nextcloud.visionvation.com" http://traefik:80

# Check tunnel status
docker exec cloudflared cloudflared tunnel info
```

## 📊 **Monitoring**

### **Cloudflare Analytics**
- **Traffic metrics** in Cloudflare dashboard
- **Security events** and blocked requests
- **Performance insights** and optimization suggestions

### **Local Monitoring**
- **Tunnel status** in Prometheus metrics
- **Connection health** monitoring
- **Traffic patterns** analysis

## 🎯 **Final Configuration**

Your complete setup will provide:

- ✅ **Secure external access** without port forwarding
- ✅ **Automatic SSL** for all domains
- ✅ **DDoS protection** and performance optimization
- ✅ **Single point of management** for all services
- ✅ **Zero Trust security** with optional access policies

**All services will be accessible via:**
- `https://service.visionvation.com`
- `https://service.wazzan.us`

**With local access still available via:**
- `https://service.HOST_IP` (through Traefik)

This provides the best of both worlds - secure external access and fast local access! 🚀

