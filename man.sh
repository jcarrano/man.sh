#!/bin/sh
# Copyright 2011 Juan I Carrano <juan@superfreak.com.ar>

PINF=${PATH_INFO-"/"}

w404() {
	cat <<HTDOC
Status: 404 Not Found
Content-type: text/plain

$1
HTDOC
}

printman() {
#	echo "${1}"
	if MFILE="$(echo "${1}" | xargs man -W | grep -v '/var/cache')" ; then
		bzcat "${MFILE}" | man2html -H H -M H | sed -r \
's/http\:\/\/HH\?([[:digit:]]+)\+(.+)/\.\/\1~\2/g;'\
's/<TABLE>/<TABLE class="listing" style="width: auto;">/;'\
's/<BODY>/<BODY style="color:#eeeeee;">/;'\
's/HREF\=\"file:\/usr\/include\/([^\/]+\/)?(.*)\"/HREF\=\".\/\2\"/g;'\
's/<\/HEAD>/<link href="..\/cosas\/simple.css" rel="stylesheet" type="text\/css" title="default" id="style" \/><\/HEAD>/'
		return 1
	else
		return 0
	fi
}

REQ="$(echo "${PINF}" | sed -n -r 'y/~/ /;y/\// /;s/[ -]*([[:alnum:]_.+-]+([ ]+[[:alnum:]_.+]+[[:alnum:]_.+-]*)?)(.*)/\1/p' )"

main() {
	if ERRCOND="$(printman "${1}" 3>&1 1>&2 2>&3 3>&-)" ; then
		w404 "${ERRCOND}" 1>&2
	fi
}

if [ "x${REQ}" != "x" ] ; then
	main "${REQ}" 2>&1
else
	cat <<HTDOC
Status: 200 Ok
Content-type: text/plain

Manual Page Browser by Juan Carrano
HTDOC
fi

#echo  "${PATH_INFO}" "-" "${PINF}"  "-" "${REQ}"
#sed 2>&1
#echo "${PINF}" | sed -n -r 'y/~/ /;y/\// /;s/[ -]*([[:alnum:]_.+-]+([ ]+[[:alnum:]_.+]+[[:alnum:]_.+-]*)?)(.*)/\1/p' 2>&1
