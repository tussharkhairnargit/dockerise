# dockerise
Check the installed version:
```docker --version```

Check the system architecture:
``` docker info | grep -i architecture ```

Check active container engines:
```docker ps```

Start the Jenkins service as a background daemon: ```brew services start jenkins-lts```

Retrieve your initial administrator password by running this command in your Terminal:
bash ```cat /Users/$(whoami)/.jenkins/secrets/initialAdminPassword```

configuration file : 
Create a file named ```docker-compose.yml```

3. Run a Live Test Container:
   ```docker run --rm hello-world```

Retrieve the Initial Admin PasswordJenkins locks itself automatically on the first boot for safety. Wait about 30 seconds for it to initialize, then run this command to read the setup password from the container logs: 
```docker logs jenkins-local```

   50000 port: This port is left open so you can attach external build agent machines to this main Jenkins controller in the future.


   TODO
   Setting up a Jenkins agent/node for iOS or macOS builds?
