Pi-hole *FTL*DNS uses the well-known relational database management system SQLite3 as its long-term storage of query data. In contrast to many other database management solutions, *FTL*DNS does not need a server database engine as the database engine is directly embedded in *FTL*DNS. It seems an obvious choice as it is probably the most widely deployed database engine - it is used today by several widespread web browsers, operating systems, and embedded systems (such as mobile phones), among others. Hence, it is rich in supported platforms and offered features. SQLite implements most of the SQL-92 standard for SQL and can be used for high-level queries.

The long-term query database was the first database that was added to the Pi-hole project.
We update this database periodically and on the exit of *FTL*DNS (triggered e.g. by a `service pihole-FTL restart`). The updating frequency can be controlled by the parameter [`DBINTERVAL`](../ftldns/configfile.md#dbinterval) and defaults to once per minute. We think this interval is sufficient to protect against data losses due to power failure events. *FTL*DNS needs the database to populate its internal history of the most recent 24 hours. If the database is disabled, *FTL*DNS will show an empty query history after a restart.

The location of the database can be configured by the config parameter [`DBFILE`](../ftldns/configfile.md#dbfile). It defaults to `/etc/pihole/pihole-FTL.db`. If the given file does not exist, *FTL*DNS will create a new (empty) database file.

Another way of controlling the size of the long-term database is by setting a maximum age for log queries to keep using the config parameter [`MAXDBDAYS`](../ftldns/configfile.md#maxdbdays). It defaults to 365 days, i.e. queries that are older than one year get periodically removed to limit the growth of the long-term database file.

The config parameter [`DBIMPORT`](../ftldns/configfile.md#dbimport) controls whether `FTL` loads information from the database on startup. It needs to do this to populate the internal data structure with the most recent history. However, as importing from the database on disk can delay FTL on very large deploys, it can be disabled using this option.

---

### Split database

You can split your long-term database by periodically rotating the database file (do this only when `pihole-FTL` is *not* running). The individual database contents can easily be merged when required.
This could be implemented by running a monthly `cron` job such as:

```bash
sudo service pihole-FTL stop
sudo mv /etc/pihole/pihole-FTL.db /media/backup/pihole-FTL_$(date +"%m-%y").db
sudo service pihole-FTL start
```

Note that DNS resolution will not be available as long as `pihole-FTL` is stopped.

### Backup database

The database can be backed up while FTL is running when using the SQLite3 Online backup method, e.g.,

```bash
sqlite3 /etc/pihole/pihole-FTL.db ".backup /home/pi/pihole-FTL.db.backup"
```

will create `/home/pi/pihole-FTL.db.backup` which is a copy of your long-term database.

---

The long-term database contains three tables:

### Query Table

Label | Type | Allowed to by empty | Content
--- | --- | ---- | -----
`id` | integer | No | autoincrement ID for the table, only used by SQLite3, not by *FTL*DNS
`timestamp` | integer | No | Unix timestamp when this query arrived at *FTL*DNS (used as index)
`type` | integer | No | Type of this query (see [Supported query types](ftl.md#supported-query-types))
`status` | integer | No | How was this query handled by *FTL*DNS? (see [Supported status types](ftl.md#supported-status-types))
`domain` | text | No | Requested domain
`client` | text | No | Requesting client (IP address)
`forward` | text | Yes | Forward destination used for this query (only set if `status == 2`)
`additional_info` | blob | Yes | Data-dependent content, see below

#### Data-dependent `additional_info` field

The content and type of the `additional_info` row depends on the status of the given query.

##### Query blocked due to a CNAME inspection (status 9, 10, 11) {#additional_info_cname data-toc-label='Blocked CNAME'}

If a query was blocked due to a CNAME inspection (status 9, 10, 11), this field contains the domain which was the reason for blocking the entire CNAME chain (text).

##### Query blocked due to a REGEX filter (status 4) {#additional_info_regex data-toc-label='Regular expression'}

If a query was blocked due to a regex rule (status 4), this field contains the ID of the blacklist regex responsible for blocking this domain (integer).

##### Other

For any other query status, this field is empty. You should, however, not rely on this field being empty as we may add content of any type for other status types in future releases.

### Counters table

This table contains counter values integrated over the entire lifetime of the table

Label | Type | Allowed to by empty | Content
--- | --- | ---- | -----
`id` | integer | No | ID for the table used to select a counter (see below)
`value` | integer | No | Value of a given counter

ID | Interpretation
--- | ---
0 | Total number of queries
1 | Total number of blocked queries

### FTL table

The FTL table contains some data used by *FTL*DNS for determining which queries to save to the database. This table does not contain any entries of general interest.

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
8 | NAPTR
9 | MX
10 | DS
11 | RRSIG
12 | DNSKEY
13 | OTHER (any query type not covered above)


<!-- ID | 1 | 2 | 3 | 4 | 5 | 6 | 7 -->
<!-- -- | -- | -- | -- | -- | -- | -- | -- -->
<!-- Query | A | AAAA | ANY | SRV | SOA | PTR | TXT -->

### Supported status types

ID | Status | | Details
--- | --- | --- | ---
0 | Unknown | ❔ | was not answered by forward destination
1 | Blocked | ❌ | Domain contained in [gravity database](../database/gravity/index.md#gravity-table-gravity)
2 | Allowed | ✅ | Forwarded
3 | Allowed | ✅ | Known, replied to from cache
4 | Blocked | ❌ | Domain matched by a [regex blacklist](../database/gravity/index.md#regex-table-regex) filter
5 | Blocked | ❌ | Domain contained in [exact blacklist](../database/gravity/index.md#blacklist-table-blacklist)
6 | Blocked | ❌ | By upstream server (known blocking page IP address)
7 | Blocked | ❌ | By upstream server (`0.0.0.0` or `::`)
8 | Blocked | ❌ | By upstream server (`NXDOMAIN` with `RA` bit unset)
9 | Blocked | ❌ | Domain contained in [gravity database](../database/gravity/index.md#gravity-table-gravity)<br>*Blocked during deep CNAME inspection*
10 | Blocked | ❌ | Domain matched by a [regex blacklist](../database/gravity/index.md#regex-table-regex) filter<br>*Blocked during deep CNAME inspection*
11 | Blocked | ❌ | Domain contained in [exact blacklist](../database/gravity/index.md#blacklist-table-blacklist)<br>*Blocked during deep CNAME inspection*

### Example for interaction with the long-term query database

In addition to the interactions the Pi-hole database API offers, you can also run your own SQL commands against the database. If you want to obtain the three most queries domains for all time, you could use

```bash
sqlite3 "/etc/pihole/pihole-FTL.db" "SELECT domain,count(domain) FROM queries WHERE (STATUS == 2 OR STATUS == 3) GROUP BY domain ORDER BY count(domain) DESC LIMIT 3"
```

which would return something like

```text
discourse.pi-hole.net|421095
www.pi-hole.net|132483
posteo.de|130243
```

showing the domain and the number of times it was found in the long-term database. Note that such a request might take a very long time for computation as the entire history of queries has to be processed for this.

{!abbreviations.md!}
