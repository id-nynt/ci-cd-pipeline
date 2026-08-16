#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "[build] FAIL: version not specified"
    exit 1
fi

# Check version folder exists
if [ ! -d "app/$VERSION" ]; then
    echo "[build] FAIL: app/$VERSION does not exist"
    exit 1
fi

# Check config.json exists
if [ ! -f "app/$VERSION/config.json" ]; then
    echo "[build] FAIL: app/$VERSION/config.json does not exist"
    exit 1
fi

# Check config contains version field
if ! grep -q '"version"' "app/$VERSION/config.json"; then
    echo "[build] FAIL: config.json missing version field"
    exit 1
fi

echo "[build] PASS"
exit 0