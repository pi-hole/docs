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
- The privacy level is re-read from `pihole.toml` (`misc.privacylevel`).
- The blocking status is re-read from `setupVars.conf` (`BLOCKING_ENABLED`).
- The debug settings are re-read from `pihole.toml` (`debug.*`).
- The gravity database connection (`/etc/pihole/gravity.db`) is re-opened.
- The number of blocked domains is updated.
- All regular expression (RegEx) filters in `gravity.db` are re-read and pre-compiled for fast execution later on.
- The blocking cache (storing if a domain has already been analyzed and what the result was) is cleared.
- If `DEBUG_CAPS` is enabled, the current set of available capabilities is logged.

# Real-time (RT) signals

While `SIGHUP` updates/flushes almost everything, such a massive operation is often not necessary. Hence, we added several small real-time signals available for fine-grained control of what FTL does. When you see `SIGHUP` as a "big gun", the real-time signals are rather the "scalpel" to serve rather specific needs.

<!-- markdownlint-disable code-block-style -->
!!! warning "Real-time signals vary"
    Real-time signals are not guaranteed to have the same number on all operating systems as the value of the constant `SIGRTMIN` may vary.
    You can check the value on your system with

    ```bash
    pihole-FTL sigrtmin
    ```
<!-- markdownlint-enable code-block-style -->
For the signals described below, we recommend using the exact signal number described in the parentheses, e.g., real-time signal 0 (assuming `RTMIN=35`) can be sent like:

```bash
sudo pkill -SIG35 pihole-FTL
```

## Real-time signal 0 (35)

This signal does:

- The gravity database connection (`/etc/pihole/gravity.db`) is re-opened.
- The number of blocked domains is updated.
- All regular expression (RegEx) filters in `gravity.db` are re-read and pre-compiled for fast execution later on.
- The blocking cache (storing if a domain has already been analyzed and what the result was) is cleared.
- The privacy level is re-read from `pihole.toml` (`misc.privacylevel`).

The most important difference to `SIGHUP` is that the DNS cache itself is **not** flushed. Merely the blocking cache (storing if a domain has already been analyzed and what the result was) is cleared.

This is the preferred signal to be used after manipulating the `gravity.db` database manually as it reloads only what is needed in this case.

## Real-time signal 1 (36)

*Reserved* - Currently ignored

## Real-time signal 2 (37)

*Reserved* - Used for internal signaling that a fork or thread crashed and needs to inform the main process to shut down, storing the last (valid) queries still into the long-term database.

## Real-time signal 3 (38)

Reimport alias-clients from the database and recompute affected client statistics.

## Real-time signal 4 (39)

Re-resolve all clients and forward destination hostnames. This forces refreshing hostnames as in that the usual "resolve only recently active clients" condition is ignored. The re-resolution adheres to the specified `REFRESH_HOSTNAMES` config option meaning that this option may not try to resolve all hostnames.

## Real-time signal 5 (40)

Re-parse ARP/neighbour-cache now to update the Network table now

## Real-time signal 6 (41)

*reserved* - Signal used internally to terminate the embedded `dnsmasq`. Please do not use this signal to prevent misbehaviour.

## Real-time signal 7 (42)

Scan binary search lookup tables for hash collisions and report if any are found. This is a debugging signal and not meaningful production. Scanning the lookup tables is a time-consuming operation and may stall DNS resolution for a while on low-end devices.
