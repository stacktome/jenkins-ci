FROM jenkinsci/jnlp-slave:2.62

ADD ssh_keys/id_rsa /tmp
ADD ssh_keys/id_rsa.pub /tmp

ADD jenkins-slave /usr/local/bin/jenkins-slave

USER root

# I don't know why, but chowns within /home/jenkins take no effect
RUN chown jenkins:jenkins /tmp/id_rsa
RUN chown jenkins:jenkins /tmp/id_rsa.pub

USER jenkins

# docker build -t gcr.io/fuzzylabs-1314/jnlp-slave-infrastructure .
# docker run -it --rm --name=jnlp-slave gcr.io/fuzzylabs-1314/jnlp-slave
# gcloud docker -- push gcr.io/fuzzylabs-1314/jnlp-slave-infrastructure