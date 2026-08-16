#!/bin/bash

ENVIRONMENT=$1
VERSION=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$VERSION" ]; then
    echo "[deploy] FAIL: environment and version required"
    exit 1
fi

# Validate environment
if [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "production" ]; then
    echo "[deploy] FAIL: invalid environment"
    exit 1
fi

# Check source version exists
if [ ! -d "app/$VERSION" ]; then
    echo "[deploy] FAIL: app/$VERSION does not exist"
    exit 1
fi

# For production, save previous version
if [ "$ENVIRONMENT" = "production" ]; then
    CURRENT=$(cat state/production_version.txt 2>/dev/null)
    if [ -n "$CURRENT" ]; then
        echo "$CURRENT" > state/previous_production_version.txt
    fi
fi

# Copy files to deployment folder
rm -f "deployments/$ENVIRONMENT"/*
cp "app/$VERSION/config.json" "deployments/$ENVIRONMENT/"
cp "app/$VERSION/health.txt" "deployments/$ENVIRONMENT/"
cp "app/$VERSION/index.html" "deployments/$ENVIRONMENT/"

# Update state file
echo "$VERSION" > "state/${ENVIRONMENT}_version.txt"

echo "[deploy] PASS: deployed $VERSION to $ENVIRONMENT"
exit 0