#!/bin/bash

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    ENVIRONMENT="production"
fi

if [ "$ENVIRONMENT" != "production" ]; then
    echo "[inject-failure] FAIL: only production failure injection is supported"
    exit 1
fi

touch state/force_production_health_failure
echo "[inject-failure] PASS: production health check will fail"
exit 0
