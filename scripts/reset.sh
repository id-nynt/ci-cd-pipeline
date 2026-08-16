#!/bin/bash

echo "[reset] Resetting local CI/CD demo state..."

mkdir -p deployments/staging
mkdir -p deployments/production
mkdir -p state

rm -f deployments/staging/*
rm -f deployments/production/*
rm -f state/force_production_health_failure
rm -f state/staging_version.txt

cp app/v1/config.json deployments/production/
cp app/v1/health.txt deployments/production/
cp app/v1/index.html deployments/production/

echo "v1" > state/production_version.txt
echo "v1" > state/previous_production_version.txt

echo "[reset] PASS: production reset to v1"
exit 0
