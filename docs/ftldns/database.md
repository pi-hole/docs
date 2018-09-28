Pi-hole *FTL*DNS uses the well-known relational database management system SQLite3 as it's long-term storage of query data. In contrast to many other database management solutions, *FTL*DNS does not need a server database engine as the database engine is directly embedded in *FTL*DNS. It seems an obvious choice as it is probably the most widely deployed database engine - it is used today by several widespread web browsers, operating systems, and embedded systems (such as mobile phones), among others. Hence, it is rich in supported platforms and offered features. SQLite implements most of the SQL-92 standard for SQL and can be used for high-level queries.

We update the database file periodically and on exit of *FTL*DNS (triggered e.g. by a `service pihole-FTL restart`). The updating frequency can be controlled by the parameter [`DBINTERVAL`](configfile.md#dbinterval) and defaults to once per minute. We think this interval is sufficient to protect against data losses due to power failure events. *FTL*DNS needs the database to populate its internal history of the most recent 24 hours. If the database is disabled, *FTL*DNS will show an empty query history after a restart.

The location of the database can be configures by the config parameter [`DBFILE`](configfile.md#dbfile). It defaults to `/etc/pihole/pihole-FTL.db`. If the given file does not exist, *FTL*DNS will create a new (empty) database file.

You can split your long-term database by periodically rotating the database file (do this only when `pihole-FTL` is *not* running). The individual database contents can easily be merged when required.
This could be implemented by running a monthly `cron` job such as:
```
sudo service pihole-FTL stop
sudo mv /etc/pihole/pihole-FTL.db /media/backup/pihole-FTL_$(date +"%m-%y").db
sudo service pihole-FTL start
```
Note that DNS resolution will not be available as long as `pihole-FTL` is stopped.

The database can be backed up while FTL is running when using the SQLite3 Online backup method, e.g.,
```
sqlite3 /etc/pihole/pihole-FTL.db ".backup /home/pi/pihole-FTL.db.backup"
```
will create `/home/pi/pihole-FTL.db.backup` which is a copy of your long-term database.

Another way of controlling the size of the long-term database is setting a maximum age for log queries to keep using the config parameter [`MAXDBDAYS`](configfile.md#maxdbdays). It defaults to 365 days, i.e. queries that are older than one year get periodically removed to limit the growth of the long-term database file.

The config parameter [`DBIMPORT`](configfile.md#dbimport) controls whether `FTL` loads information from the database on startup. It need to do this to populate the internal datastructure with the most recent history. However, as importing from the database on disk can delay FTL on very large deploys, it can be disabled using this option.

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
`client` | text | No | Requesting client (IP address)
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

### Example for interaction with the FTL long-term database
In addition to the interactions the Pi-hole database API offers, you can also run your own SQL commands against the database. If you want to obtain the three most queries domains for all time, you could use
```
sqlite3 "/etc/pihole/pihole-FTL.db" "SELECT domain,count(domain) FROM queries WHERE (STATUS == 2 OR STATUS == 3) GROUP by domain order by count(domain) desc limit 3"
```
which would return something like
```
discourse.pi-hole.net|421095
www.pi-hole.net|132483
posteo.de|130243
```
showing the domain and the number of times it was found in the long-term database. Note that such a request might take very long for computation as the entire history of queries have to be processed for this.

{!abbreviations.md!}
