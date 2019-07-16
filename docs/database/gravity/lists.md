## Whitelist
### Exact Whitelisting Table (`whitelist`)
The `whitelist` table contains all whitelisted domains. It has a few extra fields to store data related to a given domain such as the `enabled` state, the dates when the domain were added and when it has last been modified, and an optional comment.

The date fields are defined as `INTEGER` fields as they expect numerical timestamps also known as *UNIX time*. The `date_added` and `date_modified` fields are initialized with the current timestamp converted to UNIX time. The  `comment` field is optional and can be empty.

Pi-hole's *FTL*DNS reads the whitelisted table through the `vw_whitelist` view, omitting any disabled domains.

Label | Type | Uniqueness enforced | Content
----- | ---- | ------------------- | --------
`id` | integer | Yes | Unique ID for database operations
`domain` | text | Yes | Domain
`enabled` | boolean | No | Flag whether domain should be used by `pihole-FTL`<br>(`0` = disabled, `1` = enabled)
`date_added` | integer | No | Timestamp when domain was added
`date_modified` | integer | No | Timestamp when domain was last modified, automatically updated when a record is changed
`comment` | text | No | Optional field for arbitrary user comments

### Regex Whitelisting Table (`regex_whitelist`)
In addition to the `whitelist` table, we also provide a `regex_whitelist` table containing all regex based whitelisting filters. Just like the `whitelist` table, it has a few extra fields to store data related to a given filter.

Its schema is identical to the schema of the `whitelist` table.

## Blacklist
### Exact Blacklisting Table (`blacklist`)
The `blacklist` table contains all blacklisted domains. Just like the `whitelist` table, it has a few extra fields to store data related to a given domain such as the `enabled` state, the dates when the domain were added and when it has last been modified, and an optional comment.

Its schema is identical to the schema of the `whitelist` table.

### Regex Blacklisting Table (`regex_blacklist`)
Just as for whitelisting, *FTL*DNS also supports blacklisting using regular expression filters.

The schema of the `regex_blacklist` table is identical to the schema of the `whitelist` table.

## Adlist Table (`adlist`)
The `adlist` table contains all sources for domains to be collected by `pihole -g`. Just like the other tables, it has a few extra fields to store meta data related to a given source.

Label | Type | Uniqueness enforced | Content
----- | ---- | ------------------- | --------
`id` | integer | Yes | Unique ID for database operations
`address` | text | Yes | The URL of the list
`enabled` | boolean | No | Flag whether domain should be used by `pihole-FTL`<br>(`0` = disabled, `1` = enabled)
`date_added` | integer | No | Timestamp when domain was added
`date_modified` | integer | No | Timestamp when domain was last modified, automatically updated when a record is changed
`comment` | text | No | Optional field for arbitrary user comments

{!abbreviations.md!}
