## Restart Ollama with Network Access
Now that it is fully shut down, reopen your Terminal application and run this exact command to start it back up with permissions enabled for Docker:bash 
```OLLAMA_HOST=0.0.0.0 ollama serve```
Use code with caution.Keep that terminal window open, return to your browser at http://localhost, and test the http://docker.internal credential again. It should connect successfully!