#!/bin/sh
# Copyright 2011 Juan I Carrano <juan@carrano.com.ar>
# Distributed under the terms of the 3-Clause BSD License (see README.rst)
# Call without arguments to use as cgi script
# To render a single page, use man.sh [section] page

PINF=${PATH_INFO-"/"}

w404() {
	cat <<HTDOC
Status: 404 Not Found
Content-type: text/plain

$1
HTDOC
}

sedify() {
	sed 's/\#/\\#/;s/\//\\\//g;s/^[[:blank:]]*//' | tr -d '\n'
}

HEADERBAR0=$(sedify <<HDRB
<div id="globbar" class="bar">
  <div class="parent_lnk">Parent</div>
  <div id="bar_items" class="bar_items">
HDRB
)
HEADERBAR1=$(sedify <<HDRB
  </div>
  <form class="search" action="/" method="get">
     <div>
       <input name="q" type="text"><input value="Search" type="submit">
     </div>
  </form>
</div>
HDRB
)

INDEXSTART=$(echo '<A NAME="index">&nbsp;</A><H2>Index</H2>' | sedify)
INDEXEND='This document was created by'
SELF_PROMOTION=$(echo "<a href=https://github.com/jcarrano/man.sh>man.sh</a>  using"|sedify)
GARBAGE1=$(echo '<A HREF="#index">Index</A>' | sedify)
GARBAGE2=$(echo '<A HREF="http://HH">Return to Main Contents</A>' | sedify)

printman() {
	echo "${1}"
	if MFILE="$(echo "${1}" | xargs man -w | grep -v '/var/cache')" ; then
		bzcat "${MFILE}" | man2html -H H -M H | sed -r \
's/^(<HTML>)/<!DOCTYPE HTML>\1/;'\
's/http\:\/\/HH\?([[:digit:]]+)\+(.+)/\.\/\1~\2/g;'\
's/<TABLE>/<TABLE class="listing">/;'\
's/<([A-ZAz]+) BORDER>/<\1>/;'\
's/<TR[^<>]*><TD[^<>]*><HR><\/TD><\/TR>//;'\
's/HREF\=\"file:\/usr\/include\/([^\/]+\/)?(.*)\"/HREF\=\".\/\2\"/g;'\
's/<\/HEAD>/<link href="\/style\/simple.css" rel="stylesheet" type="text\/css" title="default" id="style" \/><\/HEAD>/;'\
"s/$INDEXSTART/$HEADERBAR0/;s/($INDEXEND)/$HEADERBAR1\\1 $SELF_PROMOTION/;"\
"s/($GARBAGE1|$GARBAGE2)//"
		return 1
	else
		return 0
	fi
}

main() {
	if ERRCOND="$(printman "${1}" 3>&1 1>&2 2>&3 3>&-)" ; then
		w404 "${ERRCOND}" 1>&2
	fi
}

REQ="$(echo "${PINF}" | sed -n -r 's/^\/\?q=((.+)\+)?(.+)/\/\2~\3/;y/~/ /;y/\// /;s/[ -]*([[:alnum:]_.+-]+([ ]+[[:alnum:]_.+]+[[:alnum:]_.+-]*)?)(.*)/\1/p' )"

if [ "x${REQ}" != "x" ] ; then
	main "${REQ}" 2>&1
elif [ -n "$1" ] ; then
	main "$*" 2>&1 1>/dev/null | sed '1,/^$/d'
else
	cat <<HTDOC
Status: 200 Ok
Content-type: text/plain

Manual Page Browser by Juan Carrano
HTDOC
fi
