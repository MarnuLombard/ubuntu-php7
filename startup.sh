#!/bin/bash
docker run -d --name="marnu" -u root -p 242:22 -p 80:80 -p 3306:3306 -i -t marnu/ubuntu:latest
