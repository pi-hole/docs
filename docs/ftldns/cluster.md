### Running several Pi-holes as a cluster

A single Pi-hole is a single point of failure: while it is down, or while you are updating it, the
whole household has no DNS. The usual answer is to run a second one and hand out both addresses over
DHCP, which works but leaves you maintaining two Pi-holes by hand - every blocklist, every local DNS
record and every setting has to be entered twice, and the two drift apart.

Clustering removes that. Two or more Pi-holes keep their configuration and their lists in step,
watch each other, and take DHCP over when one of them stops answering. There is no primary and no
secondary: every node is equal, a change made on any of them reaches the others within a fraction of
a second, and any node can be the one that is down.

---

### What a cluster keeps in step

- **The configuration.** Upstream DNS servers, local DNS and CNAME records, cache settings, rate
  limits, the web interface theme - almost everything in `pihole.toml`. A change made in the web
  interface of one node is in force on the others about a fifth of a second later.
- **The lists.** Adlists, allow and deny lists, groups, clients and their assignments. Allow and deny
  entries, groups and clients take effect as they arrive. Adlists need the domains behind them, so
  every node whose adlists moved rebuilds its blocking database with `pihole -g` by itself - the
  node the edit was made on included. A Pi-hole on its own leaves that run to you; a clustered one
  cannot, or the node you edited would be the only one not blocking the list you just gave it.

    Between taking the adlists and finishing that rebuild, a node blocks **nothing** from them - not
    less, none. The domains it holds are filed under the adlists it had a moment ago, and those rows
    are gone, so nothing matches until the rebuild has run. It still answers every query, and allow
    and deny entries still apply; it is the adlists that are absent. This is not the window
    `pihole -g` has on its own, where the old blocking database stays in place until the new one is
    ready - it arrives without anybody asking for it, so it is worth making large list changes when
    a gap of a minute or two on the other nodes does not matter.

    One more thing about that run, which is `pihole -g` behaving as it always has: it builds the new
    database in a copy and moves the copy into place when it is done, so a list entry added on a
    node *while its rebuild is running* is lost with the swap - accepted by the web interface, gone
    a minute later. On a single Pi-hole you know when you started gravity; in a cluster the node
    starts it by itself, so check the log or the HA cluster page ("not rebuilt") before editing
    lists on a node that has just taken a peer's adlists.
- **The membership.** The list of nodes is itself a synchronized setting, so adding a node is one
  edit on one machine rather than one edit per machine.
- **The credentials**, if you let it. The web interface password, the application passwords and the
  two-factor secret travel with the rest, which is what makes the nodes interchangeable down to the
  login. This is `cluster.sync.credentials`, and it is on by default. Credentials only ever travel
  while *every* member is an `https://` one, whatever the setting says: a signature keeps a peer
  from changing them, not from reading them.

And what it deliberately does *not*:

- **Anything that names one particular machine.** The interface it listens on, the addresses it
  replies with, its certificate, its file paths, its NTP settings.
- **The DHCP settings.** The lease range, the router, the static leases: they describe what that
  machine does on its network, and a node that never had a range would otherwise hand its empty one
  to the node that is serving. With `cluster.dhcp.failover` set the same range on every node - each
  of them has to be able to serve it on its own. The *leases themselves* do travel, from whichever
  node is handing out addresses to the ones that might have to take over.
- **Whether blocking is paused.** "Disable blocking" and `pihole disable 5m` are that machine's
  pause: the timer that puts it back lives in the memory of the node you asked, so a pause that
  travelled would take blocking off the others with nothing to switch it on again. Pause each node
  you want paused - and note that the timer does not survive a restart, on a cluster no more than on
  a single Pi-hole. In a cluster somebody else's settings change can be what restarts it, so a pause
  that outlives its five minutes is worth checking for.
- **Anything that is an instruction rather than a setting.** `misc.dnsmasq_lines`,
  `misc.etc_dnsmasq_d` and `webserver.advancedOpts` are handed to dnsmasq and to the webserver as
  written, so a node able to set them on its peers would be a node able to run commands on them.
- **The cluster's own settings**, so that no node can repoint another one at a different cluster or
  switch off its guards. Two of them are the exception, and both have to be the same everywhere to
  mean anything: the member list, and the virtual IP address.
