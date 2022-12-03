## Pi-hole FTL's internal pcap packet dump

Pi-hole has its own embedded package dumping. It can be enabled by adding the following to a file like `/etc/dnsmasq.d/99-record.conf`:

```
dumpfile=/etc/pihole/dump.pcap
```

(or any other location you prefer), in addition to

```
dumpmask=<mask>
```

where `mask` specifies which types of packets should be added to the dumpfile defined above. The argument should be the OR of the bitmasks for each type of packet to be dumped: it can be specified in hex by preceding the number with 0x in the normal way.
Each time a packet is written to the dumpfile, we log the packet sequence and the mask representing its type. The current types are:

- `0x0001` - DNS queries from clients
- `0x0002` - DNS replies to clients
- `0x0004` - DNS queries to upstream
- `0x0008` - DNS replies from upstream
- `0x0010` - queries send upstream for DNSSEC validation
- `0x0020` - replies to queries for DNSSEC validation
- `0x0040` - replies to client queries which fail DNSSEC validation
- `0x0080` - replies to queries for DNSSEC validation which fail validation.

If you just want to record everything and later filter this in Wireshark you can just add the two lines

```
dumpfile=/etc/pihole/dump.pcap
dumpmask=0x00ff
```
