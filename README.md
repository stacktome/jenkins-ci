Build Infrastructure
====================

Setting up
----------

Provision GCP resources:
```
terraform init
terraform apply

gcloud compute instance-groups set-named-ports `terraform output jenkins-cluster-instance-group` --named-ports jenkins:30000 --zone=europe-west1-d
```

Get cluster credentials:
```
gcloud container clusters get-credentials jenkins
```

Deploy software:
```
kubectl create -f service.yaml
kubectl create -f deployment.yaml
kubectl create -f mock-statsd-exporter-service.yaml
kubectl create -f self-service.yaml
kubectl create -f webdriver-manager-daemonset.yaml
```

Enable IAP via GCP user interface.

Links
-----

* [Kubernetes plugin](https://cloud.google.com/solutions/configuring-jenkins-container-engine)

* [Slack plugin](https://github.com/jenkinsci/slack-plugin)