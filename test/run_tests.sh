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
FAN1_RPM=2880

## arguments
# no fan argument
OUTPUT=$(source check_fan -H localhost -w 20 -c 10 2>&1)
expect_error "$OUTPUT" "Error if no fan given"

# no hostname argument
OUTPUT=$(source check_fan -f 1 -w 20 -c 10 2>&1)
expect_error "$OUTPUT" "Error if no hostname given"

# no warning argument
OUTPUT=$(source check_fan -H localhost -f 1 -c 10 2>&1)
expect_error "$OUTPUT" "Error if no warning given"

# no critical argument
OUTPUT=$(source check_fan -H localhost -f 1 -w 10 2>&1)
expect_error "$OUTPUT" "Error if no critical given"

## thresholds
# warning lower than critical
OUTPUT=$(source check_fan -H localhost -f 1 -c 20 -w 10 2>&1)
expect_error "$OUTPUT" "Error if warning lower than critical"

# warning higher than critical
OUTPUT=$(source check_fan -H localhost -f 1 -c 10 -w 20 2>&1)
expect_no_error "$OUTPUT" "No error if warning higher than critical"

## reverse thresholds
# warning lower than critical
OUTPUT=$(source check_fan -H localhost -f 1 -c 20 -w 10 -t 2>&1)
expect_no_error "$OUTPUT" "No error if warning lower than critical"

# warning higher than critical
OUTPUT=$(source check_fan -H localhost -f 1 -c 10 -w 20 -t 2>&1)
expect_error "$OUTPUT" "Error if warning higher than critical"

##fan speed
# ok if rpm over threshold
OUTPUT=$(source check_fan -H localhost -f 1 -c 10 -w 20 2>&1)
expect_nagios_ok "$OUTPUT" "OK if rpm over threshold"

# warning threshold undershot
OUTPUT=$(source check_fan -H localhost -f 1 -c 0 -w 9999 2>&1)
expect_nagios_warning "$OUTPUT" "Warning if warning lower than fan rpm"

# critical threshold undershot
OUTPUT=$(source check_fan -H localhost -f 1 -c 8888 -w 9999 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if critical lower than fan rpm"

##reverse fan speed
# ok if rpm under threshold
OUTPUT=$(source check_fan -H localhost -f 1 -c 9999 -w 8888 -t 2>&1)
expect_nagios_ok "$OUTPUT" "OK if rpm under threshold"

# warning threshold exceed
OUTPUT=$(source check_fan -H localhost -f 1 -c 9999 -w 10 -t 2>&1)
expect_nagios_warning "$OUTPUT" "Warning if warning higher than fan rpm"

# critical threshold exceed
OUTPUT=$(source check_fan -H localhost -f 1 -c 20 -w 10 -t 2>&1)
expect_nagios_critical "$OUTPUT" "Critical if critical higher than fan rpm"
