Diese Anleitung soll die grundlegenden Prinzipien für ein reibungsloses Zusammenspiel zwischen Fritz!Box und Pi-hole verdeutlichen. Sie wurde für FRITZ!OS 07.21 geschrieben, sollte jedoch auch mit anderen Firmware-Versionen funktionieren.

!!! note "Hinweis"
    Es gibt nicht nur **die eine Art**, ein funktionierendes DNS-System aufzusetzen.  Konfiguriert euer Netzwerk nach euren Bedürfnissen.

### Erweiterte Ansicht aktivieren

Einige dieser Einstellungen sind nur sichtbar, wenn vorher die Ansicht auf "Erweitert" gesetzt wurde. Diese wird durch Umschalten (Klick) auf "Standard" am unteren linken Bildrand aktiviert.

![Screenshot der Fritz!Box DHCP Einstellungen](../images/routers/fritzbox-advanced-de.png)

## Pi-hole als DNS Server via DHCP an Clients verteilen (LAN Seite)

Mit dieser Konfiguration wird allen Clients die IP des Pi-hole als DNS Server angeboten, wenn sie einen DHCP Lease von der Fritz!Box anfordern.
DNS Anfragen nehmen folgenden Weg

```bash
Client -> Pi-hole -> Upstream DNS Server
```

!!! note "Hinweis"
    Die Fritz!Box selbst wird den unter Internet/Zugangsdaten/DNS-Server eingestellten DNS Server nutzen (siehe unten).
    Die Fritz!Box kann der Upstream Server von Pi-hole sein, solange Pi-hole nicht der Upstream Server der Fritz!Box ist. Dies würde zu einem DNS Loop führen.

Um diese Konfiguration zu nutzen, muss die IP des Pi-hole als "Lokaler DNS-Server" in

```bash
Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv4-Konfiguration/Heimnetz
```

eingetragen werden.

![Screenshot der Fritz!Box DHCP Einstellungen](../images/routers/fritzbox-dhcp-de.png)

!!! warning "Warnung"
    Clients bemerken Änderungen an den DHCP Einstellungen erst, wenn der DHCP Lease erneuert wird. Der einfachste Weg dies zu erzwingen ist ein Unterbrechen und Wiederherstellen der Netzwerkverbindung.

Nun sollten einzelne Clients im Pi-hole Dashboard auftauchen.

## Pi-hole als Upstream DNS Server der Fritz!Box (WAN  Seite)

Mit dieser Konfiguration wird Pi-hole  auch von der Fritz!Box selbst als Upstream DNS Server genutzt. DNS Anfragen nehmen folgenden Weg

```bash
(Clients) -> Fritz!Box -> Pi-hole -> Upstream DNS Server
```

Zum Einstellen muss die IP des Pi-hole als "Bevorzugter DNSv4-Server" **und** "Alternativer DNSv4-Server" in

```bash
Internet/Zugangsdaten/DNS-Server
```

eingetragen werden.

![Screenshot der Fritz!Box WAN DNS Konfiguration](../images/routers/fritzbox-wan-dns-de.png)

!!! warning "Warnung"
    Die Fritz!Box darf mit dieser Konfiguration nicht als Upstream DNS Server im Pi-hole eingestellt werden. Dies würde zu einem DNS Loop führen, da Pi-hole dann die Anfragen an die Fritz!Box senden würde, welche sie wiederum an Pi-hole senden würde.

Wird ausschließlich diese Konfiguration genutzt, sind im Pi-hole Dashboard keine individuellen Clients sichtbar. Für Pi-hole scheinen alle Anfragen von der Fritz!Box zu kommen. Dadurch können nicht alle Funktionen von Pi-hole genutzt werden, z.B. die Möglichkeit, Clients individuell zu filtern (Group Management). Wenn dies gewünscht ist, muss Pi-hole (zusätzlich) als DNS Server via DHCP an die Clients verteilt werden (siehe oben).

### Pi-hole im Gastnetzwerk nutzen

