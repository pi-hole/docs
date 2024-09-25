---
title: Domain Database
---

Pi-hole uses the well-known relational database management system SQLite3 for managing the various domains that are used to control the DNS filtering system. The database-based domain management has been added with Pi-hole v5.0. The ability to subscribe to external *allow*lists has been added with Pi-hole v6.0.

## Priorities

Pi-hole uses the following priorities when deciding whether to block or allow a domain:

1. Exact allowlist entries
2. Regex allowlist entries
3. Exact blocklist entries
4. Subscribed allowlists
5. Subscribed blocklists
6. Regex blocklist entries

## Domain tables (`domainlist`)

The database stores allow-, and blocklists which are directly relevant for Pi-hole's domain blocking behavior. The `domainlist` table contains all domains on the allow- and blocklists. It has a few extra fields to store data related to a given domain such as the `enabled` state, the dates when the domain was added and when it was last modified, and an optional comment.

The date fields are defined as `INTEGER` fields as they expect numerical timestamps also known as *UNIX time*. The `date_added` and `date_modified` fields are initialized with the current timestamp converted to UNIX time. The `comment` field is optional and can be empty.

Pi-hole's *FTL*DNS reads the tables through the various view, omitting any disabled domains.

Label | Type | Uniqueness enforced | Content
----- | ---- | ------------------- | --------
`id` | integer | Yes | Unique ID for database operations
`type` | integer | No | `0` = exact allowlist,<br> `1` = exact blocklist,<br> `2` = regex allowlist,<br> `3` = regex blocklist
`domain` | text | Yes | Domain
`enabled` | boolean | No | Flag whether domain should be used by `pihole-FTL`<br>(`0` = disabled, `1` = enabled)
`date_added` | integer | No | Timestamp when domain was added
`date_modified` | integer | No | Timestamp when domain was last modified, automatically updated when a record is changed
`comment` | text | No | Optional field for arbitrary user comments, only field that is allowed to be `NULL`

## List Table (`adlist`)

The `adlist` table contains all sources for domains to be collected by `pihole -g`. Just like the other tables, it has a few extra fields to store metadata related to a given source.

Label | Type | Uniqueness enforced | Content
----- | ---- | ------------------- | --------
`id` | integer | Yes | Unique ID for database operations
`address` | text | Yes | The URL of the list
`enabled` | boolean | No | Flag whether domain should be used by `pihole-FTL`<br>(`0` = disabled, `1` = enabled)
`date_added` | integer | No | Timestamp when domain was added
`date_modified` | integer | No | Timestamp when domain was last modified, automatically updated when a record is changed
`comment` | text | No | Optional field for arbitrary user comments
`date_updated` | integer | No | Timestamp when this list has last been updated (`pihole -g` does **not** update this timestamp when the downloaded list did not change since the last `pihole -g` run)
`number` | integer | No | Number of domains on this list
`invalid_domains` | integer | No | Number of invalid domains on this list
`status` | integer | No | `1` = List download was successful, `2` = List unchanged upstream, Pi-hole used a local copy, `3` = List unavailable, Pi-hole used a local copy, `4` = List unavailable, there is no local copy of this list available on your Pi-hole

## Gravity Tables (`gravity` and `antigravity`)

The `gravity` and `antigravity` table consists of the domains that have been processed by Pi-hole's `gravity` (`pihole -g`) command. The domains in this list are the collection of domains sourced from the configured sources (see the [List Table (`adlist`)](index.md#list-table-adlist)).

During each run of `pihole -g`, these tables are flushed and completely rebuilt from the newly obtained set of domains to be blocked or allowed.

Label | Type | Content
----- | ---- | -------
`domain` | text | Domain compiled from subscribed list referenced by `adlist_id`
`adlist_id` | integer | ID associated to subscribed list in table `adlist`

Uniqueness is enforced on pairs of (`domain`, `adlist_id`) in both tables. In other words: domains can be added multiple times, however, only when they are referencing different lists as their origins.

## Client table (`client`)

Clients are identified by their IP addresses. Each client automatically gets a unique identifier (`id`).

Label | Type | Content
----- | ---- | -------
`id` | integer | Client ID (autoincrementing)
`ip` | text | IP address of the client (IPv4 or IPv6), Uniqueness is enforced
`date_added` | integer | Timestamp when a client was added
`date_modified` | integer | Timestamp when a client was last modified, automatically updated when a record is changed
`comment` | text | Optional field for arbitrary user comments, the only field that is allowed to be `NULL`

Clients can be identified by subnets. Arbitrary subnet configurations can be specified using the widely known [Classless Inter-Domain Routing (CIDR) notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_blocks).
This allows to specify "broad clients" such as

- `192.168.1.0/24` which will match al clients in the range `192.168.1.1` to `192.168.1.255` (256 devices),
- `10.8.0.0/16` will match all clients in the range `10.8.0.1` to `10.8.255.255` (65,536 devices), and
- `192.168.100.0/22` representing the 1024 IPv4 addresses from `192.168.100.0` to `192.168.103.255`.

CIDR notation can be used for IPv6 subnets as well. The IPv6 block `2001:db8::/48` represents all IPv6 addresses from `2001:db8:0:0:0:0:0:0` to `2001:db8:0:ffff:ffff:ffff:ffff:ffff` (1,208,925,819,614,629,174,706,176 = roughly one heptillion devices).

Note that Pi-hole's implementation is more generic than what is written on the linked Wikipedia article as you can use *any* CIDR block (not only multiples of 4).
