FROM google/cloud-sdk:alpine

## Helm 2
# RUN curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
# RUN helm init -c


## Helm 3

# variable "VERSION" must be passed as docker environment variables during the image build
# docker build --no-cache --build-arg VERSION=3.2.1 -t eu.gcr.io/stacktome-prod/helm-cloud-sdk:latest .
ARG VERSION


ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${VERSION}-linux-amd64.tar.gz"

RUN apk add --update --no-cache curl ca-certificates && \
    curl -L ${BASE_URL}/${TAR_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 && \
    apk del curl && \
    rm -f /var/cache/apk/*

WORKDIR /apps

ENTRYPOINT ["helm"]
CMD ["--help"]
