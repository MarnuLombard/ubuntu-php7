#!/bin/bash
docker run -d \
  --name="marnu" \
  -p 242:22 \
  -p 80:80 \
  -p 3306:3306 \
  -v /Users/marnu/Desktop/Work/:/var/www/ \
  -v `pwd`/data/:/data/ \
  -v `pwd`/conf/:/conf/ \
  -i -t marnu/ubuntu:latest
