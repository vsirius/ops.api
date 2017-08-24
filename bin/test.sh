#!/bin/bash
sed -i '' "1,10s/tag:.*/tag: \"22\"/" "ehealth.charts/ops/values.yaml"
cat ehealth.charts/ops/values.yaml