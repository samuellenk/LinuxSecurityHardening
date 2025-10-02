---
title: "Linux Grundlagen ![LSH](images/linux_security_hardening_logo.png){width=20 height=20}"
subtitle: "Linux Sicherheit und Härtung"
author: "![SL](images/SL_foto_300.png){width=20 height=20} [&copy; Samuel Lenk](https://linux-trainings.de/)"
theme: "Luebeck"
colortheme: "whale"
aspectratio: 169
colorlinks: true
urlcolor: gray
linkcolor: gray
---

# Einleitung

Was lernst du in diesem Teil des Kurses?

<!-- TOC -->
* [Linux-Befehlszeile](#linux-befehlszeile)
* [Dokumentation und Hilfe finden](#dokumentation-und-hilfe-finden)
* [Beispiel für Redhat mit Webserver](#beispiel-für-redhat-mit-webserver)
* [Einleitung zu TCP/IP-Netzwerken](#einleitung-zu-tcpip-netzwerken)
* [Linux-Sicherheitstipps](#linux-sicherheitstipps)
<!-- TOC -->

# Linux-Befehlszeile

Warum die [Bash](https://de.wikipedia.org/wiki/Bash_(Shell))-Shell?

- Bash (die Bourne-again Shell) ist eine freie Unix-Shell unter GPL
- eine Mensch-Maschine-Schnittstelle
- elementarer Bestandteil des unixähnlichen Betriebssystems GNU
- bei allen auf GNU aufbauenden Distributionen die Standard-Shell

hier gibt das komplette [Bash Referenz-Handbuch](https://www.gnu.org/software/bash/manual/bash.html)

# Befehle, Argumente und Optionen

Schritte im Terminal:

- ```Befehl``` + [Enter] = startet Ausführung
- [Ctrl] + [C] = bricht Ausführung ab

# Befehle, Argumente und Optionen

Beispiel:
```bash
ls -l /bin
|   |   |
|   |  Argumente
|  Parameter
Befehl
```

# Befehle, Argumente und Optionen

Parameter haben nicht immer Bindestriche
Beispiele:
```bash
tar cvzf /home/tux/folder/
ps aux
```

# Dateisystem, Verzeichnisse und Pfade

- das Dateisystem ist eine Baumstruktur, die bei Root (```/```) beginnt
- darunter liegen viele verschiedene (Standard-) Verzeichnisse
- auch Platten, Geräte usw. erscheinen in dieser Struktur

Anzeige gut möglich mit ```tree```:

- ggf. erst installieren mit ```sudo apt install tree```

# Dateisystem, Verzeichnisse und Pfade

ein Pfad ist die Abfolge von Verzeichnis-Namen:

- zum Bsp. ```/home/tux/Downloads/meine-datei.txt```
- kann mit Dateinamen enden
- oder nur Ordner beinhalten

# Arten von Pfaden

- absolut: ```/etc/sudoers```
- relativ: ```ordner/datei```

besondere relative Pfade:

- ```.``` = aktuelles Verzeichnis
- ```..``` = übergeordnetes Verzeichnis
- ```.``` und ```..``` werden nicht in Shell ausgewertet
- sie sind Hardlinks, die es in jedem Verzeichnis gibt

# Benutzer-Verzeichnis (home)

- normale Benutzer haben meist ein eigenes Verzeichnis
- liegt unter ```/home/[BENUTZER_NAME]```
- Beispiel: `/home/tux`

# Durch Verzeichnisse bewegen

aktuelles Verzeichnis anzeigen:
```bash
pwd
```

in anderes Verzeichnis wechseln:
```bash
cd /usr/bin/
cd ..
```

# Dateien erzeugen und bearbeiten

leere Datei erstellen:
```bash
touch funny.txt
touch file1 file2 file3
```

Datei editieren:
```bash
nano funny.txt
```

mit ```echo``` Text in eine Datei schreiben:
```bash
echo "Hallo Linux" > hallo.txt
```

# Dateien verwalten

Dateien anzeigen:
```bash
ls
```

Dateien als lange Liste anzeigen:
```bash
ls -l
```

Dateien - auch versteckte - anzeigen:
```bash
ls -al
```

# Dateien verwalten

Dateien mit Größe in leicht lesbarer Form anzeigen:
```bash
ls -lh
```

Datei kopieren:
```bash
cp hello.txt Documents/
```

Datei verschieben:
```bash
mv hello.txt Documents/
```

# Dateien verwalten

**Achtung: ```rm``` löscht ohne Bestätigung** und ohne Papierkorb

- egal ob man Dateien, Ordner oder andere Elemente löscht
- sofern man die Berechtigungen zum Löschen besitzt

Datei löschen:
```bash
rm hello.txt
rm file1 file2
```

# Ordner erstellen

Ordner erstellen:
```bash
mkdir ordner1
mkdir -p ordner1/unterordner1
```

# Ordner verwalten

Ordner löschen:
```bash
rm -r ordner1
rm -rf ordner1
rmdir ordner1
```

# Dateien betrachten

Datei für diesen Schritt erzeugen:
```bash
echo -e 'Giraffe\nAffe\nElefant\nOchse\nKuh\nMarder\nBär \
    \nPferd\nKaninchen\nSchwein\nHase\nFuchs\nEnte\nVogel \
    \nMurmeltier\nKamel\nAntilope\nBiber\nKatze\nHund \
    \nWolf\nUhu\nEule\nAdler\nFrettchen' \
    > animals.txt
```

# Dateien betrachten

Inhalt anzeigen:
```bash
cat animals.txt
```

Inhalt mit Zeilennummern anzeigen:
```bash
cat -n animals.txt
```

# Dateien betrachten

Inhalt seitenweise anzeigen:
```bash
less animals.txt
```

Anfang der Datei anzeigen:
```bash
head animals.txt
```

# Dateien betrachten

Ende der Datei anzeigen:
```bash
tail animals.txt
```

letzte x Zeilen der Datei anzeigen:
```bash
tail -n 2 animals.txt
tail -2 animals.txt
```

# Berechtigungen

Anzeige der Berechtigungen für Datei:
```bash
ls -l
```

# Aufbau von Berechtigungen

Beispiel-Ausgabe bei Aufruf von ```ls -l```:
```bash
   Alle (all) besondere Attribute
       |      |
  ----------- -
d rwx rwx rwx . ...
- --- --- ---
|  |   |   |
|  |   |  andere (other)
|  |  Gruppe (group)
| Benutzer (user)
Datei-Typ
```

# Dateien anpassen

Berechtigungen hinzufügen:
```bash
chmod +x skript.sh
chmod u+x skript.sh
chmod 744 skript.sh
```

Berechtigungen entfernen:
```bash
chmod -x skript.sh
chmod 044 skript.sh
```

# Berechtigungen als Oktalzahlen

Wie kommen diese Oktalzahlen für Berechtigungen zustande?

grundlegende Werte:

| Wert	 | Recht  |
|-------|--------|
| 0     | 	Keine |
| 1     | 	x     |
| 2     | 	w     |
| 4     | 	r     |

# Berechtigungen als Oktalzahlen

Kombinationen dieser Werte:

| Wert	 | Recht  |
|-------|--------|
| 3     | 	w+x   |
| 5     | 	r+x   |
| 6     | 	r+w   |
| 7     | 	r+w+x |

- ergibt also insgesamt 8 mögliche Kombinationen

# Prozesse

Terminal-Prozesse anzeigen:
```bash
ps
```

alle Prozesse anzeigen:
```bash
ps aux
```

Prozess beenden:
```bash
kill [SIGNAL] [PID]
kill -9 12714
```

# Dokumentation und Hilfe finden

Hilfe-Seite aufrufen:
```bash
man cat
tldr cat
```
- ```man``` ist (meist) installiert
- Installation von ```tldr``` mit ```sudo apt install tldr```
- danach zunächst einmal aktualisieren: ```tldr -u```

# Tastenkürzel in Man-Pages

- ```/[Suchbegriff]``` = vorwärts suchen
- ```?[Suchbegriff]``` = rückwärts suchen
- ```H``` = Hilfe anzeigen
- ```Q``` = Quit/Beenden

# Shell-Skripte

Zweck = mehrere Schritte/Befehle/komplexe Logik ausführen

Vorteil = alles Mögliche lässt sich hier hinterlegen und automatisieren

dieses Vorgehen nötig:

1. Shebang-Zeile einfügen: ```#!/bin/bin/env bash```
2. Befehle in Datei einfügen
3. ausführbar machen: ```chmod +x skript.sh```
4. Skript aufrufen: ```./skript.sh```

# Shell-Skripte

**Achtung**: Ausführung mit ```skript.sh``` geht nicht

- sonst könnten Angreifer zum Beispiel ein Skript namens ```ls``` in aktuelles Verzeichnis legen
- würde dann ausgeführt statt des eigentlichen ```ls```-Befehls

# Super-User werden

viele Objekte im Datei-System sind geschützt vor "normalen" Usern

- also auch vor eigenen Tipp-Fehlern

Hauptgründe:

- System nicht aus Versehen kaputt machen
- System nicht absichtlich kaputt machen

# Super-User werden

Beispiel:
```bash
touch /usr/local/avocado
```

Fehler:
```bash
Permission denied
```

# Super-User werden

stattdessen ```sudo``` nutzen:
```bash
sudo touch /usr/local/avocado
```

prüfen, ob es funktioniert hat:
```bash
ls -l /usr/local/avocado
```

Datei wieder löschen:
```bash
sudo rm /usr/local/avocado
```

# Dienste 

- mit ```systemctl``` werden Dienste verwaltet
- Dienste werden auch Unit/Service/Daemon genannt
- als Basis-Dienst erstellt ```systemd``` mit PID 1 alle anderen Dienste
- wird heute von vielen Distributionen als Init-System verwendet (Fedora, Debian, Ubuntu, Suse, ...)

Dienste anzeigen:
```bash
systemctl list-unit-files --type=service
```

- ```enable``` = startet Dienst automatisch mit dem System
- ```disable``` = startet Dienst nicht automatisch mit dem System

# Beispiel für Redhat mit Webserver

```bash
sudo dnf install httpd
systemctl status httpd
# Dienst starten und aktivieren:
sudo systemctl enable --now httpd
sudo firewall-cmd --zone=public --add-service=http
# jetzt sollte sich die Default-Webpage aufrufen lassen
# Firewall-Regel über Reboot hinaus behalten:
sudo firewall-cmd --runtime-to-permanent
```

# Beispiel für Debian mit Webserver

```bash
sudo apt install apache2
...
# Dienst stoppen und neu starten
sudo systemctl restart apache2
# nur Konfiguration neu laden
sudo systemctl reload apache2 
```
- ```reload``` bevorzugt nutzen, damit zum Beispiel beim Web-Server nicht die User-Sessions getrennt werden

# Beispiel für Debian mit Syncthing

- läuft unter Linux, Windows, MacOS
- ist [hier](https://syncthing.net/) zu finden

anderes Beispiel mit Verwendung eines bestimmten Users:
```bash
sudo apt install syncthing
systemctl status syncthing@tux
sudo systemctl start syncthing@tux
cd /usr/lib/systemd/system
nano syncthing@.service
After=network.target → startet erst, wenn Netzwerk gestartet wurde
User=%i → läuft mit spezifiziertem User
ExecStart → was systemd ausführen wird bei Start des Dienstes
WantedBy=multi-user.target → läuft im Hintergrund 
```

# Beispiel für Debian mit Syncthing

GUI lokal aufrufen:
```bash
ssh tux@syncthing_host -L 18384:localhost:8384
```

# Einleitung zu TCP/IP-Netzwerken

TCP/IP
: Transmission Control Protocol/Internet Protocol

OSI-Modell
: Open Systems Interconnection

- beide Modelle sind ähnlich
- OSI wird öfter beim Sprechen verwendet
- TCP/IP wird im echten Leben verwendet 

# TCP/IP und OSI-Modell

| TCP/IP Layer   | OSI Layer       | Beschreibung               |
|----------------|-----------------|----------------------------|
| 7. Application | 7. Application  |                            |
|                | 6. Presentation | meist mit Layer 7 verwoben |
|                | 5. Session      | meist mit Layer 7 verwoben |
| 4. Transport   | 4. Transport    |                            |
| 3. Network     | 3. Network      |                            |
| 2. Data Link   | 2. Data Link    |                            |
| 1. Physical    | 1. Physical     |                            |

- Merksatz 1: All People Seem To Need Data Processing
- Merksatz 2: Please Do Not Throw Sausage Pizza Away

# Hierarchie der Netzwerk-Geräte

PC/Server → Switch → Router → Firewall → Modem → Internet

- Hub = "dummer" Switch sendet Nachrichten an alle, die verbunden sind
- Switch = verbindet viele Computer/Server
- Router = verbindet Switches (Netzwerke)
- Glasfaserbox = WAP + Switch + Router + Firewall in einem

# (einige) Arten von Netzwerken

- vom PC zur Glasfaserbox → LAN = lokales Netzwerk
- Internet → WAN = Wide Area Network

# Hierarchie der Geräte im Netzwerk

- Layer-2-Adresse = MAC-Adresse
- Layer-3-Adresse = IP-Adresse
- Broadcast = Adresse des Routers, der ARP verwendet
- Port = ein Dienst, der auf einem bestimmten Gerät ausgeführt wird, wie 22 für SSH

# Beispiel

Thomas → Computer → Switch → Router → Switch → Server [linux-trainings.de](https://linux-trainings.de/)

| Layer        | Inhalt                    | Synonym | Protok. | Daten            | Geräte |
|--------------|---------------------------|---------|---------|------------------|--------|
| Application  | Daten                     |         | http/s  | Browser          |        |
| Presentation | formatiert, verschlüsselt |         | ssl     |                  |        |
| Session      | User identifizieren       |         |         |                  |        |
| Transport    | Daten + L4 Header         | Segment | tcp/udp | Quell-/Ziel-Port |        |
| Network      | Daten + L3 Header         | Paket   |         | Quell-/Ziel-IP   | Router |
| Data Link    | L2 Header/Trailer + Daten | Frame   | arp     | MAC Adressen     | Switch |
| Physical     |                           |         |         |                  | Kabel  |

# Anmerkungen zum Beispiel

- verschieben auf eine niedrigere Ebene = Kapselung genannt = Einstecken in einen Umschlag
- Wechsel auf eine höhere Ebene = Entkapselung genannt
- Segment = gekapselte Daten
- Paket = hat alle darüber liegenden Schichten

# DNS und ARP/RARP

DNS
: übersetzt IP-Adressen in Servernamen und umgekehrt

ARP / RARP 
: übersetzt MAC-addresses in IP-Adressen und umgekehrt

# Hilfreiche Tools in diesem Bereich unter Linux

- ```tcpdump``` = zeigt aktuellen Netzwerk-Verkehr
- [Wireshark](https://de.wikipedia.org/wiki/Wireshark) = erweiterte Funktionen zur Netzwerk-Analyse

# Ebenen der Netzwerk-Architektur

Cisco-Modell mit 3 Ebenen:

1. Core Layer
2. Distribution Layer
3. Access layer

Cisco-Modell mit 2 Ebenen:

1. Collapsed Core Layer
2. Access layer

# Verkehrsrichtungen in Netzwerken

Nord-Süd = zum und vom Internet

- traditionell oft verwendet
- aber unpraktisch, wenn man an den Server "nebenan" schnell was schicken will

Ost-West = zwischen verschiedenen Servern auf verschiedenen Racks im selben Netzwerk

- hat ein Spine-Leaf-Design, bei dem jeder Server nur einen Hop vom anderen entfernt ist
- weil dieser Datenverkehr in einem typischen Rechenzentrum 70–80 % ausmacht
- Spine-Switches/Backbone verwendet

# Linux-Sicherheitstipps

Schütze dich - Teil 1

1. finde deine öffentliche IP-Adresse: `curl ifconfig.me`
2. gehe zu [pentest-tools.com](https://pentest-tools.com/network-vulnerability-scanning/tcp-port-scanner-online-nmap) und scanne dort mit deiner IP auf offene TCP-Ports 
3. besorg dir eine (Cloud-)Maschine, die sich nicht in deinem Netzwerk befindet und auf der du ```nmap``` ausführen kannst
4. installiere ```nmap``` auf diesem System
5. führe von diesem Computer ```nmap -sT [PUBLIC_IP]``` aus, um offene Ports zu finden
6. führe von diesem Computer ```nmap --script vuln [PUBLIC_IP]``` aus, um bekannte Schwachstellen zu finden

# Linux-Sicherheitstipps

Schütze dich - Teil 2

7. schließe alle offenen Ports in deinem Router
8. deaktiviere den Fernzugriff für deinen Router
9. aktiviere die Firewall in deinem Router
10. entferne offene Ports aus den Firewall-Einstellungen und reagiere nicht auf Ping von LAN/WAN
11. aktualisiere Betriebssystem und Firmware deines Routers
12. WLAN: Verwende WPA2, benenne das Netzwerk um und geben ein sicheres Passwort ein
13. scanne dein Netzwerk von innen mit ```nmap -sT -O 192.168.178.23/24```

# Allgemeine Linux-Sicherheitstipps - Teil 1

1. deine **Denkweise** = Sei vorbereitet, denn alles ist hackbar
2. **patche** deine Server = automatische Upgrades, Kernelcare usw.
3. wähle **starke Passwörter** und **2FA**
4. mach keine unnötigen **Dienste** öffentlich = Datenbank usw.
5. limitiere **SSH**
 - kein Root-Zugriff
 - Schlüsselverwendung vs. Passwort
 - nur bestimmte IP-Adressen zulassen

# Allgemeine Linux-Sicherheitstipps - Teil 2

6. **mehrere** Sicherheits**ebenen** haben = z. G. SSH, Firewall, fail2ban, ...
7. zuverlässige, aktuelle und vollständig getestete **Backups** implementieren = an 3 verschiedenen Orten, min. 1 außerhalb des Standorts
8. nutze **Monitoring**tools = wie [Nagios](https://de.wikipedia.org/wiki/Nagios), [Zabbix](https://de.wikipedia.org/wiki/Zabbix), ...
9. Sicherheits**audit** durch Dritte = sehr teuer, aber normalerweise lohnenswert
10. Business-**Continuity**-Plan haben und umsetzen = z. B. Auto-Healing-Server
11. Sicherheit ist ein **kontinuierlicher Prozess**

# Wichtige Standards zum Thema IT-Security

[Sicherheits-Standards](https://en.wikipedia.org/wiki/IT_security_standards):

- NIST (National Institute of Standards and Technology)
- FIPS (Federal Information Processing Standards)
- BSI IT-Grundschutz
- ...

# Fragen

1. Wie heißt die oberste Ebene in der Verzeichnis-Hierarchie von Linux?
2. Womit wird die oberste Ebene in der Verzeichnis-Hierarchie unter Linux dargestellt?
3. Was ist ein Terminal-Emulator?
4. Öffne einen Terminal-Emulator.
5. Wechsle ins Root-Verzeichnis.
6. Zeige den aktuellen Ordner-Pfad an.
7. Wechsle zurück ins Benutzer-Verzeichnis.

# Fragen

8. Zeige wieder den aktuellen Ordner-Pfad an.
9. Erstelle im Benutzer-Verzeichnis einen Ordner.
10. Wechsle in den neu erstellten Ordner.
11. Erstelle in diesem Ordner eine Datei freunde.txt.
12. Editiere freunde.txt. Füge mindestens 5 Namen von deinen Freunden ein. Jeder bekommt eine eigene Zeile. Schließe und speichere die Datei.
13. Zeige den Inhalt der freunde.txt auf der Konsole an.
14. Zeige die aktuellen Berechtigungen von freunde.txt an.

# Fragen

15. Zeige die Hilfe zum Befehl "ps" an.
16. Erstelle mein_skript.sh.
17. Passe mein_skript.sh so an, dass es "Hallo [DEIN_NAME]" ausgibt.
18. Zeige die aktuellen Berechtigungen des Skripts an.
19. Mache es jetzt ausführbar.
20. Zeige die neuen Berechtigungen des Skripts an.
21. Führe das Skript aus.

# Fragen

22. Versuche als "normaler" User die Datei /opt/grapefruit.txt zu erstellen.
23. Warum kannst du sie so nicht erstellen?
24. Erstelle die Datei jetzt als Super-User.
25. Zeige, dass nun die Datei vorhanden ist.
26. Lösche die Datei wieder.
27. Prüfe, ob die Datei gelöscht ist.
28. Mit welchen Befehlen kannst du dir auf einem neuen System gut einen allgemeinen Überblick verschaffen (System, Speicher, Benutzer, Gruppen)?

# Zusammenfassung

Was hast du in diesem Abschnitt gelernt?

<!-- TOC -->
* [Linux-Befehlszeile](#linux-befehlszeile)
* [Dokumentation und Hilfe finden](#dokumentation-und-hilfe-finden)
* [Beispiel für Redhat mit Webserver](#beispiel-für-redhat-mit-webserver)
* [Einleitung zu TCP/IP-Netzwerken](#einleitung-zu-tcpip-netzwerken)
* [Linux-Sicherheitstipps](#linux-sicherheitstipps)
<!-- TOC -->
