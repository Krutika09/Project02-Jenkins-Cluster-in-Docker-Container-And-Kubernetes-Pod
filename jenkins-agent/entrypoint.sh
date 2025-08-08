#!/bin/bash

# Download the agent.jar only if not present
if [ ! -f agent.jar ]; then
  curl -sO http://34.216.17.78:8080/jnlpJars/agent.jar
fi

# Start Jenkins agent
exec java -jar agent.jar \
  -url http://44.251.64.138:8080/ \
  -secret dd07d637328e1f74f8adc48ee3b11ca55524e34ba7f48b705a8d4ab2560a916a \
  -name "K8-Agent-Secrets" \
  -webSocket \
  -workDir "/home/jenkins/agent"
