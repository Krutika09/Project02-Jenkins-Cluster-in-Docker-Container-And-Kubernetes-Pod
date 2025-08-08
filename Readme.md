# 🚀Jenkins Cluster in Docker Container & Kubernetes Pod 

## **PART 1: EC2 INSTANCE SETUP**

### 1. Create EC2 Instance on AWS

* **Type:** `t2.medium`
* **Volume:** 20 GB
* **Security Group:**

  * Inbound: `22`, `80`, `8080`

### 2. Connect to EC2

```bash
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>
```

---

## **PART 2: INSTALL DOCKER & BUILD JENKINS MASTER IMAGE**

### 3. Install Docker on EC2

```bash
sudo apt update -y
sudo apt install docker.io -y
sudo usermod -aG docker $USER
newgrp docker
```

### 4. Build & Push Jenkins Master Image

```bash
docker build -t krutika09/project02-jenkins-master:latest .
docker login
docker push krutika09/project02-jenkins-master:latest
```

---

## **PART 3: RUN JENKINS MASTER CONTAINER**

### 5. Create Jenkins Container

```bash
docker run -d -p 8080:8080 -p 50000:50000 --name jenkins-master \
  -v jenkins_home:/var/jenkins_home \
  krutika09/project02-jenkins-master:latest
```
<img width="1074" height="46" alt="image" src="https://github.com/user-attachments/assets/6414d0b0-6c75-4e84-a082-7c9d2e5227e8" />
<img width="1044" height="43" alt="image" src="https://github.com/user-attachments/assets/f2a7afb3-6f14-434b-8cfa-57f1956e698d" />

### 6. Access Jenkins via Browser

```
http://<your-ec2-public-ip>:8080
```

### 7. Unlock Jenkins

```bash
docker exec -it jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword
```
<img width="789" height="611" alt="image" src="https://github.com/user-attachments/assets/d4391427-56ab-45b7-87cc-473af389bcf5" />

---

## **PART 4: CONFIGURE JENKINS FOR KUBERNETES**

### 8. Install Kubernetes Plugin

* Jenkins UI → `Manage Jenkins` → `Manage Plugins` → Install **Kubernetes**
<img width="1351" height="457" alt="image" src="https://github.com/user-attachments/assets/9a36cd47-a785-47dc-bdf8-e90cb39d4f37" />

### 9. Configure Kubernetes Cloud in Jenkins

* Jenkins UI → `Manage Jenkins` → `Node`

  * Node Name: `K8-Agent-Secrets`
  * Type: `Permanent Agent`
  * Create

<img width="890" height="476" alt="image" src="https://github.com/user-attachments/assets/886c19d8-09aa-4800-848c-8b9c95202bc7" />
<img width="890" height="476" alt="image" src="https://github.com/user-attachments/assets/83b3ed9a-68a4-4526-8362-e914c6a39860" />
<img width="1044" height="201" alt="image" src="https://github.com/user-attachments/assets/c0f2807c-7229-48b8-b292-aeb85f007da6" />
<img width="693" height="263" alt="image" src="https://github.com/user-attachments/assets/8b685f4d-4e40-4d4f-9f1e-015ef2b6f2ff" />

---

## **PART 5: SETUP KUBERNETES ENVIRONMENT (MINIKUBE)**

### 10. Start Minikube

```bash
minikube start -p Jenkins-Agent
```
<img width="952" height="327" alt="image" src="https://github.com/user-attachments/assets/a59df9ed-ad52-4a65-a60a-5bf1eec26dcd" />


### 11. Set Docker Environment to Minikube

**Linux/macOS:**

```bash
eval $(minikube -p Jenkins-Agent docker-env)
```

**Windows (PowerShell):**

```powershell
minikube -p Jenkins-Agent docker-env --shell powershell | Invoke-Expression
```

<img width="931" height="311" alt="image" src="https://github.com/user-attachments/assets/679ba0a5-2177-4e96-99c8-da77684ca72b" />


---

## **PART 6: BUILD & PUSH JENKINS AGENT IMAGE**

### 12. Move to Jenkins Agent Folder

```bash
cd jenkins-agent
```

### 13. Build and Push Jenkins Agent Image

```bash
docker build -t krutika09/project02-jenkins-agent:latest .
docker push krutika09/project02-jenkins-agent:latest
```

---

## **PART 7: DEPLOY JENKINS ON KUBERNETES**

### 14. Apply Kubernetes Manifests

```bash
kubectl apply -f jenkins-PV.yaml
kubectl apply -f jenkins-PVC.yaml
kubectl apply -f jenkins-deployment.yaml
kubectl apply -f jenkins-service.yaml
```

### 15. Verify Deployment

```bash
kubectl get all
```

<img width="665" height="224" alt="image" src="https://github.com/user-attachments/assets/c564e6e2-c4fb-4b69-8c84-14c67a219b71" />


### 16. Get Minikube IP

```bash
minikube ip -p Jenkins-Agent
# e.g., 192.168.59.221
```

### 17. Access Jenkins via Minikube Service

```
http://192.168.59.221:30080
```

### 18. Get Jenkins Initial Admin Password from Pod

```bash
kubectl exec -it <jenkins-pod-name> -- /bin/bash
cat /var/jenkins_home/secrets/initialAdminPassword
```
<img width="921" height="138" alt="image" src="https://github.com/user-attachments/assets/bdfd640d-332a-45d0-87de-b8635f17f862" />


---

## **PART 8: CREATE JENKINS PIPELINE JOB**

### 19. In Jenkins UI:

* Click `New Item` → Enter Job Name → Select **Pipeline**
* Under **Pipeline**:

  * **Definition:** Pipeline script from SCM
  * **SCM:** Git
  * **Repository URL:** `<your-git-repo-url>`
  * **Credentials:** Select GitHub credentials
* Save → Click **Build Now**
<img width="1009" height="588" alt="image" src="https://github.com/user-attachments/assets/39820ec1-9384-47a9-a5c2-5f1e89117143" />
<img width="948" height="462" alt="image" src="https://github.com/user-attachments/assets/f1af7ad1-f7af-4d4d-b5b8-ef8b35a6e787" />
<img width="921" height="532" alt="image" src="https://github.com/user-attachments/assets/a562f788-9f3f-4974-baed-3db30371d5d8" />
<img width="869" height="574" alt="image" src="https://github.com/user-attachments/assets/f7c4cd2d-1795-45ee-8855-456f24fd5c4d" />


---

## ✅ PART 9: YOU DID IT!

* Jenkins pulls code from GitHub
* Builds Docker images using Jenkinsfile
* Deploys to Kubernetes
* Runs Jenkins Agents as Kubernetes pods

---

Let me know if you want a downloadable `README.md` file.
