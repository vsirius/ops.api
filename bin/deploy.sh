#!/bin/bash
## install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
## Install helm
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.6.0-linux-amd64.tar.gz
tar -zxvf helm-v2.0.0-linux-amd64.tgz
mv linux-amd64/helm /usr/local/bin/helm
# Credentials to GCE
gcloud auth  activate-service-account  --key-file=$TRAVIS_BUILD_DIR/eh-test-44e7d0ea33e2.json
gcloud container clusters get-credentials cluster-1 --zone europe-west1-b --project eh-test-176611
kubectl get pod --all-namespaces=true
helm ls
#get helm charts
git clone https://$GITHUB_TOKEN@github.com/edenlabllc/ehealth.charts.git
cd ehealth.charts
ls
git pull
