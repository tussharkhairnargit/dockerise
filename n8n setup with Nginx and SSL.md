To put n8n behind an Nginx reverse proxy, you need to route external traffic securely (via HTTPS) to your internal n8n Docker container.
The easiest and most production-ready way to handle this is by expanding your Docker Compose file to run both n8n and Nginx together, using Let's Encrypt (via Certbot) for free, automated SSL certificates.
## Prerequisites
Before starting, ensure you have:

* A registered domain name (e.g., ://yourdomain.com).
* Your domain's A Record pointing to your server's public IP address.
* Ports 80 and 443 open on your server's firewall.

------------------------------
## Step 1: Update your docker-compose.yml
This configuration bundles n8n, Nginx, and Certbot. It creates a shared network so Nginx can securely forward traffic to n8n without exposing n8n's port 5678 directly to the internet.
Replace your existing docker-compose.yml with the following:

version: '3.8'
networks:
  n8n-network:
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    networks:
      - n8n-network
    environment:
      - N8N_HOST=://yourdomain.com
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://://yourdomain.com/
      - GENERIC_TIMEZONE=Asia/Kolkata
      - TZ=Asia/Kolkata
    volumes:
      - n8n_data:/home/node/.n8n

  nginx:
    image: nginx:latest
    container_name: nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certbot/www:/var/www/certbot:ro
      - ./certbot/conf:/etc/letsencrypt:ro
    networks:
      - n8n-network
    depends_on:
      - n8n

  certbot:
    image: certbot/certbot:latest
    container_name: certbot
    volumes:
      - ./certbot/www:/var/www/certbot:rw
      - ./certbot/conf:/etc/letsencrypt:rw
volumes:
  n8n_data:

(Note: Replace ://yourdomain.com with your actual domain name).
------------------------------
## Step 2: Create the Nginx Configuration (nginx.conf)
Create a file named nginx.conf in the exact same directory as your docker-compose.yml. Paste the following configuration, which includes the necessary headers for n8n's WebSockets (Server-Sent Events) to function correctly.

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Redirect all HTTP traffic to HTTPS
    server {
        listen 80;
        server_name ://yourdomain.com;

        # Needed for Certbot SSL challenge
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 301 https://$host$request_uri;
        }
    }

    # HTTPS Server Configuration
    server {
        listen 443 ssl;
        server_name ://yourdomain.com;

        # SSL Certificates (Certbot paths)
        ssl_certificate /etc/letsencrypt/live/://yourdomain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/://yourdomain.com/privkey.pem;

        # Proxy traffic to the n8n container
        location / {
            proxy_pass http://n8n:5678;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded-for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Crucial for n8n UI updates & WebSockets
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_buffering off;
        }
    }
}

(Note: Remember to replace ://yourdomain.com in all three places inside this file).
------------------------------
## Step 3: Generate your SSL Certificate
Because Nginx expects SSL certificates to exist before it can start securely, we run a temporary Certbot command to fetch them first.

   1. Start just the Nginx service on port 80:
   
   docker compose up -d nginx
   
   2. Run Certbot to request your certificate (replace with your email and domain):
   
   docker compose run --rm certbot certonly --webroot --webroot-path=/var/www/certbot --email your-email@example.com --agree-tos --no-eff-email -d ://yourdomain.com
   
   3. Once Certbot successfully creates the certificates, restart Nginx to apply them:
   
   docker compose restart nginx
   
   
------------------------------
## Step 4: Boot up n8n
Now that your proxy and SSL certificates are ready, start your entire stack in the background:

docker compose up -d

You can now open your browser and securely navigate to https://yourdomain.com to start building automations with live webhook capabilities.
------------------------------
Would you like to know how to set up an automated cron job to renew these SSL certificates, or do you need help debugging an Nginx error?

