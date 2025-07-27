# 🚀 Deploying Multi-Agent Jenkins CI/CD Pipelines on Kubernetes 🐳☸️

This project demonstrates how to set up a full Jenkins CI/CD pipeline with multiple agents running inside a Kubernetes cluster. It covers deploying Jenkins master and agent nodes, configuring SSH-based agent connections, and running end-to-end pipelines.

---

## 🛠️ Project Overview

- Jenkins Master deployed inside Kubernetes
- Multiple Jenkins Agents (Slaves) deployed as Kubernetes pods
- SSH-based agent configuration
- Full Docker-in-Docker pipeline execution
- Pipeline builds, deploys and tests Dockerized applications
- SCM Polling for automatic pipeline triggering

---

## 📦 Jenkins Master Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-master
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins-master
  template:
    metadata:
      labels:
        app: jenkins-master
    spec:
      containers:
      - name: jenkins-master-container
        image: krutika09/jenkins-master:rhel9-v1
        securityContext:
          privileged: true
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-master-service
spec:
  type: NodePort
  selector:
    app: jenkins-master
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
    nodePort: 30080
````

Access Jenkins UI:
`http://<Node-IP>:30080`

---

## 📦 Jenkins Agent Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-slave
spec:
  replicas: 2
  selector:
    matchLabels:
      app: jenkins-slave
  template:
    metadata:
      labels:
        app: jenkins-slave
    spec:
      containers:
      - name: jenkins-slave-container
        image: krutika09/jenkins-slave:rhel9-v1
        securityContext:
          privileged: true
        ports:
        - containerPort: 22
```

---

## 🔑 SSH Key Configuration

1️⃣ Generate SSH key pair inside Jenkins master container
2️⃣ Copy public key into all agent pods under `/home/jenkins/.ssh/authorized_keys`
3️⃣ Verify manual SSH connectivity from master to agents

---

## ⚙️ Jenkins Agent Configuration

* Add new nodes in Jenkins UI (`Manage Jenkins > Nodes`)
* Set:

  * Remote Root Dir: `/home/jenkins`
  * Launch Method: SSH
  * Credentials: Private key of master
  * Labels: `agent-node-1`, `agent-node-2` (for targeting)

---

## 🧪 CI/CD Pipeline Script

```groovy
pipeline {
    agent { label 'agent-node-2' }

    environment {
        IMAGE_NAME = "sayantan2k21/demo-app"
        IMAGE_TAG = "v1.0-${BUILD_NUMBER}"
        CONTAINER_NAME = "demo-app-container"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Sayantan2k24/flask-app-for-jenkins-docker-example.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }
        stage('Run Docker Container') {
            steps {
                sh "docker rm -f ${CONTAINER_NAME} || true && docker run -d -p 5000:5000 --name ${CONTAINER_NAME} ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
        stage('Health Check') {
            steps {
                sh "sleep 10 && curl localhost:5000"
            }
        }
    }

    post {
        always {
            echo "Job executed on agent: ${env.NODE_NAME}"
        }
    }
}
```

---

## 🔎 Pipeline Stage Summary

* ✅ **Checkout Code** — Pull code from GitHub
* ✅ **Build Image** — Build Docker image
* ✅ **Run Container** — Deploy Docker container
* ✅ **Health Check** — Validate application
* ✅ **Post Action** — Display executing agent

---

## 🖥️ Pipeline View

* Installed **Pipeline Stage View** plugin for graphical build visualization.
* SCM Polling set to poll GitHub every 1 minute.
* Can scale horizontally by simply adding more agent pods.

---

## 🔗 Tech Stack Used

* Kubernetes (K8s)
* Jenkins (Master-Agent Architecture)
* Docker
* SSH Authentication
* GitHub (Source Control)

---

✅ **This project helps simulate a production-grade distributed CI/CD system inside Kubernetes.**

---

# Developed by: **Sayantan Samanta**
