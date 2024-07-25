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

The long-term database contains several tables:

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
`reply_type` | integer | Yes | Type of the reply for this query  (see [Supported reply types](ftl.md#supported-reply-types))
`reply_time` | real | Yes | Seconds it took until the final reply was received
`dnssec` | integer | Yes | Type of the DNSSEC status for this query  (see [DNSSEC status](ftl.md#dnssec-status))

The `queries` `VIEW` is dynamically generated from the data actually stored in the `query_storage` table and the linking tables `domain_by_id`, `client_by_id`, `forward_by_id`, and `addinfo_by_id` (see below). The table `query_storage` will contains integer IDs pointing to the respective entries of the linking tables to save space and make searching the database faster. If you haven't upgraded for some time, the table may still contain strings instead of integer IDs.

#### Data-dependent `additional_info` field

The content and type of the `additional_info` row depends on the status of the given query. For many queries, this field is empty. You should, however, not rely on this field being empty as we may add content of any type for other status types in future releases.

##### Query blocked due to a CNAME inspection (status 9, 10, 11) {#additional_info_cname data-toc-label='Blocked CNAME'}

If a query was blocked due to a CNAME inspection (status 9, 10, 11), this field contains the domain which was the reason for blocking the entire CNAME chain (text).

##### Query influenced by a black- or whitelist entry {#additional_info_list data-toc-label='domainlist_id'}

If a query was influenced by a black- or whitelist entry, this field contains the ID of the corresponding entry in the [`domainlist`](gravity/index.md#domain-tables-domainlist) table.

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

ID | Resource Record (a.k.a. query type)
--- | ---
1 | `A`
2 | `AAAA`
3 | `ANY`
4 | `SRV`
5 | `SOA`
6 | `PTR`
7 | `TXT`
8 | `NAPTR`
9 | `MX`
10 | `DS`
11 | `RRSIG`
12 | `DNSKEY`
13 | `NS`
14 | `OTHER` (any query type not covered elsewhere, but see note below)
15 | `SVCB`
16 | `HTTPS`

Any other query type will be stored with an offset of 100, i.e., `TYPE66` will be stored as `166` in the database (see [pi-hole/FTL #1013](https://github.com/pi-hole/FTL/pull/1013)). This is done to allow for future extensions of the query type list without having to change the database schema. The `OTHER` query type is deprecated since Pi-hole FTL v5.4 (released Jan 2021) and not used anymore. It is kept for backwards compatibility. Note that `OTHER` is still used for the [regex extension `querytype=`](../regex/pi-hole.md#only-match-specific-query-types) filter and used for all queries not covered by the above list.

### Supported status types

ID | Status | | Details
--- | --- | --- | ---
0 | Unknown | ❔ | Unknown status (not yet known)
1 | Blocked | ❌ | Domain contained in [gravity database](gravity/index.md#gravity-table-gravity)
2 | Allowed | ✅ | Forwarded
3 | Allowed | ✅ | Replied from cache
4 | Blocked | ❌ | Domain matched by a [regex blacklist](gravity/index.md#domain-tables-domainlist) filter
5 | Blocked | ❌ | Domain contained in [exact blacklist](gravity/index.md#domain-tables-domainlist)
6 | Blocked | ❌ | By upstream server (known blocking page IP address)
7 | Blocked | ❌ | By upstream server (`0.0.0.0` or `::`)
8 | Blocked | ❌ | By upstream server (`NXDOMAIN` with `RA` bit unset)
9 | Blocked | ❌ | Domain contained in [gravity database](gravity/index.md#gravity-table-gravity)<br>*Blocked during deep CNAME inspection*
10 | Blocked | ❌ | Domain matched by a [regex blacklist](gravity/index.md#domain-tables-domainlist) filter<br>*Blocked during deep CNAME inspection*
11 | Blocked | ❌ | Domain contained in [exact blacklist](gravity/index.md#domain-tables-domainlist)<br>*Blocked during deep CNAME inspection*
12 | Allowed | ✅ | Retried query
13 | Allowed | ✅ | Retried but ignored query (this may happen during ongoing DNSSEC validation)
14 | Allowed | ✅ | Already forwarded, not forwarding again
15 | Blocked | ❌ | Blocked (database is busy)<br> How these queries are handled can be [configured](../ftldns/configfile.md#reply_when_busy)
16 | Blocked | ❌ | Blocked (special domain)<br>*E.g. Mozilla's canary domain and Apple's Private Relay domains* <br> Handling can be [configured](../ftldns/configfile.md)
17 | Allowed | ✅⌛ | Replied from *stale* cache

### Supported reply types

ID | Reply type is
--- | ---
0 | *unknown* (no reply so far)
1 | `NODATA`
2 | `NXDOMAIN`
3 | `CNAME`
4 | a valid `IP` record
5 | `DOMAIN`
6 | `RRNAME`
7 | `SERVFAIL`
8 | `REFUSED`
9 | `NOTIMP`
10 | `OTHER`
11 | `DNSSEC`
12 | `NONE` (query was dropped intentionally)
13 | `BLOB` (binary data)

### DNSSEC status

ID | DNSSEC status is
--- | ---
0 | *unknown*
1 | `SECURE`
2 | `INSECURE`
3 | `BOGUS`
4 | `ABANDONED`

### Linking tables

The `queries` `VIEW` reads repeating properties from linked tables to reduce both database size and search complexity. These linking tables, `domain_by_id`, `client_by_id`, `forward_by_id`, and `addinfo_by_id` all have a similar structure:

#### `domain_by_id`

Label | Type | Allowed to by empty | Content
--- | --- | --- | ---
`id` | integer | No | ID of the entry. Used by `query_storage`
`domain` | text | No | Domain name

#### `client_by_id`

Label | Type | Allowed to by empty | Content
--- | --- | --- | ---
`id` | integer | No | ID of the entry. Used by `query_storage`
`ip` | text | No | Client IP address
`name` | text | Yes | Client host name

#### `forward_by_id`

Label | Type | Allowed to by empty | Content
--- | --- | --- | ---
`id` | integer | No | ID of the entry. Used by `query_storage`
`forward` | text | No | Upstream server identifier (`<ipaddr>#<port>`)

#### `addinfo_by_id`

Label | Type | Allowed to by empty | Content
--- | --- | --- | ---
`id` | integer | No | ID of the entry. Used by `query_storage`
`type` | integer | No | Type of the `content` field
`content` | blob | No | Type-dependent content

Valid `type` IDs are currently

- `ADDINFO_CNAME_DOMAIN = 1` - `content` is a string (the related CNAME)
- `ADDINFO_DOMAIN_ID = 2` - `content` is an integer (ID pointing to a domain in the [`domainlist` table](gravity/index.md#domain-tables-domainlist))

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
