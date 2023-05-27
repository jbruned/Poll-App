#!/bin/bash
set -e

(aws sts get-caller-identity > /dev/null && echo "Successfully logged in") || (echo "Error while logging in" && exit 1)
