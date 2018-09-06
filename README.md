# antminer_monitoring_checks

A collection of Nagios plugin checks for monitoring Antminer systems.

## check_fan
Usage:
```
Check for Fan RPM Status of Antminer
Warning and Critical are in Nagios Threshold Format. (10, 10:, 10:20, ~:20, @10:20 etc.)
Usage: check_fan [-p api_port] [-n fan_number] [-H hostname] [-w warning_rpm_range] [-c critical_rpm_range]
Command Summary:
  -c critical_threshold		Critical treshold (range) in RPM
  -n fan_number			Specify Fan number
  -H hostname			Antminer target
  -h				This help text
  -p api_port			Monitoring API Port (Default: 4028)
  -w warning_threshold		Warning threshold (range) in RPM
```

For example check the rpm of Fan 1 and trigger warning if
the current rpm lies outside of 1000 to 3500 rpm

```
check_fan -H antminer.local -w 1000:3500 -f 1
=> OK - FAN1 2880 RPM | FAN1_RPM=2880;1000:3500;
```
## check_chain_status
Usage:
Checks the ASIC status of a chain.
```
Check for Chain Status of Antminer
Usage: check_chain_status [-p api_port] [-n chain_number] [-H hostname]
Command Summary:
  -n chain_number		Specify Chain number
  -H hostname			Antminer target
  -h					This help text
  -p api_port			Monitoring API Port (Default: 4028)
```

Specify the chain number as parameter

```
check_chain_status -H antminer.local -n 3

=> OK - chain 3 status: oooo
or maybe
=> CRITICAL - chain 3 status: xxxx
```

## License Notice
You can redistribute and/or modify this software under the terms of the GNU
General Public License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version; with the
additional exemption that compiling, linking, and/or using OpenSSL is
allowed.

This software is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.

See the `COPYING` file for the complete text of the GNU General Public
License, version 3.
