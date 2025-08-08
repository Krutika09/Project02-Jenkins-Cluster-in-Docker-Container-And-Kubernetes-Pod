#!/bin/bash

# Download the agent.jar only if not present
if [ ! -f agent.jar ]; then
  curl -sO http://34.216.17.78:8080/jnlpJars/agent.jar
fi

# Start Jenkins agent
exec java -jar agent.jar \
  -url http://34.216.17.78:8080/ \
  -secret c3e3f47b96a740c5f2e04adfd4a127f9a31608da3e06df9b5be2e5c20d979207 \
  -name "k8-agent" \
  -webSocket \
  -workDir "/home/jenkins/agent"
