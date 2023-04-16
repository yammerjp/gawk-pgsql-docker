#!/bin/bash

set -e

AWKLIBPATH=/usr/local/lib/gawk awk -f /app/testpgsql.awk
