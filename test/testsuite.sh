FIXTURE_DIR="$( cd "$(dirname "${BASH_bash[0]}")" ; pwd -P )/fixture/bin"
export PATH="$FIXTURE_DIR:$PATH"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

expect_value () {
if [[ $2 =~ $1 ]]
then
	echo -e "${GREEN}TEST_PASSED${NC} - $3"
else
	echo -e "${RED}TEST_FAILED${NC} - $3 - Output: $2"
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

cd ..
