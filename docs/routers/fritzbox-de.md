Diese Anleitung wurde für FRITZ!OS 07.21 geschrieben, sollte jedoch auch mit anderen Firmware-Versionen funktionieren. Ziel ist es, grundlegende Prinzipien für ein reibungsloses Zusammenspiel zwischen Fritz!Box und Pi-hole zu verdeutlichen.

> Hinweis:
Es gibt nicht nur **die eine Art**, eine funktionierende DNS System aufzusetzen.  Konfiguriert euer Netzwerk nach euren Bedürfnissen.
Diese Anleitung wurde für IPv4 geschrieben und muss für IPv6 Netwerke entsprechend angepasst werden.

## 1) Pi-hole als Upstream DNS Server der Fritz!Box (WAN  Seite)

Mit dieser Konfiguration, wird Pi-hole für alle Geräte im Netzwerk, incl. der Fritz!Box genutzt. DNS Anfragen nehmen folgenden Weg

```bash
Client -> Fritz!Box -> Pi-hole -> Upstream DNS Server
```

Zum Einstellen muss die IP des Pi-hole als "Bevorzugter DNS-Server" **und** "Alternativer DNS-Server" in

```bash
Internet/Zugangsdaten/DNS-Server
```

![Screenshot der Fritz!Box WAN DNS Konfiguration](../images/fritzbox-wan-dns-de.png)

eingetragen werden.

!!! warning
    Die Fritz!Box darf nicht als upstream DNS Server im Pi-hole eingestellt werden. Dies würde zu einem DNS Loop führen, da Pi-hole dann die Anfragen an die Fritz!Box senden würde, welche sie wiederum an Pi-hole senden würde.

Mit dieser Konfiguration sind im Pi-hole Dashboard keine individuellen Clients sichtbar. Für Pi-hole scheinen alle Anfragen von der Fritz!Box zu kommen. Dadurch können nicht alle Funktionen von Pi-hole genutzt werden, z.B. die Möglichkeit, Clients individuell zu filtern (Group Management). Wenn dies gewünscht ist, muss die Konfiguration #2 verwendet werden.


## 2) Pi-hole als DNS Server via DHCP an Clients verteilen (LAN Seite)

Mit dieser Konfiguration wird allen Clients die IP des Pi-hole als DNS Server angeboten, wenn sie einen DHCP Lease vom der Fritz!Box anfordern.
DNS Anfragen nehmen folgenden Weg

```bash
Client -> Pi-hole -> Upstream DNS Server
```

> Hinweis:
Die Fritz!Box selbst wird den unter Internet/Zugangsdaten/DNS-Server eingestellten DNS Server nutzen.
Die Fritz!Box kann der Upstream Server von Pi-hole sein, solange Pi-hole nicht der Upstream Server der Fritz!Box ist. Dies würde zu einem DNS Loop führen.

Um diese Konfiguration zu nutzen, muss die IP des Pi-hole als "Lokaler DNS-Server" in

```bash
Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv4-Konfiguration/Heimnetz
```

![Screenshot der Fritz!Box DHCP Einstellungen](../images/fritzbox-dhcp-de.png)

eingetragen werden.

>Hinweis:
Clients bemerken Änderungen an den DHCP Einstellungen erst, wenn der DHCP Lease erneuert wird. Der einfachste Weg dies zu erzwingen ist ein Unterbrechen und Wiederherstellen der Netzwerkverbindung.

Nun sollen einzelne Clients in Pi-hole Dashboard auftrauchen.

## 3) Kombination aus 1) und 2)

Durch die Kombination von 1) und 2) senden alle Clients und die Fritz!Box selbst DNS Anfragen direkt an Pi-hole.

```bash
Client (incl. Fritz!Box) -> Pi-hole -> Upstream DNS Server
```

!!! warning
    Die Fritz!Box darf nicht als Upstream DNS Server des Pi-hole gesetzt werden. Dies würde zu einem DNS Loop führen, da Pi-hole die Anfragen an die Fritz!Box senden würde, welche sie wiederum an Pi-hole weitergeben würde.

## Pi-hole im Gastnetzwerk nutzen

Es gibt in der Fritz!Box keine Möglichkeit unter

```bash
Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv4-Konfiguration/Gastnetz
```

den DNS Server des Gastnetzwerks einzustellen.

Die Fritz!Box wird immer ihre eigene IP als DNS Server des Gastnetzes einstellen. Um die DNS Anfragen dennoch über den Pi-hole zu senden, muss der als Upstream DNS für die Fritz!Box (siehe #1) eingetragen werden. Da es keine andere Option gibt, werden alle Anfragen aus dem Gastnetz für Pi-hole so erscheinen, als ob sie direkt von der Fritz!Box kommen. Eine individuelle Filterung je nach Client innerhalb des Gastnetzwerks ist deshalb nicht möglich.
