#!/bin/bash

# SPDX-FileCopyrightText: 2023 Linnea Gräf <nea@nea.moe>
#
# SPDX-License-Identifier: MIT

set -ueo pipefail
shopt -s extglob
function dbg() {
    echo "$@" >&2
}
self="$0"
read -r method path http

dbg --------------
dbg Method: $method
dbg Path: $path
dbg Version: $http
cat >/dev/null &


function begin_response() {
    echo HTTP/1.1 "$1" "$2"
    echo Connection: close
    echo Server: shiggy.sh
    echo Date: $(date +"%a, %d %m %y %H:%M:%S %Z")
}

function content_type() {
    echo "Content-Type: $1"
}

function content_length() {
    echo "Content-Length: $1"
    dbg "Sending content length of $1"
}

function end_headers() {
    echo
}

function resolve_file() {
    echo "$(dirname "$self")/$1"
}

function send_file() {
    filename="$(resolve_file "$1")"
    dbg Trying to send "$filename"
    content_length $(wc -c "$filename" | cut -d ' ' -f 1)
    end_headers
    cat <"$filename"
    dbg Finished sending file
}

function send_heredoc() {
    data="$(cat)"
    content_length ${#data}
    end_headers
    echo -n "$data"
}

function send_file_if_exists() {
    if [[ -f "$(resolve_file "$1")" ]]; then
        begin_response 200 Found
        content_type "$2"
        send_file "$1"
    else
        send_404
    fi
}


function send_404() {
    begin_response 404 "Not Found"
    content_type "text/html"
    send_heredoc <<-'EOF'
<html>
<head>
    <title>404 Not Found</title>
</head>
<body>
<div class="center">
    <h1 color=red>404 Not Found</h1>
    <img src="/404.png" alt="4OwO4 nyot found :3"/>
</div>
</body>
</html>
EOF
}

function random_shiggy() {
    ls -1 posts|shuf -n 1
}

function redirect_to() {
    begin_response 302 "Redirect"
    echo "Location: $1"
    end_headers
}

function get_random_fragment() {
    shiggy_id=$(random_shiggy)
    cat <<EOF
<div class="shiggy">
<img src="/image/$shiggy_id" />
<a href="/image/$shiggy_id">Permalink</a>
<a href="#" onclick="window.location.reload()">Another one</a>
</div>
EOF
}

case "$path" in
    /)
        begin_response 200 Found
        content_type text/html
        send_heredoc <<-EOF
<html>
<head>
<title>Shiggy</title>
<link rel="stylesheet" href="/style.css">
</head>
<body>
<div class="center">
$(get_random_fragment)
</div>
</body>
</html>
EOF
        ;;
    /style.css)
        begin_response 200 Found
        content_type text/css
        send_heredoc <<EOF
.center {
    display: grid;
    justify-content: center;
}
img {
    display: block;
}
a {
    display: block;
    text-align: center;
}
EOF
        ;;
    /image/random)
        redirect_to /image/"$(random_shiggy)"
        ;;
    /image/*[!0123456789]*.png)
        send_404
        ;;
    /image/*.png)
        send_file_if_exists "posts/${path:7}" image/png
        ;;
    /404.png)
        begin_response 200 "Found"
        content_type image/png
        send_file 404.png
        ;;
    *)
        dbg "$path" does not match what i expected
        send_404
        ;;
esac








