#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "[tests] FAIL: version not specified"
    exit 1
fi

# Check config contains payment-service
if ! grep -q '"service": "payment-service"' "app/$VERSION/config.json"; then
    echo "[tests] FAIL: config missing payment-service"
    exit 1
fi

# Check health.txt contains OK
if ! grep -q "OK" "app/$VERSION/health.txt"; then
    echo "[tests] FAIL: health.txt does not contain OK"
    exit 1
fi

echo "[tests] PASS"
exit 0