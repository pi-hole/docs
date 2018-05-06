Pi-hole *FTL*DNS uses the well-known relational database management system SQLite3 it's long-term storage of query data. In contrast to many other database management solutions, *FTL*DNS does not need a server database engine as the database engine is directly embeeded in *FTL*DNS. It seems an obvious choice as tt is probably the most widely deployed database engine - it is used today by several widespread browsers, operating systems, and embedded systems (such as mobile phones), among others. Hence, it is rich in supported platform and offered features. SQLite implements most of the SQL-92 standard for SQL and can be used for high-level queries.

We update the database file periodically and on exit of *FTL*DNS (triggered e.g. by a `service restart`). The updating frequency can be controlled by the parameter [`DBINTERVAL`](configfile.md#dbinterval) and defaults to once per minute. We think this value is a good compromise between SD card load due to writing and protection against data losses due to power failure events. *FTL*DNS needs the database to populate its internal history of the most recent 24 hours. If the database is disabled, *FTL*DNS will show an empty query history after a restart.

The location of the database can be configures by the config parameter [`DBFILE`](configfile.md#dbfile). It defaults to `/etc/pihole/pihole-FTL.db`. If the given files does not exist, *FTL*DNS will create a new file.

You can split your long-term database by periodically rotating the database file (do this only when `pihole-FTL` is *not* running). The individual database contents can easily be merged when required.
This could be implemented by running a monthly `cron` job such as:
```
sudo service pihole-FTL stop
sudo mv /etc/pihole/pihole-FTL.db /media/backup/pihole-FTL_$(date +"%m-%y").db
sudo service pihole-FTL start
```
Note that DNS resolution will not be available as long as `pihole-FTL` is stopped.

Another way of controling the size of the long-term database is setting a maximal age for log queries to keep using the config parameter [`MAXDBDAYS`](configfile.md#maxdbdays). It defaults to 365 days, i.e. queries that are older than one year get periodically removed to limit the growth of the long-term database file.

---

The long-term database contains three tables:

### Query Table

Label | Type | Allowed to by empty | Content
--- | --- | ---- | -----
`id` | integer | No | autoincrement ID for the table, only used by SQLite3, not by *FTL*DNS
`timestamp` | integer | No | Unix timestamp when this query arrived at *FTL*DNS (used as index)
`type` | integer | No | Type of this query (see [Supported query types](database.md#supported-query-types))
`status` | integer | No | How was this query handled by *FTL*DNS? (see [Supported status types](database.md#supported-status-types))
`domain` | text | No | Requested domain
`client` | text | No | Requesting client
`forward` | text | Yes | Forward destination used for this query (only set if `status == 2`)

SQLite3 syntax used to create this table:
```
CREATE TABLE queries ( id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER NOT NULL, type INTEGER NOT NULL, status INTEGER NOT NULL, domain TEXT NOT NULL, client TEXT NOT NULL, forward TEXT );
CREATE INDEX idx_queries_timestamps ON queries (timestamp);
```

### Counters table
This table contains counter values integrated over the entire lifetime of the table

Label | Type | Allowed to by empty | Content
--- | --- | ---- | -----
`id` | integer | No | ID for the table used to select a counter (see below)
`value` | integer | No | Value of a given counter

Counter ID | Interpretation
--- | ---
0 | Total number of queries
1 | Total number of blocked queries (Query `status` 1, 4 or 5)

SQLite3 syntax used to create this table:
```
CREATE TABLE counters ( id INTEGER PRIMARY KEY NOT NULL, value INTEGER NOT NULL );
```

### FTL table
The FTL tables contains some data used by *FTL*DNS for determining which queries to save to the database. This table does not contain any entries of general interest.

SQLite3 syntax used to create this table:
```
CREATE TABLE ftl ( id INTEGER PRIMARY KEY NOT NULL, value BLOB NOT NULL );
```

### Supported query types
ID | Query Type
--- | ---
1 | A
2 | AAAA
3 | ANY
4 | SRV
5 | SOA
6 | PTR
7 | TXT

<!-- ID | 1 | 2 | 3 | 4 | 5 | 6 | 7 -->
<!-- -- | -- | -- | -- | -- | -- | -- | -- -->
<!-- Query | A | AAAA | ANY | SRV | SOA | PTR | TXT -->

### Supported status types
ID | Query Type
--- | ---
0 | Unknown status (was not answered by forward destination)
1 | Blocked by `gravity.list`
2 | Permitted + forwarded
3 | Permitted + replied to from cache
4 | Blocked by wildcard
5 | Blocked by `black.list`
