#!/bin/bash

# Copyright (c) 2020 František Bráblík
# https://github.com/Bleskocvok/
# License: MIT License

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 11`
reset=`tput sgr0`
bold=`tput bold`

width=`tput cols`

echo_color() {
    echo "${bold}${!1}$2$reset"
}

math() {
    if [ "$2" == "round" ]; then
        echo "from __future__ import division; print(int($1))" | python2
    else
        echo "from __future__ import division; print($1)" | python2
    fi
}

fill() {
    for i in `seq $2`; do
        echo -n "$1"
    done
}

print_bar() {
    size=$((width - 2))
    percent=$1
    i=`math "$percent / 100 * $size" round`
    echo -n -e "\e[1A"
    echo -n "["
    fill "#" $i
    fill "." $((size - i))
    echo -n "]"
    echo ""
}

loading() {
    wait_time=`math "$1 / 100"`
    echo ""
    for i in `seq 100`; do
        print_bar $i
        sleep $wait_time
    done
}

echo_err() {
    echo -e "$1" 1>&2
}

add_cron_task() {
    sudo crontab -l > tasks
    echo "$1" >> tasks
    sudo crontab tasks
    rm tasks
}

schedule_task() {
    if [ "$1" == "lock" ]; then
        add_cron_task "$2 cp `realpath locked_hosts` /etc/hosts"
    elif [ "$1" == "unlock" ]; then
        add_cron_task "$2 cp `realpath unlocked_hosts` /etc/hosts"
    fi
}

setup() {
    if [ ! -f original_hosts ]; then
        cp /etc/hosts original_hosts
    fi
    cp original_hosts unlocked_hosts
    cp original_hosts locked_hosts
    cat $1 | sed -e 's/\(.*\)/0.0.0.0 \1\n0.0.0.0 www.\1/g' >> locked_hosts
}

print_manual() {
    echo_err "usage: $0 [lock/unlock/check/setup/help]\n"
    echo_err "setup argument:"
    echo_err "\t$0 setup [filename]"
    echo_err "\t$0 setup"
    echo_err "\t\t -- filename is a file containing list of urls"
    echo_err "\t\t -- if no filename is given the list of urls is expected on stdin"
}

lock() {
    echo_color yellow "LOADING"
    loading 1
    sudo cp locked_hosts /etc/hosts
    echo_color yellow "SAVING"
    loading 0.5
    echo_color green "LOCKED"
}

unlock() {
    if [ -x "$(command -v sl)" ]; then
        sl
    else
        echo_err "warning: sl not installed\nfull immersion not available"
    fi
    echo_color yellow "LOADING"
    loading 15
    sudo -k cp /etc/hosts .
    echo_color yellow "SAVING"
    loading 10
    sudo cp unlocked_hosts /etc/hosts
    echo_color red "UNLOCKED"
}

check() {
    if diff /etc/hosts locked_hosts > /dev/null; then
        echo_color green "Hosts LOCKED"
        exit 0
    elif diff /etc/hosts unlocked_hosts > /dev/null; then
        echo_color red "Hosts UNLOCKED"
        exit 1
    else
        echo_err "Hosts file is neither locked nor unlocked"
        exit 2
    fi
}

if [ "$1" == "unlock" ]; then
    unlock
elif [ "$1" == "lock" ]; then
    lock
elif [ "$1" == "check" ]; then
    check
elif [ "$1" == "setup" ]; then
    setup ${@:2}
elif [ "$1" == "help" ]; then
    print_manual
else
    echo_err "wrong argument"
    print_manual
    exit 1
fi



