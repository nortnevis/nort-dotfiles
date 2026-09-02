#!/bin/bash

val=${1:-1200}

sudo ip l set dev wlan0 mtu $val
