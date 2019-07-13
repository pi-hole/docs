## Group management
Any blocklist or domain on the white-/black-/regex-lists can be managed through groups. This allows not only grouping them together to highlight their relationship, but also enabling/disabling them together if one, for instance, wants to visit a specific service only temporarily.

Groups are defined in the `group` table and can have an optional description in addition to a mandatory name of the group.

Label | Type | Uniqueness enforced | Content
----- | ---- | ------------------- | --------
`id` | integer | Yes | Unique ID for database operations
`enabled` | boolean | No | Flag whether domains in this group should be used<br>(`0` = disabled, `1` = enabled)
`name` | text | No | Mandatory group name
`comment` | text | No | Optional field for arbitrary user comments

Group management is implemented using so called linking tables. Hence, it is possible to
- associate domains with any number of groups,
- manage adlists together with groups,
- use the same groups for, e.g., black- and whitelisted domains at the same time.

The linking tables are particularly simple, as they only link group `id`s with list `id`s. As an example, we describe the `whitelist_by_group` table. All other linking tables are constructed similarly.

Label | Type | Content
----- | ---- | -------
`whitelist_id` | integer | `id` of domain in the `whitelist` table
`group_id` | integer | `id` of associated group in the `group` table

## Effect of group management
The great flexibility to manage domains in no, one, or multiple groups may result in unexpected behavior when, e.g., the domains are enabled in some but disabled in other groups. For the sake of convenience, we describe all possible configurations and whether *FTL*DNS uses these domains (&#10004;) or not (&#10008;) in these cases.

- Domain disabled: &#10008;<br>Note that the domain is never imported by *FTL*DNS, even if it is contained in an enabled group.

- Domain enabled: It depends...
    - Not managed by a group: &#10004;
    - Contained in one or more groups (at least one enabled): &#10004;
    - Contained in one or more groups (all disabled): &#10008;
