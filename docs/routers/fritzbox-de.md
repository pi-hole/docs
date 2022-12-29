Diese Anleitung soll die grundlegenden Prinzipien für ein reibungsloses Zusammenspiel zwischen Fritz!Box und Pi-hole verdeutlichen. Sie wurde für FRITZ!OS 07.21 geschrieben, sollte jedoch auch mit anderen Firmware-Versionen funktionieren.

!!! note "Hinweis"
    Es gibt nicht nur **die eine Art**, ein funktionierendes DNS-System aufzusetzen.  Konfiguriert euer Netzwerk nach euren Bedürfnissen.
    Diese Anleitung wurde für IPv4 geschrieben und muss für IPv6 Netzwerke entsprechend angepasst werden.

### Erweiterte Ansicht aktivieren

Einige dieser Einstellungen sind nur sichtbar, wenn vorher die Ansicht auf "Erweitert" gesetzt wurde. Diese wird durch Umschalten (Klick) auf "Standard" am unteren linken Bildrand aktiviert.

![Screenshot der Fritz!Box DHCP Einstellungen](../images/routers/fritzbox-advanced-de.png)

## Pi-hole als DNS Server via DHCP an Clients verteilen (LAN Seite)

Mit dieser Konfiguration wird allen Clients die IP des Pi-hole als DNS Server angeboten, wenn sie einen DHCP Lease von der Fritz!Box anfordern.
DNS Anfragen nehmen folgenden Weg

``` plain
Client -> Pi-hole -> Upstream DNS Server
```

!!! note "Hinweis"
    Die Fritz!Box selbst wird den unter Internet/Zugangsdaten/DNS-Server eingestellten DNS Server nutzen (siehe unten).
    Die Fritz!Box kann der Upstream Server von Pi-hole sein, solange Pi-hole nicht der Upstream Server der Fritz!Box ist. Dies würde zu einem DNS Loop führen.

Um diese Konfiguration zu nutzen, muss die IP des Pi-hole als "Lokaler DNS-Server" in

``` plain
Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv4-Konfiguration/Heimnetz
```

eingetragen werden.

![Screenshot der Fritz!Box DHCP Einstellungen](../images/routers/fritzbox-dhcp-de.png)

!!! warning "Warnung"
    Clients bemerken Änderungen an den DHCP Einstellungen erst, wenn der DHCP Lease erneuert wird. Der einfachste Weg dies zu erzwingen ist ein Unterbrechen und Wiederherstellen der Netzwerkverbindung.

Nun sollten einzelne Clients im Pi-hole Dashboard auftauchen.

## Pi-hole als Upstream DNS Server der Fritz!Box (WAN  Seite)

Mit dieser Konfiguration wird Pi-hole  auch von der Fritz!Box selbst als Upstream DNS Server genutzt. DNS Anfragen nehmen folgenden Weg

``` plain
(Clients) -> Fritz!Box -> Pi-hole -> Upstream DNS Server
```

Zum Einstellen muss die IP des Pi-hole als "Bevorzugter DNSv4-Server" **und** "Alternativer DNSv4-Server" in

``` plain
Internet/Zugangsdaten/DNS-Server
```

eingetragen werden.

![Screenshot der Fritz!Box WAN DNS Konfiguration](../images/routers/fritzbox-wan-dns-de.png)

!!! warning "Warnung"
    Die Fritz!Box darf mit dieser Konfiguration nicht als Upstream DNS Server im Pi-hole eingestellt werden. Dies würde zu einem DNS Loop führen, da Pi-hole dann die Anfragen an die Fritz!Box senden würde, welche sie wiederum an Pi-hole senden würde.

Wird ausschließlich diese Konfiguration genutzt, sind im Pi-hole Dashboard keine individuellen Clients sichtbar. Für Pi-hole scheinen alle Anfragen von der Fritz!Box zu kommen. Dadurch können nicht alle Funktionen von Pi-hole genutzt werden, z.B. die Möglichkeit, Clients individuell zu filtern (Group Management). Wenn dies gewünscht ist, muss Pi-hole (zusätzlich) als DNS Server via DHCP an die Clients verteilt werden (siehe oben).

