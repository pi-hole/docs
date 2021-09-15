# Interface binding behavior

## Interface listening settings

Pi-hole offers three choices for interface listening behavior on its dashboard:

![Available interface listening behavior settings](/images/interface-listening.png)

### Listen on all interfaces

This setting accepts DNS queries only from hosts whose address is on a local subnet, i.e. a subnet for which an interface exists on the server. It is intended to be set as a default on installation, to allow unconfigured installations to be useful but also safe from being used for DNS amplification attacks if (accidentally) running public.

The `dnsmasq` option `local-service` is used.

### Listen only on interface `eth0`

Listen only on the specified interface. The loopback (`lo`) interface is automatically added to the list of interfaces to use when this option is used. When the optional settings `bind-interfaces` or `bind-dynamic` are in effect, IP alias interface labels (e.g. `eth1:0`) are checked, rather than interface names.

In the degenerate case when an interface has one address, this amounts to the same thing but when an interface has multiple addresses it allows control over which of those addresses are accepted. The same effect is achievable in default mode by using `listen-address`.

The `dnsmasq` option `interface=eth0` is used (the interface may be different).

### Listen on all interfaces, permit all origins

We intentionally add this option to disable any possible `local-service` settings from other files. This truly allows any traffic to be replied to and a dangerous thing to do. You should always ask yourself if the first option doesn't work for you as well.

The `dnsmasq` option `except-interface=nonexisting` is used.

## Technical details

By default, FTL binds the wildcard address, even when it is listening on only some interfaces. It then discards requests that it shouldn't reply to. This has the big advantage of working even when interfaces come and go and change address (this happens way more often than one would think).

If this is not what you want, you can add the option

```plain
bind-interfaces
```

to some file like `/etc/dnsmasq.d/99-user.conf` and see [the comment above](#listen-only-on-interface-eth0). This config forces FTL to really bind only the interfaces it is listening on.
About the only time when this is useful is when running another nameserver on the same port on the same machine.

{!abbreviations.md!}
