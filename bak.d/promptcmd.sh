#

# get path settings, etc
#
[[ "$GORC" ]] || return 5
test -e $GORC || return 10
test -r $GORC || return 13
source $GORC  || return 15

now_time_t="$(date +%s)"
now_timefmt="$(date -d @$now_time_t +$HISTTIMEFORMAT)"

logvals=(
	$GOASSOC
	$now_timefmt
	$GOTTY_TYPE
	$GOTTY_NUM
	$SHLVL
	$1 # passed by shell in `$PROMPT_COMMAND': previous command result code
)

HISTTIMEFORMAT="%s " history 1 | (
	read -r num time_t command # must use raw or '\n' etc will log as 'n'
	((time_t < GOSTART)) && exit		        # already logged
	echo ${logvals[@]} "$command" >> $GOLOG_CMDS	# logfile1
	echo ${logvals[@]} "$command" >> $GOLOG_MOST	# logfile2
	for file in $GOLOG_FULL $GOLOG_BASH; do		# logfile3, logfile4
		printf "#%u\n%s\n" \
			"$time_t" \
			"$command" \
		>> $file
	done
)
