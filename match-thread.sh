#!/bin/bash

#
# If a mail message has a References: value found in the refs file, then
# add the requested header.
#
# Usage:
#
# cat mail_msgs | match-thread.sh ~/.mail.refs.muted "Muted: true"
#

ref_file="$1"
header="$2"

mail=/tmp/match-thread.mail.$$
cat - >$mail

newrefs="$(cat $mail | formail -x references -x message-id | tr -d '\n')"

touch $ref_file

cat $ref_file | awk -v newrefs="$newrefs" '

	BEGIN {
		found = 0;
		split(newrefs, tmp);
		for (i in tmp) {
			refs[tmp[i]]++;
		}
	}

	# Each thread will have one line in the ref file, with
	# space-separated references. So we just need to look for any
	# reference from the mail.
	{
		for (ref in refs) {
			if (index($0, ref) != 0) {
				found = 1;
				exit(0);
			}
		}
	}

	END {
		exit(found ? 0 : 1);
	}
'

if [[ $? = 0 ]]; then
	cat $mail | formail -i "$header"
else
	cat $mail
fi