- **Anything pinned through the environment.** A setting given as an `FTLCONF_` variable, the way
  the Docker image takes its configuration, cannot be changed by anybody - not by you through the
  web interface and not by a peer. A node that pins one is a node the cluster can never bring into
  line on it, so the HA cluster page names the item rather than leaving you with a difference that
  never resolves.

!!! info
    Each of these is decided by a flag on the individual setting, so `pihole.toml` on each node
    remains the place where you can see and change everything - including the items that never
    travel.

---

### Building a cluster from the web interface

Open **HA cluster** in the web interface of a Pi-hole that is not in one yet. It scans the network
as the page loads and shows you both halves of the answer.

**Start with the Pi-hole you want to keep.** Whichever machine creates the cluster is the one whose
settings and lists the others will take, and a node that joins gives up its own for the cluster's.
If one of these machines is the one you have been curating and the others are fresh installs, create
the cluster *there* and join the fresh ones to it. Doing it the other way round replaces the curated
one, and nothing asks first.

That first Pi-hole has nothing to join, so it presses **Create a cluster**. That makes a cluster of
one: FTL generates the shared secret in `/etc/pihole/cluster_secret` and starts answering the scan so
the next node can find it. Only do this once - if the scan already found something, a cluster exists
and creating a second one leaves you with two that ignore each other. The page says so, and names how
many nodes answered.

**Every node after that** joins instead. The nodes that are already clustered answer on UDP port
4712 with nothing but the port they speak HTTPS on, so the scan fills the address in for you. Pick
one, enter *that* node's web interface password, and press **Join**.

The password is the one thing that cannot be automatic: it is what proves you are allowed to have
the cluster's secret, its configuration and its passwords, rather than merely being on the same
network as it.

The joining node takes the cluster's shared secret, its member list, its configuration and its
lists, and **replaces its own with them** - this is the step that decides which machine's setup
survives, and it is not a merge. It restarts once and comes back as a member; the other nodes
learn about it because the member list is itself synchronized.

"Its lists" is worth spelling out, because it is more than the Adlists page: the groups, the
clients, the domains and the adlists all go, along with everything on the settings pages and the
web password. Nothing of the joining node's is kept and there is no undo, so export a Teleporter
archive from it first if any of it matters - or create the cluster on that node instead and join
the others to it.

!!! warning
    Both ends of this have to be encrypted: the password of the other node crosses this connection,
    and so does the shared secret coming back. FTL refuses to join, and refuses to hand its secret
    over, on a plain `http://` connection - and it refuses application passwords and the CLI
    password, which exist so a script can read data rather than take a cluster over.

A Pi-hole with no web interface password is asked for none: its API is open because somebody decided
so, and this is part of that API. A password-less cluster works. Demanding a session such a node
cannot create would protect nothing anyway - whoever can reach it can already make it hand the other
nodes whatever they like.

This is also the one connection a cluster cannot authenticate for itself, since the joining node
holds no secret yet, so by default the certificate the other node presents is taken as it comes.
The **Fingerprint** field is how you close that: every node shows its own fingerprint on its HA
cluster page, and a joining node given one refuses to join through anything that does not present
exactly that certificate. It is entirely optional - leave it empty and joining works as it always
does - and it has to be carried by hand from one machine to the other, because a fingerprint that
arrived over the connection it is meant to vouch for would vouch for nothing.

The beacon is only bound while `cluster.enabled` is set, so a Pi-hole that is not in a cluster
neither answers nor is found. It says nothing about the node beyond its HTTPS port.

### Leaving a cluster

**Leave the cluster** at the bottom of the same page takes a node back out. The other nodes are
handed the member list without it first, so they stop polling an address that is about to stop
answering, and only then does clustering stop here - the other way round the removal would never
leave the machine. FTL restarts at the end of it.

What the node holds is left alone: the configuration and the lists it took from the cluster stay,
and so does the shared secret, so it can be taken back in later without copying anything again. If
none of the other nodes is reachable at that moment the node still leaves, and the log says how many
were told - the ones that were not keep the entry until somebody removes it there.

DHCP is the one thing that does move. A node that was handing out addresses gives that up on its way
out, so that the node the cluster elects next is the only one serving - two DHCP servers on one
range is the outcome this whole area is built to avoid. The exception is a node that has nobody to
hand it to: if no remaining member takes part in failover, it keeps serving rather than leaving the
network with no DHCP server at all, and says so in the log.

