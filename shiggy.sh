#!/bin/bash

# SPDX-FileCopyrightText: 2023 Linnea Gräf <nea@nea.moe>
#
# SPDX-License-Identifier: MIT

set -ueo pipefail
dbg() {
    echo "$@" >&2
}
self="$0"
read -r method path http

dbg --------------
dbg Method: $method
dbg Path: $path
dbg Version: $http


begin_response() {
    echo HTTP/1.1 "$1" "$2"
    echo Connection: close
    echo Server: shiggy.sh
    echo Date: $(date +"%a, %d %m %y %H:%M:%S %Z")
}

content_type() {
    echo "Content-Type: $1"
}

content_length() {
    echo "Content-Length: $1"
}

end_headers() {
    echo
}

send_file() {
    filename="$(dirname "$self")/$1"
    content_length $(wc -c "$filename")
    end_headers
    cat -- "$filename"
}

send_heredoc() {
    data="$(cat)"
    content_length ${#data}
    end_headers
    echo -n "$data"
}


case "$path" in
    "/")
        ;;
    "/image/*")
        ;;
    /404.png)
        begin_response 200 "Found"
        content_type "image/png"
        send_file 404.png
        ;;
    *)
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
        ;;
esac








