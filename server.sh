#!/bin/sh
# Copyright 2017 Juan I Carrano <juan@carrano.com.ar>
# Distributed under the terms of the 3-Clause BSD License (see README.rst)

PORT=${2-"8000"}
_BASEDIR=${BASEDIR-$(pwd)}
_OUTPUT_FILE=${_OUTPUT_FILE-"/dev/null"}

respond() {
    cat <<HTDOC
HTTP/1.1 $1
Content-type: $2

HTDOC
}

qresp() {
    echo "$1: ${3-Unknwn}" >&2
    echo "$2" | respond "$2" "text/plain"
}

alias w403='qresp 403 "Not Authorized"'
alias w404='qresp 403 "File not found"'
alias w405='qresp 405 "Method Not Allowed"'

serve_file() {
    if ! SAFEPATH=$(realpath --relative-base="$_BASEDIR" -m "$_BASEDIR/$1") ; then
        w404 "Empty path"
    fi
    case "$SAFEPATH" in
    .*|/*)
        w404 "Unsafe file: $SAFEPATH"
        ;;
    *)
        if [ -e "$SAFEPATH" ] ; then
            echo "Start serving file $SAFEPATH" >&2
            cat <<HTDOC
HTTP/1.1 200 Ok
Content-type: $2

HTDOC
            cat "$SAFEPATH"
            echo "Done with file" >&2
        else
            w404 "Nonexistent file"
        fi
        ;;
    esac
}

filter_cgi() {
    sed -r '1s/^Status: (.+)/HTTP\/1.1 \1/;'\
'1t;'\
'1iHTTP/1.1 200 Ok'
}

parse_request() {
    sed -n 's/\r//;1p;/^$/q'
}

serve_1() {
    echo "Start parsing request:" >&2
    parse_request | tee -a /dev/stderr | _serve_1
}

_serve_1() {
    read -r METHOD PATHINFO HTTP_VERSION

    echo "Starting response" >&2

    if [ x"$METHOD" != xGET ] ; then
        w405 "$METHOD"
        return
    fi

    case "$PATHINFO" in
    *.css)
        serve_file "$PATHINFO" 'text/css'
        ;;
    *)
        PATH_INFO="$PATHINFO" ./man.sh | filter_cgi
        ;;
    esac

    echo "Served request" >&2
}

# We cannot do persistent connections since we do not know content-length

if [ x"$1" = xserve ] ; then
   echo "serving on port $PORT"
   while true ; do
    echo "Start NC" >&2
    nc -l -p "$PORT" -e $0
    echo "Exit NC" >&2
   done
else
   serve_1 2>>debug_log.txt | tee -a "$_OUTPUT_FILE"
fi
