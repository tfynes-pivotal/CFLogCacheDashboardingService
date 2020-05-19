# Cloud Foundry / Tanzu Application Service (TAS) Telemetry/Instrumentation Dashboards-as-a-Service

Application developers want to instrument their applications and dependent services hosted in TAS. Metrics data is emitted from applications and stored by the platform engine in a TSDB service called 'log-cache' that supports PrometheusQL

Tenant access to the log-cache service is available through the TAS security service; UAA

The only thing missing is the ability to take this metrics data and rapidly visualize it.

Grafana is an excellent tool perfectly suited to this purpose, creating dashboards & alerts based on a backing datastore. TAS is the perfect platform upon which to host Grafana dashboards.

This project integrates TAS-Hosted-Grafana (using binary-buildpack) with TAS-UAA and TAS-LogCache components to allow for rapid creation of secured, tennant grafana-dashboards.

Experimental dashboard included to instrument the KPIs from the "Tanzu Gemfire" (PCC) data-grid TAS Service.

PreRequisites:

*UAA client (id/secret) for instances of the dashboarding engine to leverage with the following scopes;
```
openid,uaa.resource,doppler.firehose,logs.admin,cloud_controller.read
```

*Steps to create client using uaac (already deployed to OpsManager VM)
Choose acceptable values for grafanaUaaClientId and grafanaUaaClientSecret
```
ssh -i <om-key> ubuntu@<ops-mgr host>
uaac target https://uaa.<system-domain>
uaac token client get admin get -s <uaa admin-client secret from OM TAS tile credentials tab>
# Note - create grafanaUaaClient with required scopes and **redirect_uri grafana dashboards FQDN wildcard on <apps-domain>**
uaac client add --name <grafanaUaaClientId> --scope openid,uaa.resource,doppler.firehose,logs.admin,cloud_controller.read --authorized_grant_types openid,uaa.resource,doppler.firehose,logs.admin,cloud_controller.read --redirect_uri https://*.<apps-domain>/** -s <grafanaUaaClientSecret>
```

*CredhubService instance hosting this Grafana UAA client id and secret
```
  cf cs credhub default grafanaUaaClient -c '{"clientid":"<grafanaUaaClientId>","clientsecret":"<grafanaUaaClientSecret>"}
```
Note this service instance can be created once and shared in the target spaces into which Grafana dashboard instances will run.
```
cf share-service grafanaUaaClient -s <space-to-share-service-in>
```

PREREQ SUMMARY
1. create uaa client for grafana instances to access log-cache
2. store this uaa client id and secret in credhub service - called **"grafanaUaaClient"**
3. download grafana-7.0.0+ binary for linux64
```
wget https://dl.grafana.com/oss/release/grafana-7.0.0.linux-amd64.tar.gz
```

DEPLOYMENT STEPS
1. Create working directory
```mkdir grafana```
2. Download / copy grafana gzip archive to this folder
* cd grafana
* wget https://dl.grafana.com/oss/release/grafana-7.0.0.linux-amd64.tar.gz
3. Clone this repo and cd into repository directory (CFLogCacheDashboardingService)
* git clone https://github.com/tfynes-pivotal/CFLogCacheDashboardingService
* cd CFLogCacheDashboardingService
2. Extract grafana binary to current (repository directory)
* tar zxvf ../grafana-7.0.0.linux-amd64.tar.gz
3. Run ./setupGrafana.sh to move assets from grafana distribution sub-folder up to current 
* ./setupGrafana.sh
4. Modify manifest.yml to reflect your application name, ingress-route, pcc-SI and Credhub-SI (containing grafana UAA client details)
...
5. ** Copy/Move profile script to <dot>-Profile "cp ./profile ./.profile" ** 
* cp profile .profile
6. Deploy the dashboard
* cf push

WHATS HAPPENING
* 1. manifest file orders cf to use binary-buildpack and launch grafana-server
* 2. grafana-server looks in ./conf/defaults.ini for initial configuration
* 3. '.profile' script executed on container-launch by platform, performs following tasks:
  *  3.1 Extracts grafanaUaaClientId&Secret from Credhub-SI 'grafanaUaaClient' and injects them into the generic-oauth section of defaults.ini
  * 3.2 Extracts PCC SI GUID from the bound PCC service instance key (extracting it from the hostname of the SI management endpoint)
  * 3.3 Updates the root_uri for the grafana dashboard to listen on by inspecting first exposed route of this CF application.
  * 3.4 Update UAA endpoints for oAuth integration to reflect the founation's "system-domain"  in defaults.ini generic-oauth section
        system.domain discovered from VCAP_APPLICATION/cf_api endpoint
  * 3.5 Update the conf/provisioning/datasources/logcache.yml configuration file "system-domain" to that of current foundation
 


/manifest.yml - sample deployment manifest
/pccdashboards/pcc.json - sample dashboard for PCC service instance
/conf/defaults.ini - UAA integration code
/conf/provisioning/dashboards/pcc.yaml - configures the '/pccdashboards' folder as dashboard json location

/conf/provisioning/datasources/logcache.yaml 
  - configures the location of the log-cache endpoint  
  - configures grafana to use oAuthPassThru to authenticate against log-cache service.
  
NOTE: When you hit the grafana dashboard URI for the first time, navigate to dashboards / manage (left of screen) and select the PCC Dashboard

DAY2 Use:
use 'cf log-meta' and 'cf tail' to discovery other platform, application or services to instrument. Create new panels for existing sample dashboard and when ready just export the json (share dashboard / export json). This json file can be placed in './pccdashboards'. 
