Create network
```
gcloud compute networks create jenkins --mode auto
```

View ip range:
```
gcloud compute networks subnets list | grep jenkins | grep europe-west1
```

Create firewall rules:
```
gcloud compute firewall-rules create jenkins-fw --network jenkins --allow tcp,udp,icmp --source-ranges <ip range>
gcloud compute firewall-rules create jenkins-fw-ext --network jenkins --allow tcp:22,tcp:3389,icmp
```

Create cluster:
```
gcloud container clusters create jenkins-cd -z europe-west1-d --network jenkins --scopes "storage-rw,cloud-platform" --num-nodes=3
```

Provision persistent disk:
```
gcloud compute disks create --size=100GB --zone=europe-west1-d jenkins-home
```

Create controller:
```
kubectl create namespace jenkins
kubectl create -f jenkins-service.yaml
kubectl create -f jenkins-volume.yaml
kubectl create -f jenkins-claim.yaml
kubectl create -f jenkins-secret.yaml
kubectl create -f jenkins.yaml
```

To get password for the ui, run:
```
kubectl exec <pod name> --namespace jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

Make sure to "enable proxy compatibility" in Manage Jenkins → Configure Global Security → Crumbs Algortithm

Install and configure kubernetes plugin
https://cloud.google.com/solutions/configuring-jenkins-container-engine