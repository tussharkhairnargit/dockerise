# Setting Up Jenkins in a Docker Container

Setting up **Jenkins in a Docker container** is the fastest way to get a CI/CD environment running. You can achieve this using either a direct Docker command or a Docker Compose file. 

---

## Method 1: Using the Docker CLI (Quickest)

Run the following command in your terminal to pull the official **Jenkins LTS image** and start the container:

```bash
docker run -d \
  --name jenkins \
  --restart unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

### What these flags do:
* `-d`: Runs the container in the background (detached mode).
* `--name jenkins`: Assigns a friendly name to your container.
* `--restart unless-stopped`: Ensures Jenkins automatically restarts if the system reboots.
* `-p 8080:8080`: Maps the Jenkins web interface to your host machine.
* `-p 50000:50000`: Maps the port required for connecting distributed Jenkins build agents.
* `-v jenkins_home:/var/jenkins_home`: Creates a persistent named volume so you don't lose your data, configurations, and jobs when the container restarts.

---

## Method 2: Using Docker Compose (Recommended)

If you prefer managing your infrastructure as code, you can use **Docker Compose**. 

1. Create a file named `docker-compose.yml`.
2. Paste the following configuration:

```yaml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_data:/var/jenkins_home

volumes:
  jenkins_data:
```

3. Start the container by running:
```bash
docker compose up -d
```

---

## Post-Installation & Wizard Setup

Once your container is running, complete the setup through the web interface:

1. **Access the Dashboard:** Open your browser and go to `http://localhost:8080`.
2. **Retrieve the Initial Admin Password:** Jenkins will ask for an unlock key. Get it by checking the container logs with this command:
   ```bash
   docker logs jenkins
   ```
   *(Alternatively, read the file directly from the container: `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`)*
3. **Complete the Wizard:** Paste the password, click **"Install suggested plugins"**, and create your first admin user account.
