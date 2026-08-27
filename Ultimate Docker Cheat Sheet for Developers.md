### Ultimate Docker Cheat Sheet for Developers

A production-ready reference guide for building, managing, troubleshooting, and persisting data within Docker environments, tailored with Apple Silicon optimization notes. 

### 1. Running & Managing Containers

* **docker run -d -p <host-port>:<container-port> --name <name> <image>**
Downloads and starts a container in background detached mode (-d), exposes network ports (-p), and sets a friendly container name.
* **docker stop <container-id-or-name>**
Gracefully halts a running container by issuing a standard SIGTERM signal to its main process.
* **docker start <container-id-or-name>**
Wakes up and spins up an existing stopped container without resetting its data or state.
* **docker restart <container-id-or-name>**
Quickly stops and restarts a container—ideal for applying configuration tweaks.
* **docker rm <container-id-or-name>**
Deletes a stopped container from local storage. Append -f to force-remove an actively running container.

### 2. Inspecting & Troubleshooting

* **docker ps**
Lists all actively running containers on your engine.
* **docker ps -a**
Lists all containers across all states (running, paused, exited, or crashed). Use this to debug containers that stop immediately on launch.
* **docker logs -f --tail <number> <container-name>**
Fetches application logs. The -f flag streams lines in real time, and --tail limits the output history to keep your terminal responsive.
* **docker exec -it <container-name> bash**
Opens an interactive terminal terminal link (-it) inside a running container. Swap bash out for sh if working with lightweight base images like Alpine Linux.
* **docker stats**
Launches a live system monitor displaying real-time CPU consumption, memory footprints, and network I/O streams for active containers.
* **docker inspect <container-id-or-name>**
Returns low-level configuration details of a container or image in a comprehensive JSON payload.

### 3. Storage & Data Persistence

Containers are entirely ephemeral—data created inside them is destroyed when the container is dropped. Use the following structures to preserve your application data. 

### Docker-Managed Volumes (Best for Databases & Tools)

Docker manages a secure storage partition abstracted directly inside its engine files. 

* **docker volume create <volume-name>**
Generates a brand new, isolated data storage volume.
* **docker volume ls**
Lists all current active volumes on your machine.
* **docker volume inspect <volume-name>**
Reveals JSON metadata about a volume, displaying its driver attributes and secure pathing.
* **docker run -d -v my_data:/var/lib/mysql mysql**
Mounts a named volume (my_data) to a container target. If the volume name does not exist, Docker creates it on the fly.
* **docker volume rm <volume-name>**
Deletes a data volume. This fails if a container (even an inactive one) remains linked to it.

### Host Bind Mounts (Best for Local Development)

Maps an absolute file directory from your host Mac directly inside a target container space. This lets your local code edits show up instantly without rebuilding an image. 

* **docker run -d -v /Users/username/project:/app nginx**
Mounts an explicit host directory into the container's /app folder.
* **docker run -d -v $(pwd):/app nginx**
A quick-launch variant that uses your current terminal directory position ($(pwd)) as the host source path.

### Argument Syntax Rule of Thumb

* **Named Volume Syntax:** -v volume_name:/container/path (Begins directly with an alphanumeric string name).
* **Bind Mount Syntax:** -v /host/absolute/path:/container/path (Must always lead with a forward slash or system variable).

### 4. Managing Docker Images

* **docker images**
Lists all local image blueprints cached on your hard drive.
* **docker pull <image-name>:<tag>**
Downloads an image asset directly from Docker Hub without launching a container runtime.
* **docker build -t <image-name>:<tag> .**
Compiles a brand new image based on the instructions inside the local directory's (.) Dockerfile.
* **docker build --platform linux/amd64 -t <image-name>:<tag> .**
**Apple Silicon Tip:** Forces the build engine to output an Intel x86 image profile rather than ARM64, ensuring cloud infrastructure compatibility.
* **docker rmi <image-id-or-name>**
Erases an image from local machine memory. This can only be performed if no current container relies on the targeted image blueprint.

### 5. Multi-Container Orchestration (Docker Compose)

* **docker compose up -d**
Reads the local docker-compose.yml file, sets up networks, builds dependencies, and spins up your full stack in the background.
* **docker compose down**
Brings down your application stack, systematically pausing containers and destroying local configuration networks safely.
* **docker compose down -v**
Tears down the environment stack and completely wipes out all attached named data volumes permanently. Use with caution.
* **docker compose logs -f <service-name>**
Isolates and streams the background log output of a single distinct service defined within your compose environment.

### 6. Housekeeping & Space Recovery

Running multiple builds on Apple Silicon Macs can consume disk space quickly. Use these utility tools to recover storage room. 

* **docker system df**
Prints a clean, concise breakdown of disk space consumed by images, containers, and active system volumes.
* **docker system prune**
Deletes all stopped containers, unused virtual networks, and dangling image cache blocks.
* **docker system prune -a --volumes**
The ultimate deep clean. Completely wipes all stopped containers, unused networks, unreferenced volumes, and every image not currently assigned to a live container environment.
