# Cloud Foundry / Tanzu Application Service (TAS) telemetry / instrumentation dashboards

Application developers want to instrument their applications and dependent services hosted in TAS. Metrics data is emitted from applications and stored by the platform engine in a TSDB service called 'log-cache' that supports PrometheusQL

Tenant access to the log-cache service is available through the TAS security service; UAA

The only thing missing is the ability to take this metrics data and rapidly visualize it.

Grafana is an excellent tool perfectly suited to this purpose, creating dashboards & alerts based on a backing datastore.

This project integrates TAS-Hosted-Grafana (using binary-buildpack) with TAS-UAA and TAS-LogCache components to allow for rapid creation of secured, tennant grafana-dashboards.

Experimental dashboard included to instrument the KPIs from the "Tanzu Gemfire" (PCC) data-grid TAS Service.

PreRequisites:

*UAA client (id/secret) for instances of the dashboarding engine to leverage with the following scopes;
```
openid,uaa.resource,doppler.firehose,logs.admin,cloud_controller.read
```

*Steps to create client using uaac (already deployed to OpsManager VM)
```
uaac target https://uaa.<system-domain>
uaac token client get admin get -s <uaa admin secret>
# Note - redirect_uri grafana dashboards FQDNs whitelist
uaac client add --name grafanaUaaClientId --scope openid,uaa.resource,doppler.firehose,logs.admin,cloud_controller.read --authorized_grant_types openid,uaa.resource,doppler.firehose,logs.admin,cloud_controller.read --redirect_uri https://*.<system-domain>/** -s grafanaUaaClientSecret
```

*CredhubService instance hosting this Grafana UAA client id and secret
```
  cf cs credhub default grafanaUaaClient -c '{"clientid":"grafanaUaaClientId","clientsecret":"grafanaUaaClientSecret"}
```
Note this service instance can be created once and shared in the target spaces into which Grafana dashboard instances will run.
Note - Use admin client secret as defined when creating client in previous step


PREREQ SUMMARY
1. create uaa client for grafana instances to access log-cache
2. store this uaa client id and secret in credhub service - called "grafanaUaaClient"
3. download grafana-6.7.3 binary for linux64

DEPLOYMENT STEPS
1. clone repo and open command prompt in repo directory
2. extract grafana binary to ./grafana-6.7.3
3. run ./setupGrafana.sh to move assets from grafana distribution folder up to current
4. modify manifest.yml to reflect your application name, ingress-route, pcc-SI and Credhub-SI (containing grafana UAA client details)
5. ** Copy/Move profile script to <dot>-Profile "cp ./profile ./.profile"
6. cf push

WHATS HAPPENING
1. manifest file orders cf to use binary-buildpack and launch grafana-server
2. grafana-server looks in ./conf/defaults.ini for initial configuration
3. '.profile' script executed on container-launch performs following tasks:
  3.1 Extracts grafanaUaaClientId&Secret from Credhub-SI 'grafanaUaaClient' and injects them into the generic-oauth section of defaults.ini
  3.2 Extracts PCC SI GUID from the bound PCC service instance key (extracting it from the hostname of the SI management endpoint)
  3.3 Updates the root_uri for the grafana dashboard to listen on by inspecting first exposed route of this CF application.
  3.4 Update UAA endpoints for oAuth integration to reflect the founation's "system-domain"  in defaults.ini generic-oauth section
        system.domain discovered from VCAP_APPLICATION/cf_api endpoint
  3.5 Update the conf/provisioning/datasources/logcache.yml configuration file "system-domain" to that of current foundation
 


/manifest.yml - sample deployment manifest
/pccdashboards/pcc.json - sample dashboard for PCC service instance
/conf/defaults.ini - UAA integration code
/conf/provisioning/dashboards/pcc.yaml - configures the '/pccdashboards' folder as dashboard json location

/conf/provisioning/datasources/logcache.yaml 
  - configures the location of the log-cache endpoint **change endpoint to log-cache.system-domain for your foundation** 
  - configures grafana to use oAuthPassThru to authenticate against log-cache service.

