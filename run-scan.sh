#! /usr/bin/env bash

pip install rl-deploy

rl-deploy --version

echo "description=This is a message"  >> $GITHUB_OUTPUT
echo "status=success"                 >> $GITHUB_OUTPUT
