#!/bin/bash

echo "=========================================="
echo "CI/CD PIPELINE START"
echo "=========================================="

# Reset: ensure production is v1 and local state is clean
echo ""
echo "RESET: Preparing clean local demo state..."
./scripts/reset.sh
if [ $? -ne 0 ]; then
    echo "PIPELINE FAILED at RESET"
    exit 1
fi

# Build
echo ""
echo "BUILD: Building v2..."
./scripts/build.sh v2
if [ $? -ne 0 ]; then
    echo "PIPELINE FAILED at BUILD"
    exit 1
fi

# Test
echo ""
echo "TEST: Testing v2..."
./scripts/run-tests.sh v2
if [ $? -ne 0 ]; then
    echo "PIPELINE FAILED at TEST"
    exit 1
fi

# Security
echo ""
echo "SECURITY: Scanning v2..."
./scripts/security-scan.sh v2
if [ $? -ne 0 ]; then
    echo "PIPELINE FAILED at SECURITY"
    exit 1
fi

# Staging Deployment
echo ""
echo "STAGING DEPLOY: Deploying v2 to staging..."
./scripts/deploy.sh staging v2
if [ $? -ne 0 ]; then
    echo "PIPELINE FAILED at STAGING DEPLOY"
    exit 1
fi

# Staging Health Check
echo ""
echo "STAGING HEALTH: Checking staging health..."
./scripts/health-check.sh staging
if [ $? -ne 0 ]; then
    echo "PIPELINE FAILED at STAGING HEALTH"
    exit 1
fi

# Simulate production failure (force the health check to fail)
echo ""
echo "INJECTING FAILURE: Simulating production health failure..."
./scripts/inject-failure.sh production
if [ $? -ne 0 ]; then
    echo "PIPELINE FAILED at FAILURE INJECTION"
    exit 1
fi

# Production Deployment
echo ""
echo "PRODUCTION DEPLOY: Deploying v2 to production..."
./scripts/deploy.sh production v2
if [ $? -ne 0 ]; then
    echo "PIPELINE FAILED at PRODUCTION DEPLOY"
    exit 1
fi

# Production Health Check
echo ""
echo "PRODUCTION HEALTH: Checking production health..."
./scripts/health-check.sh production
HEALTH_RESULT=$?

if [ $HEALTH_RESULT -ne 0 ]; then
    echo ""
    echo "PRODUCTION HEALTH FAILED"
    echo ""
    echo "TRIGGERING HARDCODED RECOVERY: Rolling back..."
    ./scripts/rollback.sh production
    if [ $? -ne 0 ]; then
        echo "ROLLBACK FAILED"
        exit 1
    fi
else
    echo "PRODUCTION HEALTH PASSED"
fi

# Final verification
echo ""
echo "=========================================="
echo "PIPELINE END: Final State Check"
echo "=========================================="
echo ""
echo "Production version:"
cat state/production_version.txt
echo ""
echo "Production config:"
cat deployments/production/config.json | grep version
echo ""
echo "Previous production version:"
cat state/previous_production_version.txt
echo ""
./scripts/show-state.sh
echo ""
echo "PIPELINE COMPLETED SUCCESSFULLY"
echo "=========================================="
exit 0
