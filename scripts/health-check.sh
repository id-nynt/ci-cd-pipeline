#!/bin/bash

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    echo "[health-check] FAIL: environment not specified"
    exit 1
fi

# Validate environment
if [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "production" ]; then
    echo "[health-check] FAIL: invalid environment"
    exit 1
fi

# For production, check if failure is forced
if [ "$ENVIRONMENT" = "production" ]; then
    if [ -f "state/force_production_health_failure" ]; then
        echo "[health-check] FAIL: forced failure for $ENVIRONMENT"
        exit 1
    fi
fi

# Check if health.txt exists and contains OK
if [ ! -f "deployments/$ENVIRONMENT/health.txt" ]; then
    echo "[health-check] FAIL: $ENVIRONMENT health: health.txt not found"
    exit 1
fi

if grep -q "OK" "deployments/$ENVIRONMENT/health.txt"; then
    echo "[health-check] PASS: $ENVIRONMENT health"
    exit 0
else
    echo "[health-check] FAIL: $ENVIRONMENT health: health check did not return OK"
    exit 1
fi