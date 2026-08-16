#!/bin/bash

echo "=========================================="
echo "LOCAL PIPELINE STATE"
echo "=========================================="

echo ""
echo "Production version:"
cat state/production_version.txt 2>/dev/null || echo "(missing)"

echo ""
echo "Previous production version:"
cat state/previous_production_version.txt 2>/dev/null || echo "(missing)"

echo ""
echo "Staging version:"
cat state/staging_version.txt 2>/dev/null || echo "(missing)"

echo ""
echo "Production deployed config version:"
grep '"version"' deployments/production/config.json 2>/dev/null || echo "(missing)"

echo ""
echo "Staging deployed config version:"
grep '"version"' deployments/staging/config.json 2>/dev/null || echo "(missing)"

echo ""
echo "Forced production health failure:"
if [ -f state/force_production_health_failure ]; then
    echo "enabled"
else
    echo "disabled"
fi

echo "=========================================="
exit 0
