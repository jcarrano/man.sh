#!/bin/sh
# Copyright 2017 Juan I Carrano <juan@carrano.com.ar>

PORT=${2-"8000"}
_BASEDIR=${BASEDIR-$(pwd)}
_OUTPUT_FILE=${_OUTPUT_FILE-"/dev/null"}

respond() {
    cat <<HTDOC
HTTP/1.1 $1
Content-type: $2

HTDOC
}

w403() {
    echo "403: ${1-Unknwn}" >&2
    echo "Not Authorized" | respond "403 Unauthorized" "text/plain"
}

w404() {
    echo "404: ${1-Unknwn}" >&2
    echo "File not found" | respond "404 Not Found" "text/plain"
}

serve_file() {
    if ! SAFEPATH=$(realpath --relative-base=. -sm "$_BASEDIR/$1") ; then
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
    read -r STATUS
    THE_STATUS=$(echo "$STATUS" | sed -nr 's/^Status: (.+)/\1/p')
    echo "HTTP/1.1" "$THE_STATUS"
    cat
}

consume_headers() {
    while true ; do
        read -r SOMETHING
        if [ -z "$(echo "$SOMETHING" | tr -d '\r')" ] ; then
            break
        fi
    done
}

serve_1() {
    echo "Start parsing request" >&2
    read -r LINE1

    echo "Consuming headers" >&2
    consume_headers

    echo "Headers consumed" >&2
    case "$LINE1" in
    GET*)
        PATHINFO=$(echo "$LINE1" | sed -nr 's/^GET (\/[^ ]*).*/\1/p')
        case "$PATHINFO" in
        *.css)
            serve_file "$PATHINFO" 'text/css'
            ;;
        *)
            PATH_INFO="$PATHINFO" ./man.sh | filter_cgi
        esac
        ;;
    *)  w403
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
   serve_1 2>>debug_log.txt | tee -a _OUTPUT_FILE
fi
