# SQLMON
A few years ago I needed to establish baseline metrics for an MSSQL Server's performance. As my first real Sql project, I built SQLMON.

In production SQLMON was paired with a simple Powershell service that pumped the metrics collcted into Graphite, which is what we used to help troubleshoot performance issues.

SQLMON was used in production with Sql Server 2008R2.