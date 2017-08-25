#!/bin/bash
set -e

if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
## install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
## Install helm
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.6.0-linux-amd64.tar.gz
tar -zxvf helm-v2.6.0-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
# Credentials to GCE
gcloud auth  activate-service-account  --key-file=$TRAVIS_BUILD_DIR/eh-test-44e7d0ea33e2.json
gcloud container clusters get-credentials cluster-1 --zone europe-west1-b --project eh-test-176611
#get helm charts
git clone https://$GITHUB_TOKEN@github.com/edenlabllc/ehealth.charts.git
cd ehealth.charts
git checkout charts_for_tests
#get version and project name
PROJECT_NAME=$(sed -n 's/.*app: :\([^, ]*\).*/\1/pg' "$TRAVIS_BUILD_DIR/mix.exs")
#PROJECT_VERSION=$(sed -n 's/.*@version "\([^"]*\)".*/\1/pg' "$TRAVIS_BUILD_DIR/mix.exs")
PROJECT_VERSION="0.1.261"
sed -i'' -e "1,10s/tag:.*/tag: \"$PROJECT_VERSION\"/g" "$Chart/values.yaml"
helm upgrade  -f $Chart/values.yaml  $Chart $Chart 
cd $TRAVIS_BUILD_DIR/bin
./wait-for-deployment.sh api $Chart 18
   if [ "$?" -eq 0 ]; then
     kubectl get pod -n$Chart | grep api 
     cd $TRAVIS_BUILD_DIR/ehealth.charts && git add . && sudo  git commit -m "Bump $Chart version $PROJECT_VERSION" && sudo git pull && sudo git push
     exit 0
   else 
   	 kubectl logs $(sudo kubectl get pod -n$Chart | awk '{ print $1 }' | grep api) -n$Chart 
   	 helm rollback $Chart  $(($(helm ls | grep $Chart | awk '{ print $2 }') -1)) 
   	 exit 1
   fi;
fi;