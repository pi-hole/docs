Pi-hole uses the well-known relational database management system SQLite3 for managing the various domains that are used to control the DNS filtering system. The database-based domain management has been added with Pi-hole v5.0.

## Gravity Table
The `gravity` table consists of the domains that have been processed by Pi-hole's `gravity` (`pihole -g`) command. The domain in this list are the unique collection of domains sources from the configured sources (see [Adlists Table](gravity.md#adlists-table)).

During each run of `pihole -g`, this table is flushed and completely rebuilt from the newly obtained set of domains to be blocked.

SQLite3 syntax used to create this table and its view:
```sql
CREATE TABLE gravity (domain TEXT UNIQUE NOT NULL);
```
## Whitelist Table
The `whitelist` table contains all manually whitelisted domains. It has a few extra fields to store data related to a given domain such as the `enabled` state, the dates when the domain were added and when it has last been modified, and an optional comment.

The date fields are defined as `INTEGER` fields as they expect numerical timestamps also known as *UNIX time*. The `date_added` field is initialized with the current timestamp converted to UNIX time. The `date_modified` as well as the `comment` fields are optional and can be empty (`NULL`).

Pi-hole's *FTL*DNS reads the whitelisted table through the `vw_whitelist` view, omitting any disabled (`enabled != 1`) domains.

SQLite3 syntax used to create this table and its view:
```sql
CREATE TABLE whitelist (domain        TEXT UNIQUE NOT NULL,
                        enabled       BOOLEAN     NOT NULL DEFAULT 1,
                        date_added    INTEGER     NOT NULL DEFAULT (cast(strftime('%s', 'now') as int)),
                        date_modified INTEGER,
                        comment       TEXT);
CREATE VIEW vw_whitelist AS SELECT DISTINCT a.domain FROM whitelist a WHERE a.enabled == 1;
```

## Blacklist Table
The `blacklist` table contains all manually blacklisted domains. Just like the `whitelist` table, it has a few extra fields to store data related to a given domain such as the `enabled` state, the dates when the domain were added and when it has last been modified, and an optional comment.

Pi-hole's *FTL*DNS reads the blacklisted table through the `vw_blacklist` view, omitting any disabled (`enabled != 1`) or whitelisted domains (domains in the `vw_whitelist` view).

SQLite3 syntax used to create this table and its view:
```sql
CREATE TABLE blacklist (domain        TEXT UNIQUE NOT NULL,
                        enabled       BOOLEAN     NOT NULL DEFAULT 1,
                        date_added    INTEGER     NOT NULL DEFAULT (cast(strftime('%s', 'now') as int)),
                        date_modified INTEGER,
                        comment       TEXT);
CREATE VIEW vw_blacklist AS SELECT DISTINCT a.domain FROM blacklist a WHERE
            a.enabled == 1 AND a.domain NOT IN vw_whitelist;
```

## Regex Table
The `regex` table contains all regex based filters. Just like the `black`- and `whitelist` tables, it has a few extra fields to store data related to a given filter.

SQLite3 syntax used to create this table and its view:
```sql
CREATE TABLE regex (domain        TEXT UNIQUE NOT NULL,
                    enabled       BOOLEAN     NOT NULL DEFAULT 1,
                    date_added    INTEGER     NOT NULL DEFAULT (cast(strftime('%s', 'now') as int)),
                    date_modified INTEGER,
                    comment       TEXT);
CREATE VIEW vw_regex AS SELECT DISTINCT a.domain FROM regex a WHERE a.enabled == 1;

```

## Adlists Table
The `adlists` table contains all sources for domains to be collected by `pihole -g`. Just like the other tables, it has a few extra fields to store data related to a given source.

SQLite3 syntax used to create this table and its view:
```sql
CREATE TABLE adlists (address       TEXT UNIQUE NOT NULL,
                      enabled       BOOLEAN     NOT NULL DEFAULT 1,
                      date_added    INTEGER     NOT NULL DEFAULT (cast(strftime('%s', 'now') as int)),
                      date_modified INTEGER,
                      comment       TEXT);

CREATE VIEW vw_adlists AS SELECT DISTINCT a.address FROM adlists a WHERE a.enabled == 1;
```
