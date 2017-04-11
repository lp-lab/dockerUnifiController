#!/bin/bash
set -e

exec /etc/init.d/mongodb start
exec /etc/init.d/unifi start