Es gibt in der Fritz!Box keine Möglichkeit unter

```bash
Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv4-Konfiguration/Gastnetz
```

den DNS Server des Gastnetzwerks einzustellen.

Die Fritz!Box wird immer ihre eigene IP als DNS Server des Gastnetzes einstellen. Um die DNS Anfragen dennoch über den Pi-hole zu senden, muss dieser als Upstream DNS Server für die Fritz!Box eingetragen werden. Da es keine andere Option gibt, werden alle Anfragen aus dem Gastnetz für Pi-hole so erscheinen, als ob sie direkt von der Fritz!Box kommen. Eine individuelle Filterung je nach Client innerhalb des Gastnetzwerks ist deshalb nicht möglich.

## Hostnamen in Pi-hole statt IP-Addressen - Conditional forwarding

Wenn die Fritz!Box im Netzwerk als DHCP Server fungiert, werden die Hostnamen der Clients nur dort registriert. Pi-hole versucht standardmäßig, die IP-Adressen der Clients wieder in Hostnamen aufzulösen. Daher müssen die Anfragen zur Fritz!Box gelangen.
Dafür gibt es zwei Wege:

* Die Fritz!Box ist der Upstream DNS Server des Pi-holes. Damit landen alle Anfragen sowieso bei der Fritz!Box, welche die Hostnamen an Pi-hole zurücksenden kann.

!!! warning "Warnung"
    Die Fritz!Box darf nur der Upstream DNS Server des Pi-hole sein, wenn dieser nicht gleichzeitig der Upstream DNS Server der Fritz!Box ist. Dies würde zu einem DNS Loop führen.

* Es werden nur die Anfragen an die Fritz!Box gesendet, welche versuchen im lokalen Netzwerk IP-Adressen wieder Hostnamen zuzuordnen. Alle anderen Anfragen werden an den Upstream DNS Server des Pi-Hole gesendet. Dafür ist die Option *Conditional forwarding* zuständig.
Folgende Einstellungen müssen dafür vorgenommen werden:
    * **Local network in CIDR notation:** IP-Bereich des Netzwerks in CIDR Notation, Standard für die Fritz!Box ist **192.168.178.0/24**
    * **IP address of your DHCP server (router):** IP-Adresse der Fritz!Box selbst, Standard ist **192.168.178.1**
    * **Local domain name (optional):** Name der lokalen Domän, für die Fritz!Box **fritz.box**

![Screenshot der Conditional Forwarding Einstellungen](../images/routers/conditional-forwarding.png)

## Pi-hole als DNS Server via IPv6

Mit dieser Konfiguration bekommen alle Clients die IPv6 von Pi-hole als DNS-Server über DHCPv6 und Router Advertisement (RA/RDNSS, SLAAC) angeboten, wenn sie mit Ihrer Fritz!Box verbunden sind.

### Stabile IPv6 Adresse für den Pi-hole

Der folgende Abschnitt hilft dabei, eine geeignete IPv6-Adresse des Pi-hole auszuwählen.
Um alle IPv6 Adressen anzuzeigen, die derzeit von Ihrer Hauptnetzwerkschnittstelle verwendet werden, öffnen Sie ein Terminal, ersetzen Sie `eth0` durch den Namen Ihrer Hauptschnittstelle (kann auch weggelassen werden) und führen Sie den Befehl aus

```bash
ip -6 address show eth0
```

The output should look like this but with different addresses

