#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/logger.sh"
source "$PROJECT_ROOT/lib/alert_manager.sh"

TEST_KEY="automated_test"

echo "TEST 1: First breach"
record_breach "$TEST_KEY" "Automated test incident"

echo "TEST 2: Second breach"
record_breach "$TEST_KEY" "Automated test incident"

echo "TEST 3: Third breach - should trigger triage"
record_breach "$TEST_KEY" "Automated test incident"

if ! grep -q "^${TEST_KEY}|3|" "$PROJECT_ROOT/state/alerts.state"; then
    echo "FAIL: Breach counter did not reach 3"
    exit 1
fi

echo "PASS: Three consecutive breaches recorded"

echo "TEST 4: Recovery"
resolve_breach "$TEST_KEY"

if grep -q "^${TEST_KEY}|" "$PROJECT_ROOT/state/alerts.state"; then
    echo "FAIL: Recovery did not clear alert state"
    exit 1
fi

echo "PASS: Recovery cleared alert state"
echo "ALL ALERT TESTS PASSED"
