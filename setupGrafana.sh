#!/bin/bash

if [ -d "./grafana-6.7.3" ] 
then
  mv ./grafana-6.7.3/bin .
  mv ./grafana-6.7.3/scripts .
  mv ./grafana-6.7.3/tools .
  mv ./grafana-6.7.3/public .
else
  echo "Please extract grafana binary to current director (assets land in ./grafana-6.7.3)"
  echo "    e.g. tar xvf ../../grafana-6.7.3.linux-amd64.tar.gz"
fi
