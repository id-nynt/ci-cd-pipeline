#!/bin/bash

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    echo "[rollback] FAIL: environment not specified"
    exit 1
fi

if [ "$ENVIRONMENT" != "production" ]; then
    echo "[rollback] FAIL: can only rollback production"
    exit 1
fi

# Get previous version
PREVIOUS=$(cat state/previous_production_version.txt 2>/dev/null)

if [ -z "$PREVIOUS" ]; then
    echo "[rollback] FAIL: no previous version found"
    exit 1
fi

# Check previous version folder exists
if [ ! -d "app/$PREVIOUS" ]; then
    echo "[rollback] FAIL: app/$PREVIOUS does not exist"
    exit 1
fi

# Restore from previous version
rm -f "deployments/$ENVIRONMENT"/*
cp "app/$PREVIOUS/config.json" "deployments/$ENVIRONMENT/"
cp "app/$PREVIOUS/health.txt" "deployments/$ENVIRONMENT/"
cp "app/$PREVIOUS/index.html" "deployments/$ENVIRONMENT/"

# Update state to previous version
echo "$PREVIOUS" > "state/production_version.txt"

# Clean up force-fail flag
rm -f "state/force_production_health_failure"

echo "[rollback] PASS: restored $ENVIRONMENT to $PREVIOUS"
exit 0