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

*CredhubService instance hosting this Grafana UAA client id and secret
```
  cf cs credhub default grafanaUaaClient -c '{"clientid":"grafana","clientsecret":"grafana"}
```
Note this service instance can be created once and shared in the target spaces into which Grafana dashboard instances will run.




