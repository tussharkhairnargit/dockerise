Your provided setup is excellent! It is clean, production-ready, and keeps your execution logs reactive with proxy_buffering off and WebSocket connection upgrades.
To make this exact configuration work with your host-installed Ollama running Gemma 3, you just need to add two lines to the docker-compose.yml so the containers can speak to your computer's local hardware.
Here is the exact way to organize, update, and run your files.
------------------------------
## Step 1: Organize Your Project Files
Create a project folder on your computer and place your files exactly like this:

local-ai-automation/
├── docker-compose.yml
└── nginx.conf

## Step 2: Save Your Updated Configurations## 1. docker-compose.yml
Save this code block. Notice the addition of extra_hosts under the nginx and n8n services—this is the magic line that allows Docker to reach out to your host's local Ollama instance.

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
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - GENERIC_TIMEZONE=Asia/Kolkata
      - TZ=Asia/Kolkata
    volumes:
      - n8n_data:/home/node/.n8n
    # Allows n8n to talk directly to your host's Ollama if needed
    extra_hosts:
      - "host.docker.internal:host-gateway"

  nginx:
    image: nginx:latest
    container_name: nginx
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - n8n-network
    depends_on:
      - n8n
    # Allows Nginx to proxy or pass traffic to your host's Ollama
    extra_hosts:
      - "host.docker.internal:host-gateway"
volumes:
  n8n_data:

## 2. nginx.conf
Save your exact configuration into a file named nginx.conf in the same directory:

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://n8n:5678;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # WebSocket support for live UI updates
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_buffering off;
        }
    }
}

------------------------------
## Step 3: Start the Stack
Open your terminal in the local-ai-automation folder and run:

docker compose up -d

This downloads the images, links them to n8n-network, mounts your config, and fires everything up. You can now access your n8n dashboard by opening your browser to http://localhost.
------------------------------
## Step 4: Hook It to Your Local Ollama & Gemma 3
Because your Ollama application is running natively on your computer (outside of Docker), we use the host.docker.internal bridge we added to your Compose file.

   1. Open http://localhost and go to Settings -> Credentials.
   2. Click Add Credential and search for Ollama.
   3. For the Base URL, enter:
   
   http://docker.internal
   
   4. Click Save.

(Note: Remember to make sure your local Ollama is configured to accept outside connections by setting the environment variable OLLAMA_HOST=0.0.0.0 before running it on your host machine, as detailed previously!)
When you add an AI node in n8n, select this credential, type in gemma3 (or your specific tag like gemma3:4b), and your local workflows will process instantly using your computer's native hardware.
Are you getting any connection errors when testing the credential, or would you like to build a quick test workflow to check the processing speed of Gemma 3?

