#!/bin/bash
# Ensure nginx is installed and deployment directory exists
if [ ! -d /usr/share/nginx/html ]; then
  mkdir -p /usr/share/nginx/html
fi
rm -rf /usr/share/nginx/html/*
