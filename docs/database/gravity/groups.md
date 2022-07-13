## Group management

Groups are defined in the `group` table and can have an optional description in addition to the mandatory name of the group.

Label | Type | Uniqueness enforced | Content
----- | ---- | ------------------- | --------
`id` | integer | Yes | Unique ID for database operations
`enabled` | boolean | No | Flag whether domains in this group should be used<br>(`0` = disabled, `1` = enabled)
`name` | text | Yes | Mandatory group name
`description` | text | No | Optional field for arbitrary user comments

Group management is implemented using so-called linking tables. Hence, it is possible to

- associate domains (and clients!) with any number of groups,
- manage adlists together with groups,
- use the same groups for black- and whitelisted domains at the same time.

The linking tables are particularly simple, as they only link group `id`s with list `id`s. As an example, we describe the `domainlist_by_group` table. The `adlist` and `client` linking tables are constructed similarly.

Label | Type | Content
----- | ---- | -------
`domainlist_id` | integer | `id` of domain in the `domainlist` table
`group_id` | integer | `id` of associated group in the `group` table

Group `Default` (`group_id` `0`) is special as it is automatically assigned to domains and clients not being a member of other groups. Each newly added client or domain gets assigned to group zero when being added.
