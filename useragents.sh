#! /bin/bash
getUserName() {
echo $1 | cut -d : -f 1 | xargs basename
}

asterisk -rx 'sip show peers' | cut -f1 -d/ | grep -P '\d\d\d\d' | grep -vP '(UNKNOWN|Unmonitored)' | grep -v 'Plivo' |
while read PEER
do
asterisk -rx "sip show peer $(getUserName ${PEER})" |
grep -P "(Username|Useragent|Contact)"
echo ";"
done