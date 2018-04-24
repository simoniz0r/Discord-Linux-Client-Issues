#!/bin/bash
# Author: simonizor
# Title: discord-issues
# Description: Simple script to search the Discord Trello linux-issues board using curl and jq
# License: MIT

# download issues to /tmp/discord-linux-issuses.json to avoid multiple checks
function getissues() {
    rm -f /tmp/discord-linux-issues.json
    case "$1" in
        Linux|linux)
            BOARD="UyU76Esh"
            ;;
        Desktop|desktop)
            BOARD="AExxR9lU"
            ;;
        Android|android)
            BOARD="Vqrkz3KO"
            ;;
        iOS|ios)
            BOARD="vLPlnX60"
            ;;
        *)
            BOARD="UyU76Esh"
            ;;
    esac
    curl -sSL -o /tmp/discord-linux-issues.json "https://trello.com/b/$BOARD.json" || { echo "Failed to download issues from Trello; exiting..."; exit 1; }
}
# use jq to output all issues in a readable format
function showissues() {
    START_ISSUE=0
    for issue in $(jq -r '.cards[].shortUrl' /tmp/discord-linux-issues.json); do
        case "$(jq -r ".cards[$START_ISSUE].labels[0].color" /tmp/discord-linux-issues.json)" in
            green)
                CLR=2
                ;;
            yellow)
                CLR=3
                ;;
            orange)
                CLR=1
                ;;
            *)
                CLR=4
                ;;
        esac
        echo -e "$(tput setaf 6)Issue: $(jq -r ".cards[$START_ISSUE].shortLink" /tmp/discord-linux-issues.json)\n$(tput sgr0)"
        echo -e "Name:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].name" /tmp/discord-linux-issues.json)$(tput sgr0)"
        echo -e "Last Date of Activity:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].dateLastActivity" /tmp/discord-linux-issues.json)$(tput sgr0)"
        echo -e "Description:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].desc" /tmp/discord-linux-issues.json)$(tput sgr0)"
        echo -e "Attachments:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].attachments[].previews[].url" /tmp/discord-linux-issues.json)$(tput sgr0)"
        echo -e "Labels:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].labels[].name" /tmp/discord-linux-issues.json)$(tput sgr0)"
        echo -e "URL:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].shortUrl" /tmp/discord-linux-issues.json)$(tput sgr0)"
        START_ISSUE=$(($START_ISSUE+1))
        echo
    done
}
# run a grep -qi containing the search input on the name of the issue
function searchissues() {
    echo "Searching for '$@' ..."
    START_ISSUE=0
    for issue in $(jq -r '.cards[].shortUrl' /tmp/discord-linux-issues.json); do
        if jq -r ".cards[$START_ISSUE].name" /tmp/discord-linux-issues.json | grep -qi "$@"; then
            case "$(jq -r ".cards[$START_ISSUE].labels[0].color" /tmp/discord-linux-issues.json)" in
                green)
                    CLR=2
                    ;;
                yellow)
                    CLR=3
                    ;;
                orange)
                    CLR=1
                    ;;
                *)
                    CLR=4
                    ;;
            esac
            echo -e "$(tput setaf 6)Issue: $(jq -r ".cards[$START_ISSUE].shortLink" /tmp/discord-linux-issues.json)\n$(tput sgr0)"
            echo -e "Name:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].name" /tmp/discord-linux-issues.json)$(tput sgr0)"
            echo -e "Last Date of Activity:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].dateLastActivity" /tmp/discord-linux-issues.json)$(tput sgr0)"
            echo -e "Description:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].desc" /tmp/discord-linux-issues.json)$(tput sgr0)"
            echo -e "Attachments:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].attachments[].previews[].url" /tmp/discord-linux-issues.json)$(tput sgr0)"
            echo -e "Labels:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].labels[].name" /tmp/discord-linux-issues.json)$(tput sgr0)"
            echo -e "URL:\n$(tput setaf $CLR)$(jq -r ".cards[$START_ISSUE].shortUrl" /tmp/discord-linux-issues.json)$(tput sgr0)"
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
        echo "Usage: discord-issues [arguments] [search term(s)]"
        echo
        echo "Arguments:"
        echo "-h, --help        Show this help output and exit."
        echo
        echo "-s, --search      Search for term(s) matching the input. '\|' can be used to search for multiple terms at once."
        echo "                  Ex: discord-issues -s 'start\|KDE'"
        echo
        echo "-b, --board       Specify the Trello board to search on; options are linux, desktop, android, ios"
        echo "                  Can be used with -s; Ex: discord-issues -s -b desktop 'drop-down'"
        echo
        echo "If no argument is passed, the entire list of Linux issues will be shown."
        echo
        exit 0
        ;;
    -s|--search)
        shift
        case "$1" in
            -b|--board)
                shift
                INPUT_BOARD="$1"
                shift
                ;;
            *)
                INPUT_BOARD="linux"
                ;;
        esac
        getissues "$INPUT_BOARD"
        searchissues "$@"
        ;;
    *)
        case "$1" in
            -b|--board)
                shift
                INPUT_BOARD="$1"
                shift
                ;;
            *)
                INPUT_BOARD="linux"
                ;;
        esac
        getissues "$INPUT_BOARD"
        showissues | less
        ;;
esac
rm -f /tmp/discord-linux-issues.json
exit 0
