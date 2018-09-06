#!/bin/bash
. testsuite.sh

FAN_RPM=2880

OVER_FAN=$((FAN_RPM+1))
UNDER_FAN=$((FAN_RPM-1))

OK_RANGE=$((FAN_RPM-1)):$((FAN_RPM+1))
UNDER_RANGE=$((FAN_RPM-2)):$((FAN_RPM-1))
OVER_RANGE=$((FAN_RPM+1)):$((FAN_RPM+2))
ILLEGAL_RANGE="gibberish"

## arguments
# no fan argument
COMMAND="bash check_fan -H localhost -w 20 -c 10"
expect_error "$COMMAND" "Error if no fan given"

 #fan does not exist argument
COMMAND="bash check_fan -n 9 -H localhost"
expect_error "$COMMAND" "Error if invalid fan given"

# no hostname argument
COMMAND="bash check_fan -n 1 -w 20 -c 10"
expect_error "$COMMAND" "Error if no hostname given"

##fan speed
# warning if rpm over warning threshold
COMMAND="bash check_fan -H localhost -n 1 -w $UNDER_FAN "
expect_nagios_warning "$COMMAND" "Warning if rpm over threshold"

# critical if rpm over critical threshold
COMMAND="bash check_fan -H localhost -n 1 -c $UNDER_FAN "
expect_nagios_critical "$COMMAND" "Warning if rpm over threshold"

# ok if rpm inside range
COMMAND="bash check_fan -H localhost -n 1 -w \~:"$OVER_FAN""
expect_nagios_ok "$COMMAND" "Ok if rpm outside range"

# ok if rpm is exactly like threshold
COMMAND="bash check_fan -H localhost -n 1 -c $FAN_RPM -w $FAN_RPM"
expect_nagios_ok "$COMMAND" "OK if rpm is exactly like threshold"

# within warning range
COMMAND="bash check_fan -H localhost -n 1 -w $OK_RANGE"
expect_nagios_ok "$COMMAND" "Ok if rpm inside warning range"

# within critical range
COMMAND="bash check_fan -H localhost -n 1 -c $OK_RANGE"
expect_nagios_ok "$COMMAND" "Ok if rpm inside critical range"

# illegal range
COMMAND="bash check_fan -H localhost -n 1 -c "$ILLEGAL_RANGE""
expect_error "$COMMAND" "Error on illegal range"

# exactly like range
COMMAND="bash check_fan -H localhost -n 1 -c $FAN_RPM:$FAN_RPM"
expect_nagios_ok "$COMMAND" "Ok if rpm exactly like critical range"

# within critical range and within warning range
COMMAND="bash check_fan -H localhost -n 1 -w $OK_RANGE -c $OK_RANGE"
expect_nagios_ok "$COMMAND" "Ok if rpm inside critical range"

# under warning range
COMMAND="bash check_fan -H localhost -n 1 -w $UNDER_RANGE"
expect_nagios_warning "$COMMAND" "Warning if rpm under warning range"

# over critical range
COMMAND="bash check_fan -H localhost -n 1 -c $OVER_RANGE"
expect_nagios_critical "$COMMAND" "Critical if rpm over critical range"

# outside warning and critical range
COMMAND="bash check_fan -H localhost -n 1 -w $OVER_RANGE -c $UNDER_RANGE"
expect_nagios_critical "$COMMAND" "Critical if rpm outside critical range and warning range"
