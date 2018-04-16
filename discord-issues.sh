#!/bin/bash
# Author: simonizor
# Title: discord-issues
# Description: Simple script to search the Discord Trello linux-issues board using curl and jq
# License: MIT

# download issues to /tmp/discord-linux-issuses.json to avoid multiple checks
function getissues() {
    rm -f /tmp/discord-linux-issues.json
    curl -sSL -o /tmp/discord-linux-issues.json "https://api.trello.com/1/boards/UyU76Esh/cards" || { echo "Failed to download issues from Trello; exiting..."; exit 1; }
}
# use jq to output all issues in a readable format
function showissues() {
    START_ISSUE=0
    for issue in $(jq -r '.[].shortUrl' /tmp/discord-linux-issues.json); do
        echo -e "$(tput setaf 1)Issue: $(jq -r ".[$START_ISSUE].shortLink" /tmp/discord-linux-issues.json)\n$(tput sgr0)"
        echo -e "Name:\n$(tput setaf 2)$(jq -r ".[$START_ISSUE].name" /tmp/discord-linux-issues.json)$(tput sgr0)"
        echo -e "Last Date of Activity:\n$(tput setaf 2)$(jq -r ".[$START_ISSUE].dateLastActivity" /tmp/discord-linux-issues.json)$(tput sgr0)"
        echo -e "Description:\n$(tput setaf 2)$(jq -r ".[$START_ISSUE].desc" /tmp/discord-linux-issues.json)$(tput sgr0)"
        echo -e "Labels:\n$(jq -r ".[$START_ISSUE].labels" /tmp/discord-linux-issues.json)"
        echo -e "URL:\n$(tput setaf 2)$(jq -r ".[$START_ISSUE].shortUrl" /tmp/discord-linux-issues.json)$(tput sgr0)"
        START_ISSUE=$(($START_ISSUE+1))
        echo
    done
}
# run a grep -qi containing the search input on the name of the issue
function searchissues() {
    echo "Searching for '$@' ..."
    START_ISSUE=0
    for issue in $(jq -r '.[].shortUrl' /tmp/discord-linux-issues.json); do
        if jq -r ".[$START_ISSUE].name" /tmp/discord-linux-issues.json | grep -qi "$@"; then
            echo -e "$(tput setaf 1)Issue: $(jq -r ".[$START_ISSUE].shortLink" /tmp/discord-linux-issues.json)\n$(tput sgr0)"
            echo -e "Name:\n$(tput setaf 2)$(jq -r ".[$START_ISSUE].name" /tmp/discord-linux-issues.json)$(tput sgr0)"
            echo -e "Last Date of Activity:\n$(tput setaf 2)$(jq -r ".[$START_ISSUE].dateLastActivity" /tmp/discord-linux-issues.json)$(tput sgr0)"
            echo -e "Description:\n$(tput setaf 2)$(jq -r ".[$START_ISSUE].desc" /tmp/discord-linux-issues.json)$(tput sgr0)"
            echo -e "Labels:\n$(tput setaf 2)$(jq -r ".[$START_ISSUE].labels" /tmp/discord-linux-issues.json)$(tput sgr0)"
            echo -e "URL:\n$(tput setaf 2)$(jq -r ".[$START_ISSUE].shortUrl" /tmp/discord-linux-issues.json)$(tput sgr0)"
            echo
        fi
        START_ISSUE=$(($START_ISSUE+1))
    done
}
# check to see if jq is installed
if ! type jq > /dev/null 2>&1; then
    echo "jq is not installed; exiting..."
    exit 1
fi
# detect arguments
case "$1" in
    -h|--help)
        echo "A simple script that outputs and searches https://api.trello.com/1/boards/UyU76Esh/cards using curl and jq"
        echo "Usage: discord-issues [argument] [search term(s)]"
        echo
        echo "Arguments:"
        echo "-h, --help        Show this help output and exit."
        echo
        echo "-s, --search      Search for term(s) matching the input. '\|' can be used to search for multiple terms at once."
        echo "                  Ex: discord-issues -s 'start\|KDE'"
        echo
        echo "If no argument is passed, the entire list of issues will be shown."
        echo
        exit 0
        ;;
    -s|--search)
        shift
        getissues
        searchissues "$@"
        ;;
    *)
        getissues
        showissues | less
        ;;
esac
rm -f /tmp/discord-linux-issues.json
exit 0
