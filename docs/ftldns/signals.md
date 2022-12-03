You can influence FTL by sending signals to the process. There are various signals supported to trigger specific actions, described below.

# Reload everything using `SIGHUP`

When FTL receives a `SIGHUP`, it clears the entire DNS cache, and then

- Re-loads
    - `/etc/hosts`,
    - `/etc/ethers`, and
    - any file given by
        - `dhcp-hostsfile`,
        - `dhcp-optsfile`,
        - `dhcp-hostsdir` (files in `dhcp-hostsdir` are also re-read on change, without the need to send a signal),
        - `dhcp-optsdir` (files in `dhcp-optsdir` are also re-read on change, without the need to send a signal),
        - `addn-hosts`, or
        - `hostsdir`.
- The DHCP lease change script is called for all existing DHCP leases.
- If `no-poll` is set, FTL also re-reads `/etc/resolv.conf`.
- The config file specified by `servers-file` is re-read.
    **Note:** No other `dnsmasq` config files are re-read.

- The FTL database connection (`/etc/pihole/pihole-FTL.db`) is re-opened.
- The privacy level is re-read from `pihole-FTL.conf` (`PRIVACY_LEVEL`).
- The blocking status is re-read from `setupVars.conf` (`BLOCKING_ENABLED`).
- The debug settings are re-read from `pihole-FTL.conf` (`DEBUG_*`).
- The gravity database connection (`/etc/pihole/gravity.db`) is re-opened.
- The number of blocked domains is updated.
- All regular expression (RegEx) filters in `gravity.db` are re-read and pre-compiled for fast execution later on.
- The blocking cache (storing if a domain has already been analyzed and what the result was) is cleared.
- If `DEBUG_CAPS` is enabled, the current set of available capabilities is logged.

# Real-time (RT) signals

While `SIGHUP` updates/flushes almost everything, such a massive operation is often not necessary. Hence, we added several small real-time signals available for fine-grained control of what FTL does. When you see `SIGHUP` as a "big gun", the real-time signals are rather the "scalpel" to serve rather specific needs.

Real-time signals are not guaranteed to have the same number on all operating systems. FTL will adapt accordingly. For the signals described below, we will always specify them with the real-time signal ID and the *typical* signal number in parentheses.

Real-time signal can always be executed relative to the first (= minimum) real-time signal just like (for real-time signal 0):

```bash
sudo pkill -SIGRTMIN+0 pihole-FTL
```

## Real-time signal 0 (SIG34)

This signal does:

- The gravity database connection (`/etc/pihole/gravity.db`) is re-opened.
- The number of blocked domains is updated.
- All regular expression (RegEx) filters in `gravity.db` are re-read and pre-compiled for fast execution later on.
- The blocking cache (storing if a domain has already been analyzed and what the result was) is cleared.
- The privacy level is re-read from `pihole-FTL.conf` (`PRIVACY_LEVEL`).

The most important difference to `SIGHUP` is that the DNS cache itself is **not** flushed. Merely the blocking cache (storing if a domain has already been analyzed and what the result was) is cleared.

This is the preferred signal to be used after manipulating the `gravity.db` database manually as it reloads only what is needed in this case.

## Real-time signal 1 (SIG35)

*Reserved* - Currently ignored

## Real-time signal 2 (SIG36)

*Reserved* - Used for internal signaling that a fork or thread crashed and needs to inform the main process to shut down, storing the last (valid) queries still into the long-term database.

## Real-time signal 3 (SIG37)

Reimport alias-clients from the database and recompute affected client statistics.

## Real-time signal 4 (SIG38)

Re-resolve all clients and forward destination hostnames. This forces refreshing hostnames as in that the usual "resolve only recently active clients" condition is ignored. The re-resolution adheres to the specified `REFRESH_HOSTNAMES` config option meaning that this option may not try to resolve all hostnames.

## Real-time signal 5 (SIG39)

Re-parse ARP/neighbour-cache now to update the Network table now
