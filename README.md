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

Install and configure Kubernetes plugin
https://cloud.google.com/solutions/configuring-jenkins-container-engine

Install and configure Slack plugin
https://github.com/jenkinsci/slack-plugin


#### Configure build on merge to master on Github

Install and configure Build Token Root Plugin
https://wiki.jenkins-ci.org/display/JENKINS/Build+Token+Root+Plugin

Invent and add build token(s) to all build jobs in Configure → Build Triggers → Trigger builds remotely

Go to target repo page on Github, in Settings → Webhooks set `Payload URL` to `http://jenkins.fuzzylabsresearch.com:8000/?token=<token>&build=<build name>` where `<token>` is the token you have set in jenkins (make sure it does not contain "+", "?" or other confusing characters), `<build name>`is a name of a pipeline in Jenkins that you want the webhook to trigger. Select "Let me select individual events." and tick "Pull request".

Now all merged pull requests into master will automatically trigger builds in Jenkins.