#!/bin/bash
PASSWORD=$1
HASH=$(echo -n "$PASSWORD{salt_value}" | sha256sum - | awk '{ print $1; }')
echo -n "{\"hash\":\"$HASH\"}"