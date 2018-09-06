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
OUTPUT=$(bash check_fan -H localhost -w 20 -c 10 2>&1)
expect_error "$OUTPUT" "Error if no fan given"

 #fan does not exist argument
OUTPUT=$(bash check_fan -n 9 -H localhost 2>&1)
expect_error "$OUTPUT" "Error if invalid fan given"

# no hostname argument
OUTPUT=$(bash check_fan -n 1 -w 20 -c 10 2>&1)
expect_error "$OUTPUT" "Error if no hostname given"

##fan speed
# warning if rpm over warning threshold
OUTPUT=$(bash check_fan -H localhost -n 1 -w $UNDER_FAN  2>&1)
expect_nagios_warning "$OUTPUT" "Warning if rpm over threshold"

# critical if rpm over critical threshold
OUTPUT=$(bash check_fan -H localhost -n 1 -c $UNDER_FAN  2>&1)
expect_nagios_critical "$OUTPUT" "Warning if rpm over threshold"

# ok if rpm inside range
OUTPUT=$(bash check_fan -H localhost -n 1 -w ~:"$OVER_FAN"  2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm outside range"

# ok if rpm is exactly like threshold
OUTPUT=$(bash check_fan -H localhost -n 1 -c $FAN_RPM -w $FAN_RPM  2>&1)
expect_nagios_ok "$OUTPUT" "OK if rpm is exactly like threshold"

# within warning range
OUTPUT=$(bash check_fan -H localhost -n 1 -w $OK_RANGE 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm inside warning range"

# within critical range
OUTPUT=$(bash check_fan -H localhost -n 1 -c $OK_RANGE 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm inside critical range"

# illegal range
OUTPUT=$(bash check_fan -H localhost -n 1 -c "$ILLEGAL_RANGE" 2>&1)
expect_error "$OUTPUT" "Error on illegal range"

# exactly like range
OUTPUT=$(bash check_fan -H localhost -n 1 -c $FAN_RPM:$FAN_RPM 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm exactly like critical range"

# within critical range and within warning range
OUTPUT=$(bash check_fan -H localhost -n 1 -w $OK_RANGE -c $OK_RANGE 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm inside critical range"

# under warning range
OUTPUT=$(bash check_fan -H localhost -n 1 -w $UNDER_RANGE 2>&1)
expect_nagios_warning "$OUTPUT" "Warning if rpm under warning range"

# over critical range
OUTPUT=$(bash check_fan -H localhost -n 1 -c $OVER_RANGE 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if rpm over critical range"

# outside warning and critical range
OUTPUT=$(bash check_fan -H localhost -n 1 -w $OVER_RANGE -c $UNDER_RANGE 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if rpm outside critical range and warning range"