```bash
$ ip -6 address show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet6 fd6f:95dc:3a80:e9b1:503e:b05a:21dc:cf0c/64 scope global temporary dynamic
       valid_lft 7159sec preferred_lft 3559sec
    inet6 fd6f:95dc:3a80:e9b1:4bc3:7bff:fe67:c175/64 scope global dynamic mngtmpaddr noprefixroute
       valid_lft 7159sec preferred_lft 3559sec
    inet6 2001:db8::1c5e:22fe:490c:1c31/64 scope global temporary dynamic
       valid_lft 7159sec preferred_lft 3559sec
    inet6 2001:db8::4bc3:7bff:fe67:c175/64 scope global dynamic mngtmpaddr noprefixroute
       valid_lft 7159sec preferred_lft 3559sec
    inet6 fe80::4bc3:7bff:fe67:c175/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

Bei der Auswahl von der IPv6 Adresse ist folgendes zu beachten:

* Vermeidung von global unicast addresses (GUA) (Bereich `2000::/3`)  
  Ihr Internetprovider kontrolliert das GUA IPv6 Präfix, so dass es sich entweder regelmäßig oder bei einem Neustart des Routers ändern kann.
  In diesem Beispiel sollte die dritte und vierte Adresse, die mit `2001:` beginnen, nicht verwendet werden:
* Vermeidung von Privacy Extension Adressen (markiert mit `temporary`)  
  Die Schnittstellenkennung einer IPv6-Adresse ist so konzipiert, dass sie sich regelmäßig ändert, auf manchen Systemen sogar jede Stunde.
  In diesem Beispiel sollte die erste und die dritte Adresse vermieden werden.
* Bevorzugung von unique local addresses (ULA) (Bereich `fd00::/8`) gegenüber der link-lokalen Adresse (Bereich `fe80::/10`)  
  Das ULA-Präfix ist kontrollierbar und statisch. Letzteres ist nur in einem Netzwerk gültig und kann nicht geroutet werden.
  Dies kann für einfache Heimnetzwerke funkionieren, solange keine Pakete geroutet werden (wie bei Docker, einigen WiFi-Zugangspunkten, L3-Switches, ...).

In diesem Beispiel sind diese beiden Adressen verwendbar: `fd6f:95dc:3a80:e9b1:4bc3:7bff:fe67:c175` und `fe80::4bc3:7bff:fe67:c175` (mit Vorsicht).

Sollte Ihre FritzBox noch kein IPv6 ULA-Präfix vergeben, hilft der folgende Schritt bei der Konfiguration eines ULA-Präfixes.

### (Optional) ULA Adressen aktivieren

Unique local addresses (ULA) sind lokale IPv6-Adressen, die nicht über das Internet geroutet werden. Sie sind vergleichbar mit den privaten IPv4-Netzbereichen.

Zum aktivieren, wähle "Unique Local Addresses (ULA) immer zuweisen" aus in

```bash
Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv6-Konfiguration/Unique Local Addresses
```

> Hinweis:
Es wird empfohlen, das ULA-Präfix zu ändern, um Kollisionen mit anderen Netzen zu vermeiden.
Die ersten 40 Bits sollten gemäß RFC4193 oder durch einen einfachen Online-Generator, wie [unique-local-ipv6.com](https://www.unique-local-ipv6.com/), erzeugt werden.
Die restlichen 16 Bits sind die Subnetz-ID und können frei gewählt werden.  
Nach dem Auswählen von "ULA-Präfix manuell festlegen" kann man sein eigenes Präfix einstellen.

![Screenshot der Fritz!Box IPv6 Adressen Einstellungen](../images/fritzbox-ipv6-1-de.png)

Um die neue Adressen zu erhalten, muss der Pi-hole Server kurz vom Netzwerk getrennt werden oder neu gestartet werden.
Der [vorherige Schritt](#stabile-ipv6-adresse-für-den-pi-hole) sollte wiederholt werden, um die neue ULA Adresse anzuzeigen.

### Pi-hole als DNS Server verteilen

Nun kann die IPv6 Adresse des Pi-hole als "Lokaler DNSv6-Server" in

```bash
Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv6-Konfiguration/DNSv6-Server im Heimnetz
```

eingetragen werden.

> Hinweis:
Es wird empfohlen "DNSv6-Server auch über Router Advertisement bekanntgeben (RFC 5006)" auszuwählen.

![Screenshot der Fritz!Box IPv6 Adressen Einstellungen](../images/fritzbox-ipv6-2-de.png)
