#!/bin/bash
# Usage: ./validate-webpage.sh <docker_ip>

HOST=www.msftconnecttest.com
IP=${1:?usage: $0 <docker_ip>}

echo "== DNS =="; dig +short "$HOST" | sort
echo "== Docker IP =="; echo "$IP"

for p in "" connecttest.txt; do
  echo "== /$p =="
  # sort is used to avoid issues with false negatives due to different orders in the responses
  f() { tr -d '\r' | grep -vi '^date:' | sort; }
  real=$(curl -si "http://$HOST/$p" | f)
  mine=$(curl -si --resolve "$HOST:80:$IP" "http://$HOST/$p" | f)
  diff <(echo "$real") <(echo "$mine") && echo "IDENTICAL"
done
