#!/bin/bash
FIXTURE_DIR="$( cd "$(dirname "${BASH_bash[0]}")" ; pwd -P )/fixture/bin"
export PATH="$FIXTURE_DIR:$PATH"

expect_value () {
if [[ $2 =~ $1 ]]
then
	echo "TEST_PASSED - $3"
else
	echo "TEST_FAILED - $3 - Output: $2"
fi
}

expect_error () {
expect_value ".*ERROR*" "$1" "$2"
}

expect_no_error () {
expect_value ".*[^ERROR]*" "$1" "$2"
}

expect_nagios_ok () {
expect_value "^OK*" "$1" "$2"
}

expect_nagios_warning () {
expect_value "^WARNING*" "$1" "$2"
}

expect_nagios_critical () {
expect_value "^CRITICAL*" "$1" "$2"
}



not_expect_value () {
if ! [[ $1 =~ .*$1* ]]
then
	echo "TEST_PASSED - $3"
else
	echo "TEST_FAILED - $3 - Output: $2"
fi

}


cd ..

    #_           _      __           
 #__| |_  ___ __| |__  / _|__ _ _ _  
#/ _| ' \/ -_) _| / / |  _/ _` | ' \ 
#\__|_||_\___\__|_\_\_|_| \__,_|_||_|
                  #|___|             
echo "check_fan tests.."
FAN_RPM=2880

OVER_FAN=$((FAN_RPM+1))
UNDER_FAN=$((FAN_RPM-1))
echo $UNDER_FAN

OK_RANGE=$((FAN_RPM-1)):$((FAN_RPM+1))
UNDER_RANGE=$((FAN_RPM-2)):$((FAN_RPM-1))
OVER_RANGE=$((FAN_RPM+1)):$((FAN_RPM+2))
ILLEGAL_RANGE="20:10"

## arguments
# no fan argument
OUTPUT=$(bash check_fan -H localhost -w 20 -c 10 2>&1)
expect_error "$OUTPUT" "Error if no fan given"

# no hostname argument
OUTPUT=$(bash check_fan -f 1 -w 20 -c 10 2>&1)
expect_error "$OUTPUT" "Error if no hostname given"

##fan speed
# ok if rpm over warning threshold
OUTPUT=$(bash check_fan -H localhost -f 1 -w $UNDER_FAN  2>&1)
expect_nagios_ok "$OUTPUT" "OK if rpm over threshold"

# ok if rpm over critical threshold
OUTPUT=$(bash check_fan -H localhost -f 1 -c $UNDER_FAN  2>&1)
expect_nagios_ok "$OUTPUT" "OK if rpm over threshold"

# ok if rpm is exactly like threshold
OUTPUT=$(bash check_fan -H localhost -f 1 -c $FAN_RPM -w $FAN_RPM  2>&1)
expect_nagios_ok "$OUTPUT" "OK if rpm is exactly like threshold"

# under warning threshold
OUTPUT=$(bash check_fan -H localhost -f 1 -w $OVER_FAN 2>&1)
expect_nagios_warning "$OUTPUT" "Warning if rpm under warning"

# under critical threshold
OUTPUT=$(bash check_fan -H localhost -f 1 -c $OVER_FAN 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if rpm under critical"

# under critical and warning threshold
OUTPUT=$(bash check_fan -H localhost -f 1 -c $OVER_FAN -w $OVER_FAN 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if rpm under warning and critical"

# within warning range
OUTPUT=$(bash check_fan -H localhost -f 1 -w $OK_RANGE 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm inside warning range"

# within critical range
OUTPUT=$(bash check_fan -H localhost -f 1 -c $OK_RANGE 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm inside critical range"

# illegal range
OUTPUT=$(bash check_fan -H localhost -f 1 -c $ILLEGAL_RANGE 2>&1)
expect_error "$OUTPUT" "Error on illegal range"

# illegal range2
OUTPUT=$(bash check_fan -H localhost -f 1 -c "gibberish" 2>&1)
expect_error "$OUTPUT" "Error on another illegal range"

# exactly like range
OUTPUT=$(bash check_fan -H localhost -f 1 -c $FAN_RPM:$FAN_RPM 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm exactly like critical range"

# within critical range and within warning range
OUTPUT=$(bash check_fan -H localhost -f 1 -w $OK_RANGE -c $OK_RANGE 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm inside critical range"

# under warning range
OUTPUT=$(bash check_fan -H localhost -f 1 -w $UNDER_RANGE 2>&1)
expect_nagios_warning "$OUTPUT" "Warning if rpm under warning range"

# over critical range
OUTPUT=$(bash check_fan -H localhost -f 1 -c $OVER_RANGE 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if rpm over critical range"

# outside warning and critical range
OUTPUT=$(bash check_fan -H localhost -f 1 -w $OVER_RANGE -c $UNDER_RANGE 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if rpm outside critical range and warning range"
