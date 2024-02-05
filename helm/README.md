###NEXUS OOS and Jenkins Helm v3 installation

```
helm repo add sonatype https://sonatype.github.io/helm3-charts/
helm repo update
helm upgrade --install --namespace jenkins nexus sonatype/nexus-repository-manager -f ./helm/nexus/values.yaml --version 26.1.1
helm upgrade --install jenkins helm/jenkins -f ./helm/jenkins/production.yaml 
```
