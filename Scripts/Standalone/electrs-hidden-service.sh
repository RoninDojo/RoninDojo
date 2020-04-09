#!/bin/bash

V3_ADDR_ELECTRS=$( sudo docker exec -it tor cat /var/lib/tor/hsv3electrs/hostname )
echo "$V3_ADDR_ELECTRS"
