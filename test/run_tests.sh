#!/bin/bash
FIXTURE_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/fixture/bin"
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

OVER_FAN=$((FAN_RPM++))
UNDER_FAN=$((FAN_RPM--))

OK_RANGE=$((FAN_RPM--)):$((FAN_RPM++))
UNDER_RANGE=$((FAN_RPM-2)):$((FAN_RPM-1))
OVER_RANGE=$((FAN_RPM+1)):$((FAN_RPM+2))

echo $OVER_FAN
echo $UNDER_FAN

echo $OK_RANGE
echo $UNDER_RANGE
echo $OVER_RANGE

## arguments
# no fan argument
OUTPUT=$(source check_fan -H localhost -w 20 -c 10 2>&1)
expect_error "$OUTPUT" "Error if no fan given"

# no hostname argument
OUTPUT=$(source check_fan -f 1 -w 20 -c 10 2>&1)
expect_error "$OUTPUT" "Error if no hostname given"

##fan speed
# ok if rpm over single warning threshold
OUTPUT=$(source check_fan -H localhost -f 1 -w $OVER_FAN  2>&1)
expect_nagios_ok "$OUTPUT" "OK if rpm over threshold"

# warning threshold undershot
OUTPUT=$(source check_fan -H localhost -f 1 -w $UNDER_FAN 2>&1)
expect_nagios_warning "$OUTPUT" "Warning if warning lower than fan rpm"

# critical threshold undershot
output=$(source check_fan -h localhost -f 1 -c $UNDER_FAN 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if critical lower than fan rpm"

# critical threshold undershot and warning undershot
output=$(source check_fan -h localhost -f 1 -c $UNDER_FAN -w $UNDER_FAN 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if critical lower than fan rpm and warning lower than fan rpm"

# within warning range
OUTPUT=$(source check_fan -H localhost -f 1 -w $RANGE_OK 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm insie warning range"

# within critical range
OUTPUT=$(source check_fan -H localhost -f 1 -c $RANGE_OK 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm inside critical range"

# within critical range and within warning range
OUTPUT=$(source check_fan -H localhost -f 1 -w $RANGE_OK -c $RANGE_OK 2>&1)
expect_nagios_ok "$OUTPUT" "Ok if rpm inside critical range"

# under warning range
OUTPUT=$(source check_fan -H localhost -f 1 -w $RANGE_UNDER 2>&1)
expect_nagios_warning "$OUTPUT" "Warning if rpm under warning range"

# over critical range
OUTPUT=$(source check_fan -H localhost -f 1 -w $RANGE_OVER 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if rpm over critical range"

# outside warning and critical eange
OUTPUT=$(source check_fan -H localhost -f 1 -w $RANGE_OVER -c $RANGE_UNDER 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if rpm outside critical range and warning range"
