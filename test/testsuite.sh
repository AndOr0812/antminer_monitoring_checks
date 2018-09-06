FIXTURE_DIR="$( cd "$(dirname "${BASH_bash[0]}")" ; pwd -P )/fixture/bin"
export PATH="$FIXTURE_DIR:$PATH"

RED='\033[0;31m'
GREEN='\033[0;32m'
GRAY='\033[0;37m'
NC='\033[0m'

## exit statuses recognized by Nagios
OK=0
WARNING=1
CRITICAL=2
UNKNOWN=3

test_failed () {
echo -e "${RED}TEST_FAILED${NC} -  $1"
}

test_passed () {
echo -e "${GREEN}TEST_PASSED${NC} - $1"
}

expect_value () {
if [[ $2 =~ $1 ]]
then
	echo -e "${GREEN}TEST_PASSED${NC} - $3"
else
	echo -e "${RED}TEST_FAILED${NC} - $3 - Output: $2"
fi
}

expect_error () {
perform_check "${UNKNOWN}" ".*ERROR" "$1" "$2"
}

expect_no_error () {
perform_check "${UNKNOWN}" ".*[^ERROR]*" "$1" "$2"
}

expect_nagios_warning () {
perform_check "${WARNING}" "^WARNING" "$1" "$2"
}

expect_nagios_ok () {
perform_check "${OK}" "^OK" "$1" "$2"
}

expect_nagios_critical () {
perform_check "${CRITICAL}" "^CRITICAL" "$1" "$2"
}

perform_check () {
ASSERT_RETVAL=$1
OUTPUT_REGEXP=$2
COMMAND=$3
TEST_DESCRIPTION=$4
OUTPUT=$(eval $COMMAND 2>&1)
RETVAL=$?

if [[ $RETVAL -ne $ASSERT_RETVAL ]]; then
	test_failed "${GRAY}$TEST_DESCRIPTION${NC} - Wrong Returncode. Expected: ${ASSERT_RETVAL}, got: ${RETVAL} - Output: ${OUTPUT}"
elif ! [[ $OUTPUT =~ $OUTPUT_REGEXP ]]; then
	test_failed "${GRAY}$TEST_DESCRIPTION${NC} - Output did not match ${OUTPUT_REGEXP} - Output: ${OUTPUT}"
else
	test_passed "${GRAY}$TEST_DESCRIPTION${NC} - Output: ${OUTPUT} - Returncode: ${?}"
fi
}

cd ..
