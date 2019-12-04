### What to Whitelist or Blacklist

[This extension for Google Chrome](https://chrome.google.com/webstore/detail/adamone-assistant/fdmpekabnlekabjlimjkfmdjajnddgpc) can help you in finding out which domains you need to whitelist.


### How to Whitelist or Blacklist

There are scripts to aid users in adding or removing domains to the whitelist or blacklist. 

The scripts will first parse `whitelist.txt` or `blacklist.txt` for any changes, and if any additions or deletions are detected, it will reload `dnsmasq` so that they are effective immediately.

Each script accepts the following parameters:

<table>
  <tbody>
      <tr>
         <th><code>[domain]</code></th>
         <td>Fully qualified domain name you wish to add or remove. You can pass any number of domains.</td>
      </tr>     
      <tr>
         <th><code>-d</code></th>
         <td>Removal mode. Domains will be removed from the list, rather than added</td>
      </tr>     
      <tr>
         <th><code>-nr</code></th>
         <td>Update blacklist without refreshing dnsmasq</td>
      </tr>
      <tr>
         <th><code>-f</code></th>
         <td>Force delete cached blocklist content</td>
      </tr>
      <tr>
         <th><code>-q</code></th>
         <td>Quiet mode. Console output is minimal. Useful for calling from another script (see <code>gravity.sh</code>)</td>
      </tr>
   </tbody>
</table>

Domains passed are parsed by the script to ensure they are valid domains. If a domain is invalid it will be ignored.


##### Example `pihole -w` usages

<table>
  <tbody>
      <tr>
         <th><code>pihole -w domain1 [domain2...]</code></th>
         <td>Attempt to add one or more domains to the whitelist and reload dnsmasq.</td>
      </tr>     
      <tr>
         <th><code>pihole -w -nr domain1 [domain2...]</code></th>
         <td>Attempt to add one or more domains to the whitelist, but do not reload dnsmasq.</td>
      </tr>     
      <tr>
         <th><code>pihole -w -f domain1 [domain2...]</code></th>
         <td>Attempt to add one or more domains to the whitelist and force dnsmasq to reload</td>
      </tr>
   </tbody>
</table>

To remove domains from the whitelist:
Add `-d` as an additional argument (e.g `pihole -w -d domain1 [domain2...]`)


##### Example `pihole -b` usages

<table>
  <tbody>
      <tr>
         <th><code>pihole -b domain1 [domain2...]</code></th>
         <td>Attempt to add one or more domains to the blacklist and reload dnsmasq.</td>
      </tr>     
      <tr>
         <th><code>pihole -b -nr domain1 [domain2...]</code></th>
         <td>Attempt to add one or more domains to the blacklist, but do not reload dnsmasq.</td>
      </tr>     
      <tr>
         <th><code>pihole -b -f domain1 [domain2...]</code></th>
         <td>Attempt to add one or more domains to the blacklist and force dnsmasq to reload</td>
      </tr>
   </tbody>
</table>

To remove domains from the blacklist:
Add `-d` as an additional argument (e.g `pihole -b -d domain1 [domain2...]`)