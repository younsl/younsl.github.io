#!/bin/bash

# Chart Releaser Script
HELM_REPOSITORY_URL="https://younsl.xyz/"

# Prompt for chart name
read -p "Enter chart name to release: " CHART_NAME

echo "[1/5] Validating Helm chart ..."
if ! helm lint ${CHART_NAME}; then
    echo "Error: ${CHART_NAME} chart validation failed"
    exit 1
fi
echo "[1/5] ${CHART_NAME} chart validation complete"

echo "[2/5] Packaging Helm chart ..."
echo "Current directory: $(pwd)"
helm package ${CHART_NAME} --destination .
echo "[2/5] Chart packaging complete"

echo "[3/5] Moving to static directory ..."
cd ../../static

echo "[4/5] Updating Helm repository index ..."
helm repo index ../content/charts/ --url ${HELM_REPOSITORY_URL}
echo "[4/5] index.yaml created"

echo "[5/5] Moving index.yaml to static directory ..."
mv ../content/charts/index.yaml ./index.yaml
echo "[5/5] Chart release complete"