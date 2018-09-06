#!/bin/bash
. testsuite.sh

# chain is ok
OUTPUT=$(bash check_chain_status -H localhost -n 1 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if chain status is ok"

# chain is no ok
OUTPUT=$(bash check_chain_status -H localhost -n 2 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if chain status is not ok"

# chain does not exist
OUTPUT=$(bash check_chain_status -H localhost -n 9 2>&1)
expect_error "$OUTPUT" "Error if chain does not exist"

