#!/bin/bash
# @Description: upvid.mobi file download script
# @Author: Juni Yadi
# @URL: https://github.com/JuniYadi/upvid
# @Version: 201811261501
# @Date: 2018-11-26
# @Usage: ./upvid.sh url

if [ -z "${1}" ]
then
    echo "usage: ${0} url"
    echo "batch usage: ${0} url-list.txt"
    echo "url-list.txt is a file that contains one upvid.mobi url per line"
    exit
fi

function upviddownload()
{
    prefix="$( echo -n "${url}" | cut -d'/' -f4 )"
    cookiefile="/tmp/${prefix}-cookie.tmp"
    infofile="/tmp/${prefix}-info.tmp"
    infodlfile="/tmp/${prefix}-infodl.tmp"
    header="/tmp/${prefix}-header.tmp"

    # loop that makes sure the script actually finds a filename
    filename=""
    retry=0
    while [ -z "${filename}" -a ${retry} -lt 10 ]
    do
        let retry+=1
        rm -f "${cookiefile}" 2> /dev/null
        rm -f "${infofile}" 2> /dev/null
        curl -s -c "${cookiefile}" -o "${infofile}" -L "${url}"

        filename="$( cat "${infofile}" | grep '<title>' | sed -e 's/^[ \t]*//' | sed -n '/^$/!{s/<[^>]*>//g;p;}' | sed 's/ //g' )"
    done

    if [ "${retry}" -ge 10 ]; then
        echo "could not download file"
        exit 1
    fi

    if [ -f "${infofile}" ]; then
        nextfile="$( cat "${infofile}" | grep 'page=download' | sed -e 's/^[ \t]*//' | cut -d'"' -f2 )"
        curl -s -c "${cookiefile}" -o "${infodlfile}" -L "${nextfile}"

        infourldl=$( cat "${infodlfile}" | grep 'page=dl' | sed -e 's/^[ \t]*//' | cut -d'"' -f4)
        infofileurl=$( curl -s -c "${cookiefile}" -I "${infourldl}" -o "${header}" )
        getdl=$( cat "${header}" | grep "Location:" | cut -d" " -f2)

        if [ "$getdl" ]; then
            dl="${getdl}"
        else
            dl=$( cat "${header}" | grep "location:" | cut -d" " -f2)
        fi

        if [ ! "$dl" ]; then
            echo "url file not found"
            exit 1
        fi

    else
        echo "can't find info file for ${prefix}"
        exit 1
    fi

    # Set browser agent
    agent="Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36"

    if [ -f "$filename" ]; then
        echo "[ERROR] File  Exist : $filename"
    else
        echo "[INFO] Download File : $filename"

        # Start download file
        wget -c -O "${filename}" "${dl}" \
        -q --show-progress \
        --referer="${infourldl}" \
        --load-cookies="$cookiefile" \
        --user-agent="${agent}"
    fi

    rm -f "${cookiefile}" 2> /dev/null
    rm -f "${infofile}" 2> /dev/null
    rm -f "${infodlfile}" 2> /dev/null
}

if [ -f "${1}" ]
then
    for url in $( cat "${1}" | grep -i 'upvid.mobi' )
    do
        upviddownload "${url}"
    done
else
    url="${1}"
    upviddownload "${url}"
fi