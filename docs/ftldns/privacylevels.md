Using privacy levels you can specify which level of detail you want to see in your Pi-hole statistics. The privacy level may be changed at any time without having to restart the DNS resolver. Note that queries with (partially) hidden details cannot be disclosed with a subsequent reduction of the privacy level. They can be changed either from the Settings page on the dashboard or in [FTL's config file](configfile.md).

The available options are

### Level 0 - show everything

Doesn't hide anything, all statistics are available

### Level 1 - hide domains

Show and store all domains as `hidden`

This setting disables

- Top Domains
- Top Ads

### Level 2 - hide domains and clients

Show and store all domains as `hidden` and clients as `0.0.0.0`

This setting disables

- Top Domains
- Top Ads
- Top Clients
- Clients over time

### Level 3 - anonymous mode (anonymize everything)

Disable all details except the most anonymous statistics

This setting disables

- Top Domains
- Top Ads
- Top Clients
- Clients over time
- Query Log
- Long-term database logging