The node that leaves gives the virtual IP address back, because the address belongs to the cluster
rather than to it. What happens next depends on who is left:

- **Other nodes remain.** They elect a holder among themselves and place the address again within a
  round or two. Clients that were told to resolve there keep working, and there is nothing to do.
- **It was the last node.** Nothing places the address again, so anything pointing at it stops
  resolving. Give those clients another address before you leave.

Do not set the virtual IP address permanently on the machine that is leaving while a cluster
remains: the cluster will place the same address on one of its own nodes, and two machines answering
for one address is the outcome the whole arrangement exists to avoid.

The same is available as `POST /api/cluster/leave`.

---

### Setting up a cluster by hand

Everything the web interface does above can be done from the command line, which is what a
configuration-management tool or a scripted install wants.

#### 1. Create the shared secret

The nodes authenticate to each other with one shared secret rather than with individual passwords.
FTL creates it the first time clustering is switched on, so switch it on on the node you are
starting from and then read it:

``` bash
pihole-FTL --config cluster.enabled true
# ...and give FTL a moment to restart and write the file before reading it
sleep 10
sudo cat /etc/pihole/cluster_secret
```

FTL restarts to take that setting and writes the secret on the way up, so the file does not exist
until it has come back - reading it in the same breath finds nothing. With no member list yet it
gets no further than that, which is what step 2 is for.

Copy that file to every other node, keeping its ownership and permissions:

``` bash
sudo install -o pihole -g pihole -m 640 cluster_secret /etc/pihole/cluster_secret
```

