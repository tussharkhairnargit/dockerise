# Jenkins Setup in Docker

### Start the container
Run the following command to download the Jenkins image and start the service in the background:

<pre>
docker compose up -d
</pre>


This configuration uses the official *Jenkins LTS* image and sets up a dedicated Docker volume. This ensures your pipelines, plugins, and user accounts are safely saved on your computer even if the container stops or updates.

<div>
Run the logs command using the actual container name shown in your log:

<pre>
docker logs jenkins-local
</pre>

*Output: *
Jenkins initial setup is required. An admin user has been created and a password generated.
[LF]> Please use the following password to proceed to installation:
[LF]> 
[LF]> c17401dd3ff445249a82b5c832a9c051
[LF]> 
[LF]> This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
[LF]>
</ div>



## What Compose is doing
In docker-compose.yml, it does this:

* pulls jenkins/jenkins:lts-jdk17
* names the container jenkins-local
* exposes ports 8080 and 50000
* mounts a Docker volume for Jenkins data
* mounts the host Docker socket to allow Jenkins to run Docker commands
That is enough for a normal Jenkins setup without a Dockerfile.


The line - ```jenkins_data:/var/jenkins_home``` handles data persistence using a Docker Named Volume. It ensures your Jenkins configurations, plugins, and build history are safe and do not disappear when the container stops or gets deleted.



# Component Breakdown -

 **jenkins_data (The Host Side):** This is a named volume managed entirely by Docker on your host machine. Docker automatically creates a dedicated storage folder on your hard drive and maps it to this name. You do not need to worry about creating or managing the folder path manually.

**/var/jenkins_home (The Container Side):** This is the precise, hardcoded directory inside the Jenkins container where the application stores absolutely everything—your job definitions, pipeline scripts, workspace files, installed plugins, and user credentials.

# Why this is critical
 Containers are designed to be **ephemeral (temporary)**. If you restart, stop, or update a Jenkins container without this volume configuration, every change you made inside the Jenkins dashboard will be permanently wiped out. By mapping jenkins_data to /var/jenkins_home, all files written by Jenkins inside the container are immediately saved onto your actual physical machine.When you upgrade your Jenkins image in the future, you can safely destroy the old container, spin up a new one with this exact same line, and pick up right where you left off.

   