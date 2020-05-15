# CFLogCacheDashboardingService

Cloud Foundry / Tanzu Application Service (TAS) telemetry / instrumentation dashboards

Application developers want to instrument their applications and dependent services hosted in TAS. Metrics data is emitted from applications and stored by the platform engine in a TSDB service called 'log-cache' that supports PrometheusQL

Tenant access to the log-cache service is available through the TAS security service; UAA

The only thing missing is the ability to take this metrics data and rapidly visualize it.

Grafana is an excellent tool perfectly suited to this purpose, creating dashboards & alerts based on a backing datastore.

This project integrates Grafana with TAS-UAA and TAS-LogCache components to allow for rapid creation of grafana-dashboards which would be hosted within the TAS platform.

Experimental dashboard included to instrument the KPIs from the "Tanzu Gemfire" data-grid TAS Service.



PreRequisites
*UAA client (id/secret) for instances of the dashboarding engine to leverage with the following scopes;

*Steps to create client using uaac (already deployed to OpsManager VM)
```
uaac target https://uaa.<system-domain>
uaac client get admin get -s <uaa admin secret>
# Note - redirect_uri grafana dashboards FQDNs whitelist
uaac client add --name grafanaUaaClientId --scope openid,uaa.resource,doppler.firehose,logs.admin,cloud_controller.read --authorized_grant_types openid,uaa.resource,doppler.firehose,logs.admin,cloud_controller.read --redirect_uri https://grafana.homelab.fynesy.com/** -s grafanaUaaClientSecret
```

*CredhubService instance hosting this Grafana UAA client id and secret
```
  cf cs credhub default grafanaUaaClient -c '{"clientid":"grafanaUaaClientId","clientsecret":"grafanaUaaClientSecret"}
```
Note this service instance can be created once and shared in the target spaces into which Grafana dashboard instances will run.

Modify conf/defaults.ini "Generic OAuth" URLs for your TAS UAA service

Download grafana-6.7.3 for linux 
Overlay assets from this repo to your install

  /profile - rename to .profile before pushing - configures GenericOAuth clientId and clientSecret from Credhub (in defaults/ini)
  
  /manifest.yml - sample deployment manifest
  /pccdashboards - sample dashboard for PCC service instance
  /conf/defaults.ini - UAA integration code




