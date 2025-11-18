# Inception Project - Complete Roadmap
## Building a Multi-Service Docker Infrastructure from Scratch

---

## Table of Contents
1. [Prerequisites - What You Need to Understand](#prerequisites)
2. [Project Overview](#project-overview)
3. [Phase 1: Understanding Docker Fundamentals](#phase-1-docker-fundamentals)
4. [Phase 2: MariaDB Service](#phase-2-mariadb-service)
5. [Phase 3: WordPress Service](#phase-3-wordpress-service)
6. [Phase 4: Nginx Service](#phase-4-nginx-service)
7. [Phase 5: Integration & Testing](#phase-5-integration--testing)
8. [Phase 6: Final Configuration](#phase-6-final-configuration)

---

## Prerequisites - What You Need to Understand

### 1. **Docker Concepts**
- **Containers**: Isolated environments that package applications with their dependencies
- **Images**: Templates used to create containers (like a class in OOP)
- **Dockerfile**: Instructions to build an image
- **Docker Compose**: Tool to orchestrate multiple containers
- **Volumes**: Persistent storage for containers
- **Networks**: Communication channels between containers
- **Secrets**: Secure way to store sensitive data (passwords, keys)

### 2. **Linux Basics**
- File permissions (chmod, chown)
- Users and groups
- Bash scripting fundamentals
- System directories (/etc, /var, /run, /tmp, /usr)

### 3. **Networking Basics**
- Ports (3306 for MariaDB, 9000 for PHP-FPM, 443 for HTTPS)
- IP addresses and localhost
- How services communicate over networks

### 4. **Service-Specific Knowledge**
- **MariaDB**: Database management system
- **WordPress**: PHP-based content management system
- **Nginx**: Web server and reverse proxy
- **PHP-FPM**: FastCGI Process Manager for PHP

---

## Project Overview

### **Architecture**
```
Internet (HTTPS)
    ↓
Nginx:443 (SSL Termination)
    ↓
WordPress:9000 (PHP-FPM)
    ↓
MariaDB:3306 (Database)
```

### **Data Flow**
1. User visits website via HTTPS (port 443)
2. Nginx receives request and decrypts SSL
3. Nginx forwards PHP requests to WordPress container
4. WordPress processes request and queries MariaDB
5. MariaDB returns data to WordPress
6. WordPress generates HTML response
7. Nginx sends response back to user

### **Project Structure**
```
inception/
├── Makefile
├── secrets/
│   ├── db_root_password.txt
│   ├── db_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── mdb-entrypoint.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   ├── wp-config.php
        │   │   └── www.conf
        │   └── tools/
        │       └── wp-entrypoint.sh
        └── nginx/
            ├── Dockerfile
            └── conf/
                └── default
```

---

## Phase 1: Docker Fundamentals

### **Step 1.1: Understanding Dockerfile**
A Dockerfile contains instructions to build an image. Key commands:
- `FROM`: Base image (e.g., debian:bookworm)
- `RUN`: Execute commands during build
- `COPY`: Copy files from host to image
- `EXPOSE`: Document which ports the container uses
- `CMD`: Default command to run when container starts
- `ENV`: Set environment variables
- `WORKDIR`: Set working directory

### **Step 1.2: Understanding Docker Compose**
Docker Compose orchestrates multiple containers. Key concepts:
- **services**: Define your containers
- **networks**: Connect containers
- **volumes**: Persist data
- **secrets**: Manage sensitive data
- **environment**: Pass variables to containers
- **depends_on**: Define startup order

### **Step 1.3: Understanding Docker Networks**
- Containers on the same network can communicate using service names
- Example: WordPress connects to MariaDB using `mariadb:3306`
- Docker provides internal DNS resolution

### **Step 1.4: Understanding Docker Volumes**
- Volumes persist data outside containers
- Two types:
  - Named volumes: `mariadb_data:/var/lib/mysql`
  - Bind mounts: `/host/path:/container/path`
- Data survives container restarts

### **Step 1.5: Understanding Docker Secrets**
- Secure way to store passwords
- Mounted at `/run/secrets/` in container
- Not included in image (runtime only)

---

## Phase 2: MariaDB Service

### **Step 2.1: Create Directory Structure**
```bash
mkdir -p srcs/requirements/mariadb/{conf,tools}
mkdir -p secrets
```

### **Step 2.2: Create Secret Files**
**File**: `secrets/db_root_password.txt`
```
your_strong_root_password
```

**File**: `secrets/db_password.txt`
```
your_strong_db_password
```

**Purpose**: Store passwords securely outside the image

### **Step 2.3: Create Dockerfile**
**File**: `srcs/requirements/mariadb/Dockerfile`

**What to include**:
1. Base image: `FROM debian:bookworm`
2. Expose port: `EXPOSE 3306`
3. Install MariaDB: `apt-get install mariadb-server`
4. Create runtime directory: `/run/mysqld`
5. Copy configuration file
6. Copy entrypoint script
7. Set CMD to run entrypoint

**Why each step**:
- Base image: Provides OS
- Expose port: Documents MariaDB port
- Install: Adds MariaDB software
- Runtime dir: Required for PID and socket files
- Config: Customizes MariaDB behavior
- Entrypoint: Initializes database

### **Step 2.4: Create Configuration File**
**File**: `srcs/requirements/mariadb/conf/50-server.cnf`

**Critical settings**:
```ini
[mysqld]
user = mysql
pid-file = /run/mysqld/mysqld.pid
datadir = /var/lib/mysql
bind-address = 0.0.0.0
port = 3306
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci
```

**Explanation**:
- `user = mysql`: Run as mysql user (security)
- `bind-address = 0.0.0.0`: Accept external connections (other containers)
- `port = 3306`: Standard MySQL/MariaDB port
- `character-set-server`: UTF-8 support for all languages
- `datadir`: Where database files are stored

### **Step 2.5: Create Entrypoint Script**
**File**: `srcs/requirements/mariadb/tools/mdb-entrypoint.sh`

**Script logic**:
1. Check if database is initialized
2. If not, run `mariadb-install-db`
3. Set proper ownership
4. Start temporary MariaDB (no network)
5. Wait for MariaDB to be ready
6. Create database and user
7. Set root password
8. Stop temporary instance
9. Start final MariaDB server

**Why this approach**:
- Two-phase startup allows configuration before accepting connections
- Temporary instance is secure (socket only, no network)
- Idempotent: Can run multiple times safely

### **Step 2.6: Add to Docker Compose**
**File**: `srcs/docker-compose.yml`

```yaml
services:
  mariadb:
    build:
      context: ./requirements/mariadb/
    image: mariadb:v0
    container_name: mariadb
    restart: unless-stopped
    environment:
      DB_NAME: ${DB_NAME}
      DB_USER: ${DB_USER}
      DB_ROOT_PASSWORD_FILE: /run/secrets/db_root_password
      DB_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_root_password
      - db_password
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - inception
    init: true

secrets:
  db_root_password:
    file: ../secrets/db_root_password.txt
  db_password:
    file: ../secrets/db_password.txt

networks:
  inception:
    driver: bridge

volumes:
  mariadb_data:
    driver: local
```

### **Step 2.7: Create Environment File**
**File**: `srcs/.env`
```bash
DB_NAME=wordpress
DB_USER=wpuser
```

### **Step 2.8: Test MariaDB**
```bash
# Build and start
docker compose build mariadb
docker compose up mariadb -d

# Check logs
docker compose logs mariadb

# Test connection
docker exec -it mariadb mysql -u wpuser -p wordpress
```

---

## Phase 3: WordPress Service

### **Step 3.1: Create Directory Structure**
```bash
mkdir -p srcs/requirements/wordpress/{conf,tools}
```

### **Step 3.2: Create Secret Files**
**File**: `secrets/wp_admin_password.txt`
```
your_admin_password
```

**File**: `secrets/wp_user_password.txt`
```
your_user_password
```

### **Step 3.3: Create Dockerfile**
**File**: `srcs/requirements/wordpress/Dockerfile`

**What to include**:
1. Base image: `FROM debian:bookworm`
2. Expose port: `EXPOSE 9000` (PHP-FPM)
3. Install packages:
   - PHP-FPM and extensions
   - MariaDB client (to wait for database)
   - curl and ca-certificates
4. Install WP-CLI (WordPress command-line tool)
5. Create web directory: `/var/www/html`
6. Copy configuration files
7. Copy entrypoint script
8. Set CMD to run entrypoint

**Why PHP-FPM**:
- PHP-FPM processes PHP files
- Nginx forwards PHP requests to PHP-FPM
- More efficient than running PHP in Nginx

### **Step 3.4: Create PHP-FPM Configuration**
**File**: `srcs/requirements/wordpress/conf/www.conf`

**Key settings**:
```ini
[www]
user = www-data
group = www-data
listen = 9000
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

**Explanation**:
- `listen = 9000`: PHP-FPM listens on port 9000
- `user/group`: Run as www-data (security)
- `pm settings`: Process management (how many PHP workers)

### **Step 3.5: Create WordPress Configuration**
**File**: `srcs/requirements/wordpress/conf/wp-config.php`

**Key settings**:
```php
<?php
define('DB_NAME', getenv('DB_NAME'));
define('DB_USER', getenv('DB_USER'));
define('DB_PASSWORD', trim(file_get_contents('/run/secrets/db_password')));
define('DB_HOST', getenv('DB_HOST_PORT'));
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

// Authentication Unique Keys and Salts
// Generate from: https://api.wordpress.org/secret-key/1.1/salt/
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
// ... (add all salt keys)

$table_prefix = 'wp_';
define('WP_DEBUG', false);

if ( ! defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
```

**Why this config**:
- Uses environment variables for flexibility
- Reads password from secrets (security)
- Salt keys for encryption (generate unique ones)

### **Step 3.6: Create Entrypoint Script**
**File**: `srcs/requirements/wordpress/tools/wp-entrypoint.sh`

**Script logic**:
1. Create web directory with proper ownership
2. Download WordPress using WP-CLI
3. Copy wp-config.php
4. Wait for MariaDB to be ready
5. Install WordPress (create tables, admin user)
6. Create additional WordPress user
7. Set proper file permissions
8. Start PHP-FPM

**Why WP-CLI**:
- Automates WordPress installation
- No manual setup through web interface
- Scriptable and repeatable

### **Step 3.7: Add to Docker Compose**
```yaml
wordpress:
  build:
    context: ./requirements/wordpress/
  image: wordpress:v0
  container_name: wordpress
  restart: unless-stopped
  depends_on:
    - mariadb
  environment:
    URL: ${URL}
    TITLE: ${TITLE}
    WP_ADMIN_USER: ${WP_ADMIN_USER}
    WP_ADMIN_EMAIL: ${WP_ADMIN_EMAIL}
    WP_USER: ${WP_USER}
    WP_ROLE: ${WP_ROLE}
    WP_USER_EMAIL: ${WP_USER_EMAIL}
    DB_USER: ${DB_USER}
    DB_HOST: ${DB_HOST}
    DB_HOST_PORT: ${DB_HOST_PORT}
    DB_NAME: ${DB_NAME}
    WP_ADMIN_PASSWORD_FILE: /run/secrets/wp_admin_password
    WP_USER_PASSWORD_FILE: /run/secrets/wp_user_password
    DB_PASSWORD_FILE: /run/secrets/db_password
  secrets:
    - wp_admin_password
    - wp_user_password
    - db_password
  networks:
    - inception
  volumes:
    - wordpress_data:/var/www/html
  init: true
```

### **Step 3.8: Update Environment File**
Add to `srcs/.env`:
```bash
URL=https://yourdomain.42.fr
TITLE=My Inception Site
WP_ADMIN_USER=admin
WP_ADMIN_EMAIL=admin@example.com
WP_USER=user1
WP_ROLE=author
WP_USER_EMAIL=user1@example.com
DB_HOST=mariadb
DB_HOST_PORT=mariadb:3306
```

### **Step 3.9: Test WordPress**
```bash
# Build and start
docker compose up mariadb wordpress -d

# Check logs
docker compose logs wordpress

# Test PHP-FPM
docker exec -it wordpress php-fpm8.2 -v
```

---

## Phase 4: Nginx Service

### **Step 4.1: Create Directory Structure**
```bash
mkdir -p srcs/requirements/nginx/conf
```

### **Step 4.2: Create Dockerfile**
**File**: `srcs/requirements/nginx/Dockerfile`

**What to include**:
1. Base image: `FROM debian:bookworm`
2. Expose port: `EXPOSE 443` (HTTPS only)
3. Install nginx and openssl
4. Create SSL directories
5. Generate self-signed SSL certificate using build args
6. Copy nginx configuration
7. Set CMD to run nginx

**Why SSL**:
- Project requires HTTPS only (no HTTP)
- Self-signed certificate for development
- Production would use Let's Encrypt

### **Step 4.3: Create Nginx Configuration**
**File**: `srcs/requirements/nginx/conf/default`

```nginx
server {
    listen 443 ssl;
    server_name yourdomain.42.fr;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_certificate /etc/ssl/certs/server.crt;
    ssl_certificate_key /etc/ssl/private/server.key;
    
    root /var/www/html;
    index index.php index.html;
    
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass wordpress:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

**Explanation**:
- `listen 443 ssl`: HTTPS only
- `ssl_protocols`: Secure TLS versions only
- `ssl_certificate`: Path to SSL cert
- `root`: WordPress files location
- `location /`: Serve files or pass to PHP
- `location ~ \.php$`: Forward PHP requests to WordPress container
- `fastcgi_pass wordpress:9000`: Connect to WordPress via network

### **Step 4.4: Add to Docker Compose**
```yaml
nginx:
  build:
    context: ./requirements/nginx/
    args:
      COUNTRY: ${COUNTRY}
      STATE: ${STATE}
      LOCALITY: ${LOCALITY}
      ORGANIZATION: ${ORGANIZATION}
      UNIT: ${UNIT}
      COMMON_NAME: ${COMMON_NAME}
  image: nginx:v0
  container_name: nginx
  restart: unless-stopped
  depends_on:
    - mariadb
    - wordpress
  ports:
    - "443:443"
  volumes:
    - wordpress_data:/var/www/html
  networks:
    - inception
  init: true
```

**Why shared volume**:
- Nginx needs access to WordPress files
- Both nginx and wordpress containers mount same volume
- Nginx serves static files directly (images, CSS, JS)
- Nginx forwards PHP requests to WordPress

### **Step 4.5: Update Environment File**
Add to `srcs/.env`:
```bash
COUNTRY=US
STATE=California
LOCALITY=San Francisco
ORGANIZATION=42 School
UNIT=Inception
COMMON_NAME=yourdomain.42.fr
```

### **Step 4.6: Test Nginx**
```bash
# Build and start all services
docker compose up -d

# Check logs
docker compose logs nginx

# Test SSL certificate
openssl s_client -connect localhost:443

# Test in browser
# Add to /etc/hosts: 127.0.0.1 yourdomain.42.fr
# Visit: https://yourdomain.42.fr
```

---

## Phase 5: Integration & Testing

### **Step 5.1: Complete Docker Compose**
Verify all services are defined correctly:
- Services: mariadb, wordpress, nginx
- Networks: inception
- Volumes: mariadb_data, wordpress_data
- Secrets: All password files

### **Step 5.2: Create Makefile**
**File**: `Makefile`

```makefile
COMPOSE_FILE = srcs/docker-compose.yml

.PHONY: all up build start down stop clean re ps logs

all: up

up:
	docker compose -f $(COMPOSE_FILE) up -d

build:
	docker compose -f $(COMPOSE_FILE) build

start:
	docker compose -f $(COMPOSE_FILE) start

stop:
	docker compose -f $(COMPOSE_FILE) stop

down:
	docker compose -f $(COMPOSE_FILE) down

clean:
	docker compose -f $(COMPOSE_FILE) down --rmi all --volumes --remove-orphans
	docker system prune -af

re: clean all

ps:
	docker compose -f $(COMPOSE_FILE) ps -a

logs:
	docker compose -f $(COMPOSE_FILE) logs -f
```

### **Step 5.3: Testing Checklist**
1. **Build all images**: `make build`
2. **Start all services**: `make up`
3. **Check status**: `make ps`
4. **View logs**: `make logs`
5. **Test MariaDB**:
   ```bash
   docker exec -it mariadb mysql -u wpuser -p wordpress
   ```
6. **Test WordPress**:
   - Visit https://yourdomain.42.fr
   - Login with admin credentials
7. **Test persistence**:
   ```bash
   make down
   make up
   # Check if data persists
   ```

### **Step 5.4: Common Issues & Solutions**
1. **MariaDB won't start**:
   - Check permissions on /run/mysqld
   - Verify secrets are mounted
   - Check logs: `docker logs mariadb`

2. **WordPress can't connect to database**:
   - Verify DB_HOST is set to "mariadb"
   - Check if MariaDB is ready
   - Verify database credentials

3. **Nginx 502 Bad Gateway**:
   - Check if WordPress is running
   - Verify PHP-FPM is listening on port 9000
   - Check nginx configuration

4. **SSL certificate errors**:
   - Browser warning is normal for self-signed certs
   - Add exception in browser
   - Verify certificate was generated

---

## Phase 6: Final Configuration

### **Step 6.1: Security Hardening**
1. **Strong passwords** in secret files
2. **No hardcoded credentials** in code
3. **Minimal base images** (Debian slim or Alpine)
4. **Non-root users** for all services
5. **Read-only filesystems** where possible
6. **Network isolation** (only nginx exposed)

### **Step 6.2: Performance Optimization**
1. **PHP-FPM tuning** (adjust pm settings)
2. **MariaDB optimization** (buffer pool size)
3. **Nginx caching** (static files)
4. **Image size reduction** (multi-stage builds)

### **Step 6.3: Monitoring & Logging**
1. **Container health checks**
2. **Centralized logging**
3. **Resource limits** (CPU, memory)
4. **Restart policies**

### **Step 6.4: Documentation**
1. **README.md** with setup instructions
2. **Architecture diagram**
3. **Troubleshooting guide**
4. **Environment variables documentation**

---

## Key Concepts Summary

### **1. Why Three Separate Containers?**
- **Separation of concerns**: Each service has one responsibility
- **Scalability**: Can scale services independently
- **Maintainability**: Easier to update/debug individual services
- **Security**: Isolate services to limit breach impact

### **2. How Containers Communicate**
- Via Docker network using service names
- Example: WordPress connects to `mariadb:3306`
- Docker provides internal DNS resolution

### **3. Data Persistence**
- Volumes persist data outside containers
- Survives container restarts and rebuilds
- Two volumes: mariadb_data, wordpress_data

### **4. Security Best Practices**
- Secrets for sensitive data
- Non-root users in containers
- TLS 1.2+ only
- No unnecessary exposed ports

### **5. Startup Order**
- MariaDB starts first
- WordPress waits for MariaDB
- Nginx starts last (depends on both)

---

## Next Steps After Completion

1. **Add bonus services** (Redis, FTP, etc.)
2. **Implement health checks**
3. **Add backup/restore scripts**
4. **Set up CI/CD pipeline**
5. **Production deployment** (use real domain and SSL)

---

## Resources

### **Docker**
- Docker documentation: https://docs.docker.com
- Docker Compose reference: https://docs.docker.com/compose
- Docker best practices: https://docs.docker.com/develop/dev-best-practices

### **MariaDB**
- MariaDB documentation: https://mariadb.org/documentation
- Configuration reference: https://mariadb.com/kb/en/server-system-variables

### **WordPress**
- WordPress documentation: https://wordpress.org/documentation
- WP-CLI handbook: https://make.wordpress.org/cli/handbook
- wp-config.php guide: https://wordpress.org/documentation/article/editing-wp-config-php

### **Nginx**
- Nginx documentation: https://nginx.org/en/docs
- Beginner's guide: https://nginx.org/en/docs/beginners_guide.html
- FastCGI configuration: https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi

---

## Success Criteria

Your project is complete when:
- ✅ All three containers start successfully
- ✅ WordPress is accessible via HTTPS only
- ✅ Database persists after container restart
- ✅ No passwords in environment variables
- ✅ Each service in its own container
- ✅ Custom Dockerfiles (no ready-made images)
- ✅ Proper network isolation
- ✅ SSL/TLS configured correctly

Good luck with your Inception project!
