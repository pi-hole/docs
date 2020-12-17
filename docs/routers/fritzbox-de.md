**Dies ist eine inoffizielle Anleitung die durch die Community gepflegt wird**

Diese Anleitung wurde für FRITZ!OS 07.21 geschrieben, sollte jedoch auch mit anderen Firmware-Versionen funktionieren. Ziel ist es, grundlegende Prinzipien für ein reibungsloses Zusammenspiel zwischen Fritz!Box und Pihole zu verdeutlichen.

> Hinweis:
Es gibt nicht nur **die eine Art**, eine funktionierende DNS System aufzusetzen.  Konfiguriert euer Netzwerk nach euren Bedürfnissen.
Diese Anleitung wurde für IPv4 geschrieben und muss für IPv6 Netwerke entsprechend angepasst werden.

## 1) Pihole als Upstream DNS Server der Fritz!Box (WAN  Seite)

Mit dieser Konfiguration, wird Pihole für alle Geräte im Netzwerk, incl. der Fritz!Box genutzt. DNS Anfragen nehmen folgenden Weg

```bash
Client -> Fritz!Box -> Pihole -> Upstream DNS Server
```

Zum Einstellen muss die IP des Pihole als "Bevorzugter DNS-Server" **und** "Alternativer DNS-Server" in

```bash
Internet/Zugangsdaten/DNS-Server
```
![Screenshot der Fritz!Box WAN DNS Konfiguration](../images/fritzbox-wan-dns-de.png) 

eingertagen werden.

!!! warning
    Die Fritz!Box darf nicht als upstream DNS Server im Pihole eingestellt werden. Dies würde zu einem DNS Loop führen, da Pihole dann die Anfragen an dieFritz!Box senden würde, welche sie wiederum an Pihole senden würde.

Mit dieser Konfiguration sind im Pihole Dashboard keine individuellen Clients sichtbar. Für Pihole scheinen alle Anfragen von der Fritz!Box zu kommen. Dadurch können nicht alle Funktionen von Pihole genutzt werden, z.B. die Möglichkeit, Clients individuell zu filtern (Group Management). Wenn dies gewünscht ist, muss die Konfiguration #2 verwendet werden.


## 2) Pihole als DNS Server via DHCP an Clients verteilen (LAN Seite)

Mit dieser Konfiguration wird allen Clients die IP des Pihole als DNS Server angeboten, wenn sie einen DHCP Lease vom der Fritz!Box anfordern.
DNS Anfragen nehmen folgenden Weg

```bash
Client -> Pihole -> Upstream DNS Server
```

> Hinweis:
Die Fritz!Box selbst wird den unter Internet/Zugangsdaten/DNS-Server eingestellten DNS Server nutzen.
Die Fritz!Box kann der Upstream Server von Pihole sein, solange Pihole nicht der Upstream Server der Fritz!Box ist. Dies würde zu einem DNS Loop führen.

Um diese Konfiguration zu nutzen, muss die IP des Pihole als "Lokaler DNS-Server" in

```bash
Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv4-Konfiguration/Heimnetz
```
![Screenshot der Fritz!Box DHCP Einstellungen](../images/fritzbox-dhcp-de.png) 

eingetragen werden.

>Hinweis:
Clients bemerken Änderungen an den DHCP Einstellungen erst, wenn der DHCP Lease erneuert wird. Der einfachste Weg dies zu erzwingen ist ein Unterbrechen und Wiederherstellen der Netzwerkverbindung.

Nun sollen einzelne Clients in Piholes Dashboard auftrauchen.

## 3) Kombination aus 1) und 2)

Durch die Kombination von 1) und 2) senden alle Clients und die Fritz!Box selbst DNS Anfragen direkt an Pihole.

```bash
Client (incl. Fritz!Box) -> Pihole -> Upstream DNS Server
```

!!! warning
    Die Fritz!Box darf nicht als Upstream DNS Server des Pihole gesetzt werden. Dies würde zu einem DNS Loop führen, da Pihole die Anfragen an die Fritz!Box senden würde, welche sie wiederum an Pihole weitergeben würde.

## Pihole im Gastnetzwerk nutzen

Es gibt in der Fritz!Box keine Möglichkeit unter

```bash
Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv4-Konfiguration/Gastnetz
```

den DNS Server des Gastnetzwerks einzustellen.

Die Fritz!Box wird immer ihre eigene IP als DNS Server des Gastnetzes einstellen. Um die DNS Anfragen dennoch über den Pihole zu senden, muss der als Upstream DNS für die Fritz!Box (siehe #1) eingetragen werden. Da es keine andere Option gibt, werden alle Anfragen aus dem Gastnetz für Pihole so erscheinen, als ob sie direkt von der Fritz!Box kommen. Eine individuelle Filterung je nach Client innerhalb des Gastnetzwerks ist deshalb nicht möglich.
