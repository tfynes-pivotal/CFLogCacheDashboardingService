#!/bin/bash
export grafanaUaaClientId=$(echo $VCAP_SERVICES | jq -r '.credhub[]|select(.instance_name=="grafanaUaaClient") | .credentials.clientid')
sed -i "s/grafanaUaaClientId/$grafanaUaaClientId/g" /home/vcap/app/conf/defaults.ini
export grafanaUaaClientSecret=$(echo $VCAP_SERVICES | jq -r '.credhub[]|select(.instance_name=="grafanaUaaClient") | .credentials.clientsecret')
sed -i "s/grafanaUaaClientSecret/$grafanaUaaClientSecret/g" /home/vcap/app/conf/defaults.ini

sed -i "s/pccguidvalue/$pccguid/g" /home/vcap/app/pccdashboards/pcc.json

export grafana_root_url=$(echo $VCAP_APPLICATION | jq -r .application_uris[0])
sed -i "s/grafana_root_url/https\:\/\/$grafana_root_url/g" /home/vcap/app/conf/defaults.ini

export system_domain=$(echo $VCAP_APPLICATION | jq .cf_api | awk -F'api.' '{print $2}' | sed 's/.$//g')
sed -i "s/system_domain/$system_domain/g" /home/vcap/app/conf/defaults.ini

sed -i "s/system_domain/$system_domain/g" /home/vcap/app/conf/provisioning/datasources/logcache.yaml
