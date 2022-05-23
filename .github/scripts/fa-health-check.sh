#!/bin/bash
echo "Checking to see if Kickstart has finished"
COUNT=0
echo -n "Waiting for Kickstart "
until  docker logs fa-test-fusionauth 2>&1 | grep -q "Created API key ending in" ||  [ $COUNT == 60 ] ; do
    COUNT=$(( COUNT + 1 ))
    echo -n "."
    sleep 1
done
echo " Kickstart has finished"
