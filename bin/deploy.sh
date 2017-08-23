#!/bin/bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
ls $TRAVIS_BUILD_DIR/priv
ls $TRAVIS_BUILD_DIR
gcloud auth  activate-service-account  --key-file= "${GOOGLE_APPLICATION_CREDENTIALS}"
gcloud container clusters get-credentials cluster-1 --zone europe-west1-b --project eh-test-176611
kubectl get pod --all-namespaces=true