#!/bin/sh

## This script generates a new blog page.

cat > _posts/$(date "+%Y-%m-%d")-$(echo $1 | sed 's/ /-/g').markdown <<EOF
---
title:  $1
layout: post
date:   $(date "+%Y-%m-%d")
tag:    []
uuid:   $(uuidgen)
---

EOF
