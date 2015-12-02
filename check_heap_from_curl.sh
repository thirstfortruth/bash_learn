#!/bin/bash
USAGE="USAGE: $0"; ||
curl -s 'http://rtl-wl-ext-td1.konzum.hr:9512/platform/statistics/metrics' |sed 's/,/\n/g'|egrep -e 'jvm.memory.heap.(max|used)';
