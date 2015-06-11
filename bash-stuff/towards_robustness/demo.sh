#!/bin/bash
# use bin/bash instead of bin/sh to avoid ambiguity

# most ideas come from 
# * http://www.davidpashley.com/articles/writing-robust-shell-scripts/
# * http://google.github.io/styleguide/shell.xml

export LC_ALL=C # reset all locale settings to avoid unexpected results of sorting or comparing

# options to exit early in case of error
# man bash for more options
set -o nounset # readable version of "set -u"
set -o errexit # readable version of "set -e", disabled by "set +e"
set -o pipefail

# turn an "if-else" statement into a "condition || false_action && true_action" statement.  # it's compact especially when condition is exit status of a command. 
[[ $# -eq 1 ]] || { echo "Usage: $0 ARG"; exit 1; } && { ARG=$1; } 
echo "ARG:$ARG"

# allow some commands to return non-zero status by putting them between "set +e" and "set -e"
set +e
grep "^	$" tmp.txt # grep return non-zero if tmp.txt does not exist or does not match the specified pattern
set -e

# mkdir: use -p to create necessary parent directories 
mkdir -p foo/bar

# rm: use -f to continue siliently even if the specified file does not exist
rm -f tmp.txt

# LOCK implementation:
# * trap statement provides a similar semantic ability with "exception" statement in some advanced languages like java or python
# * use IO redirection and bash’s noclobber mode to avoid race condition 
LOCK_FILE=LOCK_XXX
if (set -o noclobber; echo "$$" > "${LOCK_FILE}") 2> /dev/null; 
then
	trap 'rm -f "${LOCK_FILE}"; exit 3' INT TERM EXIT # more signals can be seen by running "kill -l"
	#grep "^	$" $0 # critical section
	rm -f "${LOCK_FILE}" # unlock
	trap - INT TERM EXIT
else
	echo "failed to get the lock! lock was held by process $( cat ${LOCK_FILE} )" >&2
fi

# Online service updating with "atomic" operation:
# * double the storage resources, get the update version ready in advance
# * maximize the availabity by reducing the unavailable time to two mv operations
rm -rf online_data_tmp
cp -a online_data online_data_tmp
# update process
for file in $(find online_data_tmp -type f -name "*.html"); do
	perl -pi -e 's/www.a.com/www.b.com/g' ${file}
done
rm -rf online_data_old
mv online_data online_data_old
mv online_data_tmp online_data

exit 0
