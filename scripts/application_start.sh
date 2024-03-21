#!/bin/bash

pm2 stop all
pm2 start app.js --name=test-node