!!! warning
    Every node of a cluster holds the same secret, and that secret is what lets a node change the
    others' settings. Treat it like a password: it belongs on the machines that are part of the
    cluster and nowhere else. It is never sent over the network - see
    [How the nodes authenticate](#how-the-nodes-authenticate) below.

#### 2. Tell each node about the others

The member list is the same on every node, this one included - FTL recognizes its own entry and
skips it:

``` bash
pihole-FTL --config cluster.enabled true
pihole-FTL --config cluster.members '[ "https://192.168.0.5", "https://192.168.0.6" ]'
pihole-FTL --config cluster.name pi-hole-living-room
```

!!! warning
    Some of these settings restart FTL, and a `pihole-FTL --config` write that
    lands while it is restarting is lost - the command says nothing about it. If
    you are running them from a script, read each value back before writing the
    next, or leave a few seconds between them.

    Both halves can go missing, and they look nothing alike from the outside. A
    node that lost the member list says so itself: `cluster: enabled but no
    members configured, not starting`. A node that lost `cluster.enabled` says
    nothing about itself at all - the other nodes report it as unreachable with
    "clustering off there, or `/etc/pihole/cluster_secret` differs", which reads
    like a network or secret problem on a machine whose configuration looks
    perfectly correct. Check `pihole-FTL --config cluster.enabled` on the node
    itself before looking anywhere else.

    Writing the setting back is not enough on its own: the cluster thread only
    starts when FTL does, so a node that came up without one of them needs
    restarting once the value is in place.

That is the whole of it. There is nothing to number and nothing to rank: which node serves DHCP and
holds the virtual IP address follows from the node identities, and every node works it out for
itself.

A cluster holds at most eight nodes. Every node polls every other one, so what a round costs the
network grows with the square of the size, and FTL keeps room for that many - a longer list is
refused rather than quietly cut short.

Addresses are the safer entry, but names work as well, with one caveat: see
[the virtual IP address](#the-virtual-ip-address) for what a named member means for DHCP clients. A name is resolved once and the address it
answered on is then used directly, so a cluster does not ask the resolver again every time it polls,
and a node whose name stops resolving keeps working. When a node cannot resolve a name at all - a
container name outside Docker's own DNS, for instance - the other nodes tell it where that member
answered them, and it uses that instead. The name still travels in SNI and is still what the
certificate is checked against, so where the connection goes changes and who is accepted at the end
of it does not. `/api/cluster/status` shows the address each member was last reached at.

At this point the nodes are talking to each other, and within a round or two they are in step.

!!! warning
    There is no merge, here or anywhere else: the newest configuration wins whole, and so does the
    newest set of lists. In a cluster built this way nobody has changed anything yet - none of the
    commands above is a setting the cluster carries - so there is no "newest" to go on, and the
    nodes settle on one of them arbitrarily in the first round they can all see each other. That
    applies to the configuration and to the lists alike.

    If one of these machines is the one you have been curating and the others are fresh installs,
    do not leave that to chance: change something on the curated node *after* switching clustering
    on there and *before* switching it on anywhere else - one setting through the web interface, and
    adding and removing an adlist for the lists. That makes it the newest on both counts, and the
    others take from it.

#### 3. Switch on what you want

The configuration and the lists are kept in step from the moment a node is part of a cluster - there
is nothing to switch on for that. The other two features are separate, because both of them change
what the machine does on the network:

``` bash
# hand DHCP over when the serving node fails
pihole-FTL --config cluster.dhcp.failover true

# ...and let the clients keep talking to one address. This one is the same
# everywhere by definition, so it travels to the other nodes on its own -
# set it once, on any of them
pihole-FTL --config cluster.vip.address 192.168.0.9
```

`cluster.dhcp.failover` is per machine, because whether a particular Pi-hole may take DHCP over is a
statement about that machine and its network. `cluster.vip.interface` is per machine too, and can
almost always be left alone: with nothing set, FTL uses the interface holding the route to the
default gateway.

---

### Checking on a cluster

``` bash
pihole-FTL --config cluster.enabled
curl -s "http://pi.hole/api/cluster/status?sid=${SID}" | jq .
```

The answer carries this node's own view and its view of every peer: who is reachable, who serves
DHCP, who holds the virtual IP address, how far apart the clocks are, and the fingerprints the nodes
compare to decide who has to catch whom up. Every node also publishes which of the others it reaches,
so the web interface can draw the links as they are rather than as this node happens to see them -
every node polls every other one, and a link only one end can use shows up as such.

Each node reports its FTL version, and the branch it was built from when that is not `master`. A
member whose FTL does not know the cluster endpoints at all is reported as too old for clustering
rather than as an HTTP error.

---

### DHCP failover

With `cluster.dhcp.failover` enabled, one node runs the DHCP server and the others keep theirs
switched off until they are needed. Which one is decided by the node identities in `cluster.state`:
the reachable node with the lowest one serves. That is arbitrary but stable, and every node reaches
the same answer on its own - there is no coordinator to ask, and nothing to configure. A node is in
the running only while it is reachable, has failover switched on itself, and could actually serve.

Never by name: two Pi-holes imaged from the same card are both `raspberrypi`, and a comparison
neither of them wins is two DHCP servers on one network.

Imaging a card copies `cluster.state` too, so both machines then carry one identity. The cluster
notices - each running Pi-hole publishes a token it made up at startup, and two members answering with
the same identity from two different tokens are two machines rather than one node listed twice. Both
stand down from DHCP and the virtual address until it is fixed, and say so in the log. Give one of
them a new identity by deleting its `/etc/pihole/cluster.state` and restarting.

Handing over to a node that is already serving happens at once - the wait exists so that one missed
answer does not move DHCP, not to keep two servers running. Taking over needs two consecutive rounds
to agree first, and handing back three, so a single missed answer moves nothing. No node takes over
while another still reports serving: two DHCP servers with separate lease databases on one network
is worse than a few seconds without one. A node that could not actually start a DHCP server - no
lease range, no gateway, a read-only configuration - says so to its peers rather than being elected
and then failing.

Which machine that turns out to be is not something you choose, and does not need to be. Unplug the
one that is serving and the next takes over by itself. Plug it back in and it starts serving again
straight away, from its own lease file - `dhcp.active` is still set in its `pihole.toml` - and the
node that stood in for it yields within a round. For that round both answer, and the leases the
stand-in handed out in between are in neither file afterwards: a client renewing one of them is
offered an address afresh rather than confirmed. A lease time comfortably longer than an outage
keeps that to the few clients that arrived during it.

How long that takes follows from `cluster.interval`, which is ten seconds by default. The node that
takes over has to see the other one gone for two rounds running before it does anything - one round
is a missed packet, two is an absence - and then it restarts FTL so that dnsmasq is actually serving
the range. Half a minute is the usual figure, and a busy or distant node can make it a little more.
The virtual IP address moves on the same two rounds but without the restart, so it is quicker.

Clients keep the addresses they have throughout, which is the point: a DHCP lease outlives this by
hours, so nothing on the network has to do anything while it happens.

A node whose own resolver fails to start is treated the same way, and stops serving rather than
waiting to be unplugged: its DNS is down, so it is the last machine that should be handing out leases
naming itself as the DNS server. It gives the virtual address back, switches its own DHCP server off
and restarts, and another node picks both up. That only applies where the cluster switched DHCP on in
the first place - with `cluster.dhcp.failover` off, `dhcp.active` is your setting and stays yours.

#### What happens if the nodes cannot see each other

A node that cannot reach any peer is, from where it stands, the only node left - so it elects itself
and starts serving. That is the right answer when the other machine really is gone, and it is also
what happens when both machines are running but something between them is not: a switch that died
between two floors, a firewall rule, an access point that isolates its clients from each other. Each
side then has its own DHCP server and its own copy of the virtual IP address.

Where the two halves are genuinely separate networks that is what you want. Where they are not - the
nodes cannot see each other but the clients can still see both - it means two DHCP servers handing
out the same range and two machines answering for the same address, which is the one thing the rest
of this design works to avoid. There is no way for a node to tell the two situations apart: a cluster
this size has nobody to ask, and requiring a majority would mean two nodes could never fail over at
all.

That is the case where *nobody* can reach a node. A single broken direction is different and much more
common - a firewall rule someone added on one side, an asymmetric route, a certificate pin that no
longer matches - and there the cluster does not split. Every node publishes what it can see of every
other, so a node that cannot poll the DHCP server itself still learns from a third node that it is
running, that it answers DNS, and which node it is. Both the DHCP election and the address are decided
on that merged view, so a node with one bad link reaches the same answer as everybody else instead of
starting a server of its own. With three nodes it takes at least three broken directions before the
cluster can no longer agree, and at that point it is a partition in all but name.

It repairs itself when the nodes can see each other again: the higher identity gives DHCP back and
releases the address within a few rounds, and the configuration and lists reconcile by timestamp as
they would after any outage. What does not repair itself is any address handed out twice while the
two halves were apart, so a DHCP lease time short enough to turn those over is worth having.

A member that *answers* but does not accept this node is a different case, and it is treated
differently on purpose. A Pi-hole that is listed but has clustering switched off, holds a different
secret, or is too old to know about clustering at all, is still a Pi-hole - it may well be serving
DHCP under its own settings. So while no member accepts this node and at least one of them answers,
DHCP failover and the virtual IP are left exactly as they are: nothing is taken over and no address
is placed. That is deliberate - a second DHCP server on one range is worse than a virtual address
that is not there - but it does mean a cluster whose other members are not set up yet decides
nothing at all. The warning in the log names it, and the line above it names the member and the
reason.

#### The leases travel with it

The node handing out addresses is the only one writing `/etc/pihole/dhcp.leases`, and its peers keep
a copy of that file. Whichever of them takes over therefore already knows which client holds which
address: a client renewing after a failover is recognized and keeps the address it has, rather than
being refused and offered a different one.

It works because of when the file is read. A Pi-hole that is not serving DHCP never opens it, and a
node taking over restarts FTL, which reads it at startup - so the copy the cluster maintains is
exactly what the new server starts from. Nothing is injected into a running DHCP server.

The copy flows from whoever is actually serving, so it changes direction on its own when DHCP moves.
It flows to a node that is *not* serving, which is why a server coming back from a reboot does not
pick up what its stand-in handed out - it is serving again before it could ask.
A node with `cluster.dhcp.failover` switched off keeps no copy at all: it will never take over, and
a file full of another machine's clients has no business being there.

Such a node also keeps whatever `dhcp.active` its administrator gave it. That is deliberate - the
cluster does not switch off a setting it was told not to manage - but it means a node that runs its
own DHCP server alongside a cluster that runs failover leaves two servers on one range, each with its
own lease database. Both are visible in the cluster status; neither will stand down. If you want one
DHCP server, either switch `cluster.dhcp.failover` on everywhere or switch `dhcp.active` off on the
nodes that should not serve.

---

### How the nodes recognize each other's certificates

Pi-hole's certificates are self-signed and name a machine rather than the address a peer reaches it
at, so neither a chain nor a hostname says anything about them. What identifies a peer instead is
the hash of its public key: each node publishes its own in the status answer, and that answer is
signed with the shared secret. Every later connection to that peer has to present the same key or it
is not opened at all.

So there is nothing to distribute and nothing to copy between the nodes. Somebody who sits on the
network can break a connection, but not read one and not pretend to be a node - a signature they
cannot produce is what tells the others which key to expect.

Two cases are worth knowing about:

- **A certificate that is replaced** - reissued, or regenerated after expiry - no longer matches, so
  the connection is refused once, the old key is forgotten, and the next signed answer says what the
  new one is. A line in the log says so. A member that keeps publishing a key it does not serve - a
  proxy in front of it, or something on the path - is polled unpinned so that a renewed key can
  still be learned, and that is all the unpinned connection carries: its lists and its leases are
  not taken until it can be identified again, and the log says so once. `cluster.tls.ca` is the
  answer for a proxy that is meant to be there.
- **Joining is the one connection none of this covers**, because a node that is not a member yet
  holds no secret. The password crosses it, so if that matters to you, copy the pin out of the other
  node's HA cluster page and hand it over with the join - the connection is then refused unless that
  node presents exactly that key.

`cluster.tls.ca` is for people who run their own CA: point it at the bundle and the chain is verified
as well. With Pi-hole's own certificates it stays empty.

---

### Passwords across the cluster

`cluster.sync.credentials` is on by default: the web interface password, the application passwords
and the two-factor secret travel with the rest of the configuration, so the nodes are
interchangeable down to the login. A node that takes over is the same Pi-hole, with the same
password and the same second factor - synchronizing the password but not the factor would be a
cluster where the factor is skipped by opening a different node instead.

Because the second factor travels too, a cluster that has it on has it on everywhere - so joining a
new node to it needs a token as well as the password. The join card has a field for one; leave it
empty unless the node you are joining asks for it.

It is worth knowing what it costs. The nodes authenticate with the shared secret, and with the
password synchronized that file becomes as good as the password on every node: whoever holds it can
set a password they know everywhere. Switched off, the secret can still change what the cluster
keeps in step, but it cannot log in anywhere:

``` bash
pihole-FTL --config cluster.sync.credentials false
```

This setting is not synchronized - each node decides for itself what it accepts, and switching it
off on one node keeps that node's password local without changing the others. Because of that, the
credentials are fingerprinted apart from the rest of the configuration: they can only ever come into
step between two nodes that both accept them, so folding them into the one figure the nodes compare
would have a node that opted out reported as differing from the cluster for good. The HA cluster
page compares them only where both ends say they accept them, and says *credentials differ* rather
than the plain *differs* when that is the only difference left.

!!! warning
    Credentials only travel while *every* entry in `cluster.members` is an `https://` one, whatever
    this is set to. The nodes sign what they send, so nobody can change a password in flight - but a
    signature does not keep anybody on the path from reading it, and a password hash read once is a
    password hash for good.

---

### The virtual IP address

`cluster.vip.address` is an address that follows whichever node the clients should be talking to. It
is added to `cluster.vip.interface` and announced with a gratuitous ARP - an unsolicited neighbour
advertisement for IPv6 - so switches and clients stop sending to the previous holder rather than
waiting for their ARP entry to expire.

Pick an address the network is not using and that the DHCP server would not hand out. The web
interface will suggest one: it takes the subnet holding the default route and offers the highest
address in it that nothing Pi-hole has seen is using and no DHCP lease could land on. That is a
suggestion rather than a guarantee - a device that has been switched off since Pi-hole started has
never been seen, and still owns its address.

One address serves one segment. Pi-hole hands out a single DHCP range, so a cluster spanning two
segments is outside what this models.

Clients learn about it through DHCP, when Pi-hole is the DHCP server and `cluster.dhcp.failover` is
on. Without a virtual IP address every node is advertised individually, which also works: a client
keeps resolving when the node it was talking to stops answering, it just takes a resolver timeout to
notice.

That second form needs the member list written as IPv4 addresses. A DHCP option carries an address,
so a member written as a name cannot go into one and is left out - and a list of names alone leaves
the clients knowing about the serving node and nothing else, which is the outage failing over exists
to prevent. FTL says so in the log. A virtual IP address has no such limitation and is the better
answer either way. For IPv6 clients a virtual IP address is the only form: individual nodes are not
advertised there at all.

!!! note
    Adding and removing an address needs `CAP_NET_ADMIN`, and the gratuitous ARP needs
    `CAP_NET_RAW`. FTL holds both.

!!! warning
    `dns.listeningMode = BIND` and a virtual IP address do not go together. In that mode dnsmasq
    binds the addresses it finds when it starts, so an address that arrives afterwards is not one it
    answers on - the address moves, and DNS on it does not. FTL says so in the log when both are
    set. Use `ALL` or `SINGLE` instead.

!!! note
    FTL removes only an address it added itself. One that was already on the interface when
    clustering started is left alone, so pointing `cluster.vip.address` at a node's existing address
    does not take that address away from it.

---

### What happens when a node comes back

A node that was down missed the changes made while it was away. When it returns, the nodes compare
fingerprints, and the node whose configuration was changed more recently hands its version to the
other. A node that was never configured at all - a fresh install joining an established cluster -
holds nothing worth handing anybody and adopts the cluster's configuration instead.

Two people changing settings on two nodes in the same moment is the one case that cannot be
reconciled. The later change wins, and the cluster ends up on that node's values.

!!! note
    Because the newer change wins, the nodes have to agree on what time it is. A node whose clock is
    more than two seconds away from its peers is not synchronized with until it agrees again, which
    is said in the log and shown in `/api/cluster/status`. Any working NTP setup is enough.

A change that requires FTL to restart - a new DNS port, a changed cache size - restarts the nodes
one after another rather than all at once, and whichever node holds the virtual IP address goes
last.

#### Nodes on different Pi-hole versions

Upgrading a cluster takes as long as it takes, so its nodes will not all be on the same version for
part of that time, and after a rollback the difference can be permanent. It keeps working: a node
ignores what it does not recognize in another's answer, and takes from a configuration only the
settings it knows.

What it does not do is call them identical. The fingerprint the nodes compare covers the *names* of
the settings as well as their values, and two versions do not define quite the same set - so nodes
on different versions show as differing on the HA cluster page for as long as that lasts, with the
versions named next to the difference. Nothing is stuck and nothing is being retried in a loop;
there is simply no answer that would make two different sets of settings identical. It resolves when
they are on the same version.

For the same reason a node keeps its own configuration timestamp across an upgrade rather than
treating the new version's settings as an edit somebody made. The practical advice is the ordinary
one: upgrade the nodes in one go where you can, and expect the page to say they differ while you are
part way through.

A Pi-hole too old to cluster answers the other nodes but does not accept them, and that is treated as
a node that may be handing out leases under its own settings - because it is, and it publishes nothing
that would say either way. So no node takes DHCP over while a member is refusing it, however many of
the others have been upgraded. That is deliberate: the alternative is a second DHCP server on the
range halfway through your upgrade. It also means DHCP failover does not start working until every
member is on a version that clusters - including a member that is simply switched off from clustering,
or one whose `cluster_secret` does not match. The log says which node it is.

#### Rolling a node back to a Pi-hole without clustering

**Leave the cluster on a node before you roll it back below the version clustering appeared in.**

A Pi-hole that does not know these settings rewrites `pihole.toml` without them, which is what any
downgrade does with settings a newer version added. The member list and the rest of the cluster
configuration are gone from that node, and there is nothing the newer FTL can do about it on its way
out.

One setting is worth knowing about before it happens. `dhcp.active` is not part of what the cluster
keeps in step - each node holds its own - but on a cluster with DHCP failover it is the cluster that
switches it on, on the node it elects to serve. It is an ordinary setting in the file, so it lives
through the rollback while the clustering that decided it does not, and the node comes back serving
DHCP by itself, next to whichever node the remaining cluster elects. Two DHCP servers on one network
hand out conflicting leases.

Leaving first avoids all of it: the node hands DHCP back to a node that can take it, tells the others
to drop it, and switches clustering off before it goes.

---

### How the nodes authenticate

Every request between nodes is signed with HMAC-SHA256 using a key derived from the shared secret,
covering the method, the path, the sender, the intended recipient, a sequence number and the body.
The answers are signed back with a second derived key naming the node that wrote them.

This means the secret itself never travels, a request cannot be replayed or aimed at a different
node than it was signed for, and a node cannot be lied to about who is running DHCP - even on a
plain `http://` cluster or one where TLS verification is off.

A node authenticated this way may read `/api/cluster/...` and hand over a configuration through
`PATCH /api/config`, and nothing else. It never receives a session, so a peer cannot reach the
Teleporter archive, read the full configuration, or use the web interface. The two endpoints that
hand a cluster over - `POST /api/cluster/enroll` and `POST /api/cluster/join` - are closed to it
altogether: they need the web interface password over an encrypted connection.

---

### Trying it out with Docker

The quickest way to see a cluster work is three containers on one host. They reach each other over
the bridge network by name, so nothing has to be free on the host. Create the shared secret once:

``` bash
openssl rand -base64 32 | tr -d '\n' > cluster_secret
```

``` yaml title="docker-compose.yml"
services:
  pihole-1:
    image: pihole/pihole:latest
    container_name: pihole-1
    hostname: pihole-1
    volumes:
      - ./cluster_secret:/etc/pihole/cluster_secret:ro
      - pihole-1-etc:/etc/pihole
    environment:
      FTLCONF_webserver_api_password: cluster
      FTLCONF_cluster_enabled: 'true'
      FTLCONF_cluster_name: pihole-1
      # the same list on every node - each one skips its own entry
      FTLCONF_cluster_members: 'http://pihole-1;http://pihole-2;http://pihole-3'
      FTLCONF_cluster_interval: '5'
    ports:
      - "8081:80"
    restart: unless-stopped

  pihole-2:
    image: pihole/pihole:latest
    container_name: pihole-2
    hostname: pihole-2
    volumes:
      - ./cluster_secret:/etc/pihole/cluster_secret:ro
      - pihole-2-etc:/etc/pihole
    environment:
      FTLCONF_webserver_api_password: cluster
      FTLCONF_cluster_enabled: 'true'
      FTLCONF_cluster_name: pihole-2
      FTLCONF_cluster_members: 'http://pihole-1;http://pihole-2;http://pihole-3'
      FTLCONF_cluster_interval: '5'
    ports:
      - "8082:80"
    restart: unless-stopped

  pihole-3:
    image: pihole/pihole:latest
    container_name: pihole-3
    hostname: pihole-3
    volumes:
      - ./cluster_secret:/etc/pihole/cluster_secret:ro
      - pihole-3-etc:/etc/pihole
    environment:
      FTLCONF_webserver_api_password: cluster
      FTLCONF_cluster_enabled: 'true'
      FTLCONF_cluster_name: pihole-3
      FTLCONF_cluster_members: 'http://pihole-1;http://pihole-2;http://pihole-3'
      FTLCONF_cluster_interval: '5'
    ports:
      - "8083:80"
    restart: unless-stopped

volumes:
  pihole-1-etc:
  pihole-2-etc:
  pihole-3-etc:
```

Change something on the third node and watch it appear on the first:

``` bash
docker exec pihole-3 pihole-FTL --config dns.blockTTL 42
sleep 1
docker exec pihole-1 pihole-FTL --config dns.blockTTL
```

Take a node down, change something, and watch it catch up when it returns:

``` bash
docker stop pihole-3
docker exec pihole-1 pihole-FTL --config dns.cache.size 7777
docker start pihole-3
sleep 20
docker exec pihole-3 pihole-FTL --config dns.cache.size
```

!!! note
    DHCP failover and the virtual IP address are not part of this setup: a bridge network carries
    neither DHCP broadcasts nor a floating address. For those, run one container per host on the
    real network with `network_mode: host`, `NET_ADMIN` and `NET_RAW`, and set
    `FTLCONF_cluster_dhcp_failover`, `FTLCONF_cluster_vip_address` and
    `FTLCONF_cluster_vip_interface`.

---

### Settings

| Setting | Default | Meaning |
| --- | --- | --- |
| `cluster.enabled` | `false` | Is this Pi-hole part of a cluster? On its own this changes nothing on the machine - the features below are separate switches |
| `cluster.name` | hostname | How this node calls itself in logs and to its peers |
| `cluster.members` | `[]` | The web interface URLs of all nodes, this one included, at most eight |
| `cluster.interval` | `10` | Seconds between rounds. Also how long a peer may take to answer: a fifth of it, and never under two seconds |
| `cluster.tls.ca` | `""` | A CA bundle of your own. Empty means the peers are identified by their public keys |
| `cluster.sync.credentials` | `true` | Let the passwords and the two-factor secret travel with the rest. Only ever while every member is an `https://` one |
| `cluster.dhcp.failover` | `false` | Hand DHCP over when the serving node fails |
| `cluster.vip.address` | `""` | An address that follows whichever node the clients should use, synchronized |
| `cluster.vip.interface` | `""` | The interface it is placed on, local; empty means the one with the default route |