### Pi-hole im Gastnetzwerk nutzen

Es gibt in der Fritz!Box keine Möglichkeit unter

``` plain
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

## Optional: Erhöhung der Priorität von DNS Anfragen

Bei ausgelasteter Internetverbindung werden DNS-Anfragen u.U. stark verzögert bearbeitet. Dies kann in der Fritz!Box durch Hinterlegen von DNS als priorisierter Echtzeitanwendung vermieden werden. Falls nicht bereits geschehen, fügen Sie hierfür zunächst "`DNS`" als neuen Answendungstyp unter

``` plain
Internet/Filter/Listen -> Netzwerkanwendungen -> Netzwerkanwendung hinzufügen
```

mit den Eigenschaften

``` plain
Netzwerkanwendung: DNS
Protokoll: UDP
Quellport: beliebig
Zielport: 53
```

sowie

``` plain
Netzwerkanwendung: TCP
Protokoll: UDP
Quellport: beliebig
Zielport: 53
```

hinzu.

Dieser Eintrag kann dann unter

``` plain
Internet/Filter/Priorisierung -> Echtzeitanwendungen -> Neue Regel
```

hinzugefügt werden. Da sämtliche Einstellungen über das Pi-hole gehen, wählen Sie dieses als Gerät aus, für das die Regel gelten soll. Sollten Sie sich unsicher sein, kann hier auch "`Alle Geräte`" ausgewählt werden. Unter "`Netzwerkanwendung`" wählen Sie den soeben angelegten Eintrag "`DNS`" aus.

## Optional: DNS Anfragen nur vom Pi-hole erlauben

Nach der Konfiguration des Pi-holes als DNS Server des Netzwerks ist die Einrichtung abgeschlossen. Es bleibt jedoch weiterhin das Risiko einer Umgehung des Pi-holes bestehen - Netzwerkgeräte können sich direkt mit anderen, frei verfügbaren, DNS Servers im Internet verbinden. Dies kann durch eine geeignete Fiterregel jedoch einfach verhindert werden.

Insofern nicht bereits vorhanden, legen Sie unter

``` plain
Internet/Filter/Zugangsprofile -> Zugangsprofile verwalten und optimal nutzen
```

zwei Zugangsprofile an (z.B. "`Standard`" und "`Unbeschränkt`"). Im Profil "`Standard`" fügen Sie unter

``` plain
Erweiterte Einstellungen -> Gesperrte Netzwerkanwendungen
```

die oben angelegte Netzwerkanwendung "`DNS`" hinzu.
Im Profil "`Unbeschränkt`" darf "`DNS`" *nicht* als gesperrt hinterlegt werden.

Nun werden die Zugangsprofile unter

``` plain
Internet/Filter/Kindersicherung -> Zugangsprofile ändern (am Ende der Seite)
```

so konfiguriert, dass *sämtliche* Geräte *außer* dem Pi-hole (inkl. "`Alle anderen Geräte`") dem Zugangsprofil "`Standard`" (DNS wird blockiert) zugewiesen werden. Das Pi-hole selbst wird dem Zugangsprofil ("`Unbeschränkt`") zugeordnet um weiterhin DNS Anfragen absetzen zu können. Die Regel wird unmittelbar nach dem Speichern aktiv.

Die neue Filterregel kann z.B. durch den Aufruf von

``` bash
dig google.com @8.8.8.8 +short
```

auf dem Pi-Hole und auf einem beliebigen anderen Gerät im Netzwerk getestet werden. Während die Abfrage auf dem Pi-hole wie erwartet eine IP-Adresse zurückgeben sollte, sollte auf allen anderen Geräten eine Fehlermeldung wie

``` plain
;; communications error to 8.8.8.8#53: host unreachable
```

angezeigt werden. Dies belegt, dass DNS-Bypassing nun von der Fritz!Box blockiert wird.
