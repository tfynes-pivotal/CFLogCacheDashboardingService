#!/bin/bash

export grafana_version="7.0.0"

# NOTE MUST BE RUN FROM REPOSITORY HOME DIRECTORY

if [ -d "./grafana-$grafana_version" ] 
then
  mv ./grafana-$grafana_version/bin .
  mv ./grafana-$grafana_version/scripts .
  mv ./grafana-$grafana_version/public .
else
  echo "Please extract grafana binary to current director (assets land in ./grafana-$grafana_version)"
  echo "    e.g. tar xvf ../../grafana-<grafana_version>.linux-amd64.tar.gz"
fi
