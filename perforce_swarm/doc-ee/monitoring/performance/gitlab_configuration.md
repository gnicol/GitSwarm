# GitSwarm EE Configuration

GitSwarm EE Performance Monitoring is disabled by default. To enable it and
change any of its settings, navigate to the Admin area in **Settings >
Metrics** (`/admin/application_settings`).

The minimum required settings you need to set are the InfluxDB host and
port. Make sure _Enable InfluxDB Metrics_ is checked and hit **Save** to
save the changes.

---

![GitSwarm EE Performance Monitoring Admin Settings](img/metrics_gitlab_configuration_settings.png)

---

Finally, a restart of all GitSwarm EE processes is required for the changes
to take effect:

```bash
sudo gitswarm-ctl restart
```

## Pending Migrations

When any migrations are pending, the metrics are disabled until the
migrations have been performed.

---

Read more on:

- [Introduction to GitSwarm EE Performance Monitoring](introduction.md)
- [InfluxDB Configuration](influxdb_configuration.md)
- [InfluxDB Schema](influxdb_schema.md)
