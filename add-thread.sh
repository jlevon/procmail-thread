#!/bin/bash

#
# Add one or more mail messages to a file containing a list of
# references. The file can then be matched against with match-thread.sh
# NB: no locking!
#
# Usage:
#
# cat mail_msgs | add-thread.sh ~/.mail.refs.muted
#

ref_file=$1

newrefs="$(formail -x references -x message-id | tr -d '\n')"

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
	# space-separated references. So, to add a thread, we need to
	# see if any of its refs are already present, and if so, update
	# the line with any new references.  Although we should
	# probably have the reference of the original email of the
	# thread already, this avoids having to try to figure that out.
	{
		for (ref in refs) {
			if (index($0, ref) != 0) {
				split($0, tmp);
				for (i in tmp) {
					refs[tmp[i]]++;
				}

				for (ref in refs) {
					printf "%s ", ref;
				}
				printf "\n";
				found = 1;
				next;
			}
		}

		print;
	}

	END {
		if (!found) {
			for (ref in refs) {
				printf "%s ", ref;
			}
			printf "\n";
		}
	}
' >$ref_file.tmp

mv $ref_file.tmp $ref_file
