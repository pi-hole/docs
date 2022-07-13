## Group management

Any blocklist or domain on the white-/black-/regex-lists can be managed through groups. This allows not only grouping them to highlight their relationship, but also enabling/disabling them together if one, for instance, wants to visit a specific service only temporarily.

Group `Default` (`group_id` `0`) is special as it is automatically assigned to domains and clients not being a member of other groups. Each newly added client or domain gets assigned to group zero when being added.

## Effect of group management

The great flexibility to manage domains in zero, one, or multiple groups may result in unexpected behavior when, e.g., the domains are enabled in some but disabled in other groups.
