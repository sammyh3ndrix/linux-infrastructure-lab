#!/bin/bash
url="http://localhost/docs"
status=$(curl -s -o /dev/null -w "%{http_code}" "$url")

if [ "$status" -eq 200 ]; then
    echo "Healthy: $url returned $status"
else
    echo "Unhealthy: $url returned $status"
fi
