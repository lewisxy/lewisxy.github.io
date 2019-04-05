#!/bin/sh

## This script generates a new tag page.

mkdir -p "tags/$1/"
cat > "tags/$1/index.html" <<EOF
---
title: Posts tagged $1
tag: $1
layout: tag
---
EOF
