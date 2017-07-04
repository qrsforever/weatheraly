#!/bin/bash

print_with_color() {
    txt=$1
    if [[ x"$txt" == x ]]
    then
        txt="Text is null!!!"
    fi
    echo -e "# //////////////////////////////////////////////////"
    echo -e "# \t \e[0;34;1m$1\e[0m"
    echo -e "# //////////////////////////////////////////////////"
}
