#!/bin/bash

# GRAFANA DASHBOARD TAS INITIALIZER

# PRE-REQS
#  APP MANIFEST HAS 2 SERVICE BINDINGS
#     Credhub Service containing grafanaUaaClientId and Secret
#     PCC SI to be instrumented
     


# EXTRACT CLIENT-ID AND CLIENT-SECRET FOR GRAFANA FROM REGISTERED CREDHUB-SERVICE-BROKERED SECRET
#  EMBED INTO THE GRAFANA DEFAULTS.INI FILE

export grafanaUaaClientId=$(echo $VCAP_SERVICES | jq -r '.credhub[]|select(.instance_name=="grafanaUaaClient") | .credentials.clientid')
export grafanaUaaClientSecret=$(echo $VCAP_SERVICES | jq -r '.credhub[]|select(.instance_name=="grafanaUaaClient") | .credentials.clientsecret')
sed -i "s/grafanaUaaClientId/$grafanaUaaClientId/g" /home/vcap/app/conf/defaults.ini
sed -i "s/grafanaUaaClientSecret/$grafanaUaaClientSecret/g" /home/vcap/app/conf/defaults.ini

# INITIALIZE 'PCCGUID' ENVIRONMENT VARIABLE WITH SERVICE ID FOR FIRST BOUND PCC SERVICE INSTANCE
#  SERVICE GUID EXTRACTED FROM MANAGEMENT URI HOSTNAME IN SERVICE KEY
#  SERVICE GUID INJECTED INTO SAMPLE DASHBOARD PCC.JSON
export pccguid=$(echo $VCAP_SERVICES | jq -r .[\"p-cloudcache\"][0].credentials.urls.management | sed -n 's/https:\/\/cloudcache-\(.*\).*/\1/p' | cut -d . -f 1)
sed -i "s/pccguidvalue/$pccguid/g" /home/vcap/app/pccdashboards/pcc.json

# UPDATE GRAFANA ROOT URL BASED ON FIRST ROUTE AS EXTRACTED FROM APPLICATION ENV.
export grafana_root_url=$(echo $VCAP_APPLICATION | jq -r .application_uris[0])
sed -i "s/grafana_root_url/https\:\/\/$grafana_root_url/g" /home/vcap/app/conf/defaults.ini

# UPDATE UAA ENDPOINTS AND LOGCACHE ENDPOINT TO REFLECT THE SYSTEM DOMAIN - EXTRACTED FROM VCAP_APPLICATION CF-API URL
export system_domain=$(echo $VCAP_APPLICATION | jq .cf_api | awk -F'api.' '{print $2}' | sed 's/.$//g')
sed -i "s/system_domain/$system_domain/g" /home/vcap/app/conf/defaults.ini
sed -i "s/system_domain/$system_domain/g" /home/vcap/app/conf/provisioning/datasources/logcache.yaml


