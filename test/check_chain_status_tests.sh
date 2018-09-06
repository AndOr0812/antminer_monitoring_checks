#!/bin/bash
. testsuite.sh

# chain is ok
COMMAND="bash check_chain_status -H localhost -n 1"
expect_nagios_ok "$COMMAND" "Ok if chain status is ok"

# chain is no ok
COMMAND="bash check_chain_status -H localhost -n 2"
expect_nagios_critical "$COMMAND" "Critical if chain status is not ok"

# chain does not exist
COMMAND="bash check_chain_status -H localhost -n 9"
expect_error "$COMMAND" "Error if chain does not exist"
