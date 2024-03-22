#!/bin/bash

cd /home/ubuntu/test-node
pm2 stop all
pm2 start app.js --name=test-node
