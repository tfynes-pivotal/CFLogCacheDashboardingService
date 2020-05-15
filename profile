#!/bin/bash
export grafanaUaaClientId=$(echo $VCAP_SERVICES | jq -r '.credhub[]|select(.instance_name=="grafanaUaaClient") | .credentials.clientid')
sed -i "s/grafanaUaaClientId/$grafanaUaaClientId/g" /home/vcap/app/conf/defaults.ini
export grafanaUaaClientSecret=$(echo $VCAP_SERVICES | jq -r '.credhub[]|select(.instance_name=="grafanaUaaClient") | .credentials.clientsecret')
sed -i "s/grafanaUaaClientSecret/$grafanaUaaClientSecret/g" /home/vcap/app/conf/defaults.ini

sed -i "s/pccguidvalue/$pccguid/g" /home/vcap/app/pccdashboards/pcc.json
