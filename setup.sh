#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2023 Linnea Gräf <nea@nea.moe>
#
# SPDX-License-Identifier: MIT

mkdir -p posts
n=0
while true; do
    n=$(($n + 1))
    echo Requesting page $n
    processing_done=0
    while read -r id url; do
        processing_done=1
        if [[ -f posts/"$id".png ]]; then
            echo "Skipping processing image $id. Already exists"
            continue
        fi
        echo Processing image $id "($url)"
        curl -L --silent "$url" | mogrify -format png - > posts/$id.png
    done < <(curl --silent https://danbooru.donmai.us/posts.json\?tags\=kemomimi-chan_%28naga_u%29\&page\=$n|jq '.[]|((.id | tostring) + " " + .file_url)' -r)
    
    if [[ $processing_done -eq 0 ]]; then
        break
    fi
done 


