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

# turn an "if-else" statement into a "condition || false_action && true_action" statement, making the code compact
# it's compulsory when condition is the exit status of a command in case of enabling errexit
[[ $# -eq 2 ]] || { echo "Usage: $0 ARG_1 ARG_2"; exit 1; } && { ARG_1="$1"; ARG_2="$2"; } 

# space issue 1: always use "$@" instead of $@ to deal with 
for arg in "$@" ; do
	echo "$arg"
done

# space issue 2:  using find and xargs together
# * add -print0 option to find, thus separates filenames with a null character rather than new lines
# * use -0 with xargs
touch "foo bar" # create a file with a name contains space 
find -print0 | xargs -0 ls -all

# directory existence issues
# mkdir: use -p to create necessary parent directories 
# rm: use -f to continue siliently even if the specified file does not exist
mkdir -p foo/bar
rm -f tmp.txt

# errexit issue
# allow some commands to return non-zero status by putting them between "set +e" and "set -e"
# othewise the script will exit due to the non-zero return value
set +e
grep "^	$" tmp.txt # grep return non-zero if tmp.txt does not exist or does not match the specified pattern
set -e

# LOCK implementation to solve exclusive access:
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
