#!/bin/bash
gcloud auth  activate-service-account  --key-file=./priv/eh-test-44e7d0ea33e2.json
gcloud container clusters get-credentials cluster-1 --zone europe-west1-b --project eh-test-176611
kubectl get pod --all-namespaces=true