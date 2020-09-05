###NEXUS OOS Helm v3 installation

```
helm repo add sonatype https://sonatype.github.io/helm3-charts/
helm repo update
helm upgrade --install --namespace jenkins nexus sonatype/nexus-repository-manager -f ./helm/nexus/values.yaml --version 26.1.1
helm upgrade --install --namespace jenkins jenkins helm/jenkins
```