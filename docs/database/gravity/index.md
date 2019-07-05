Pi-hole uses the well-known relational database management system SQLite3 for managing the various domains that are used to control the DNS filtering system. The database-based domain management has been added with Pi-hole v5.0.

## Domain lists
The database stores white-, black-, and regex lists which are all directly relevant for Pi-hole's domain blocking behavior. They are stored alongside some properties such as if they are currently enabled or when they have last been modified. For a full description, see the [domain lists](lists.md) page.

## Domain group management
In addition to the ability to add comments to individual domains, we also offer a powerful way of managing domains through groups. Each domain can be associated with no group, exactly one group, or multiple groups. See [domain group management](groups.md) for further details.

## Gravity Table (`gravity`)
The `gravity` table consists of the domains that have been processed by Pi-hole's `gravity` (`pihole -g`) command. The domain in this list are the unique collection of domains sourced from the configured sources (see the [`adlist` table](lists.md#adlist-table-adlist).

During each run of `pihole -g`, this table is flushed and completely rebuilt from the newly obtained set of domains to be blocked.

Label | Type | Uniqueness enforced | Content
----- | ---- | ------------------- | --------
`domain` | text | Yes | Blocked domain compiled from enabled adlists

## Audit Table (`auditlist`)
The `audit` table contains domains that have been audited by the user on the web interface.

Label | Type | Uniqueness enforced | Content
----- | ---- | ------------------- | --------
`id` | integer | Yes | Unique ID for database operations
`domain` | text | Yes | Domain
`date_added` | integer | No | Unix timestamp when domain was added
