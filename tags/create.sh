#!/bin/sh

## This script generates a new tag page.

mkdir -p $1/
cat > $1/index.html <<EOF
---
title: Posts tagged $1
tag: $1
layout: tag
---
EOF
