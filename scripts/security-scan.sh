#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "[security] FAIL: version not specified"
    exit 1
fi

# Search for hardcoded password patterns
if grep -r "password.*=" "app/$VERSION/" | grep -v "passwordField"; then
    echo "[security] FAIL: hardcoded password found"
    exit 1
fi

# Search for hardcoded API key patterns
if grep -r "api_key.*=" "app/$VERSION/" | grep -v "apiKeyField"; then
    echo "[security] FAIL: hardcoded API key found"
    exit 1
fi

# Search for AWS key patterns
if grep -r "AKIA" "app/$VERSION/"; then
    echo "[security] FAIL: AWS key pattern found"
    exit 1
fi

echo "[security] PASS"
exit 0