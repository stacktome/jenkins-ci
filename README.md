Build Infrastructure
====================

Setting up
----------

Provision GCP resources:
```
terraform init
terraform apply

gcloud compute instance-groups set-named-ports `terraform output jenkins-cluster-instance-group` --named-ports jenkins:30000,nexus:30001 --zone=europe-west1-d
```

Get cluster credentials:
```
gcloud container clusters get-credentials jenkins
```

Deploy jenkins:
```
kubectl create -f service.yaml
kubectl create -f deployment.yaml
kubectl create -f mock-statsd-exporter-service.yaml
kubectl create -f self-service.yaml
kubectl create -f webdriver-manager-daemonset.yaml
```

Deploy nexus:
```
helm install --name repo -f nexus-helm-values.yaml stable/sonatype-nexus
kubectl delete svc repo-sonatype-nexus # svc needs to be replaced for assigning NodePort
kubectl create -f nexus-service.yaml
```

Links
-----

* [Kubernetes plugin](https://cloud.google.com/solutions/configuring-jenkins-container-engine)

* [Slack plugin](https://github.com/jenkinsci/slack-plugin)
