#!/bin/bash

LOGFILE="/var/log/gwservice.log"

if [ ! -S /run/php/php7.4-fpm.sock ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') php-fpm is NOT working properly." >> "$LOGFILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') php-fpm is working PROPERLY." >> "$LOGFILE"
fi

PIDFILE="/run/nginx.pid"
if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if ps -p $PID > /dev/null; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') nginx is running (PID: $PID)" >> "$LOGFILE"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') nginx PID file exists but process is not running" >> "$LOGFILE"
    fi
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') nginx is not running" >> "$LOGFILE"
fi
