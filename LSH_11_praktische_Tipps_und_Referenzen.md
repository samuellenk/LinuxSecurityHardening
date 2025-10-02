---
title: "praktische Tipps und Referenzen ![LSH](images/linux_security_hardening_logo.png){width=20 height=20}"
subtitle: "Linux Sicherheit und Härtung"
author: "![SL](images/SL_foto_300.png){width=20 height=20} &copy; [Samuel Lenk](https://linux-trainings.de/)"
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
* [System-Dienste auditieren](#system-dienste-auditieren)
* [Netzwerk-Dienste mit netstat auditieren](#netzwerk-dienste-mit-netstat-auditieren)
* [Netzwerk-Dienste mit nmap auditieren](#netzwerk-dienste-mit-nmap-auditieren)
* [GRUB mit Passwort sichern](#grub-mit-passwort-sichern)
* [UEFI/BIOS sicher konfigurieren](#uefibios-sicher-konfigurieren)
* [Firmware aktualisieren](#firmware-aktualisieren)
* [Sicherheitscheckliste zum System-Setup nutzen](#sicherheitscheckliste-zum-system-setup-nutzen)
* [ausführliche PE-Scans](#ausführliche-pe-scans)
* [Zehn Maßnahmen zum technischen IT-Basis-Schutz](#zehn-maßnahmen-zum-technischen-it-basis-schutz)
* [Weiterführende Ressourcen](#weiterführende-ressourcen)
<!-- TOC -->

# System-Dienste auditieren

```bash
sudo systemctl -t service --state=active
```
- ```t``` = type = Typ von Unit
- ```state``` = Status der Unit

# Netzwerk-Dienste mit netstat auditieren

```bash
netstat -lp[n] -A inet
```
- falls nicht vorhanden, dann ```net-tools``` installieren
- ```lp``` = listen port = lauschende Ports
- ```A``` = Protokoll-Familie
- ```n``` = IP-Adresse (statt Netzwerk-Name)
- bei **unbekannten Ports** eine Referenz konsultieren:
  - [Wikipedia Port Liste](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers)
  - lokal auf ```/etc/services``` einen ```grep``` mit passendem Suchbegriff/Port

# Netzwerk-Dienste mit nmap auditieren

- man muss sich nicht auf dem zu prüfenden Host einloggen, wie bei ```netstat```
- kann auch IP-Ranges verwenden

```bash
sudo nmap -sS 192.168.0.17
sudo nmap -sU 192.168.0.0/24
sudo nmap -sA 192.168.0.17
sudo nmap -A 192.168.0.1-128
```
- ```sS``` = TCP Ports
- ```sU``` = UDP Ports
- ```sA``` = ACK = wenn man feststellen will, ob Firewall den Weg zwischen lokalem Host und Ziel-System blockiert
- ```A``` = alle Ports, ausser UDP
- mehr Information in der [man-page](https://linux.die.net/man/1/nmap)

# GRUB mit Passwort sichern

physischer Zugang zu einem Linux-System:

- Passwort kann über Recovery-Mode umgangen bzw. zurückgesetzt werden
- Was, wenn Unbefugte das tun?
- Absicherung von GRUB also wichtig für Clients, die sonst nicht extra physisch geschützt sind

# GRUB mit Passwort sichern - Redhat

1. bei Anzeige von GRUB ```e```drücken
2. ```rhgb quiet``` löschen
3. dafür ```rd.break enforcing=0``` am Ende hinzufügen
4. [Ctrl] + [X]
5. man landet im ```switch_root```-Prompt
6. ```mount -o remount,rw /sysroot```
7. ```chroot /sysroot```
8. ```passwd```
9. ggf. zusätzlich ```passwd [USER_NAME]```
10. ```mount -o remount,ro /```
11. 2 x ```exit```
12. nach Reboot ```sudo restorecon /etc/shadow && sudo setenforce 1```

# GRUB mit Passwort sichern - Debian

1. bei Anzeige von GRUB ```e```drücken
2. am Ende der Zeile gehen, die mit ```linux``` beginnt
3. aus ```ro``` machen ```rw init=/bin/bash```
4. [Ctrl] + [X]
5. man landet im ```root``` Shell
6. ```passwd [USER_NAME]```
7. Reboot mit exec ```/sbin/init```
8. jetzt folgt normaler Reboot

# UEFI/BIOS sicher konfigurieren

- Konfiguration hängt ab von CPU
- dazu Informationen auf der Hersteller-Webseite suchen
- und dann **Passwort** für BIOS/UEFI setzen

# Firmware aktualisieren

- war in der Vergangenheit oft separat nötig (neben Paketverwaltung)
- ist aber (meist) nicht mehr der Fall
- es kann `fwupdmgr` verwendet werden (Paket `fwupd`)

Beispiel:
```bash
# Informationen auffrischen
fwupdmgr refresh --force
# Firmware aktualisieren
fwupdmgr update
```

- Hilfe: `fwupdmgr --help`
- Dokumentation unter [lvfs.readthedocs.io](https://lvfs.readthedocs.io/en/latest/)

# Sicherheitscheckliste zum System-Setup nutzen

- unterscheiden sich je nach zu erfüllenden Anforderungen

Beispiele:

- [Operating System Hardening Checklists](https://wikis.utexas.edu/display/ISO/Operating+System+Hardening+Checklists)
- [Server unter Linux - BSI](https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Grundschutz/IT-GS-Kompendium_Einzel_PDFs_2023/07_SYS_IT_Systeme/SYS_1_3_Server_unter_Linux_und_Unix_Edition_2023.html)
- [Clients unter Linux - BSI](https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Grundschutz/IT-GS-Kompendium_Einzel_PDFs_2023/07_SYS_IT_Systeme/SYS_2_3_Clients_unter_Linux_und_Unix_Edition_2023.html)

# ausführliche PE-Scans

- PE (Privilege Escalation) stellt einen wichtigen Weg dar, um in fremden Systemen potenziell Schaden anzurichten
- daher sind proaktive Scans und Monitoring in diesem Zusammenhang sinnvoll
- ein Skript mit einer umfangreichen Suite an Checks findet man [hier](https://github.com/peass-ng/PEASS-ng)

Nutzung:
```bash
curl -L \
https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh \
| sh
```
- mehr in der [Hilfe](https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS)

# Zehn Maßnahmen zum technischen IT-Basis-Schutz

1. eigene Denkweise
2. Backup & Recovery
3. Schutz vor Schadsoftware
4. Netzwerkschutz
5. Firewall
6. Patch-Management
7. Verschlüsselung für Speicherung und Kommunikation
8. Passwort-Management
9. Biometrie und 2FA/Token
10. Spam-Abwehr

# Weiterführende Ressourcen

detaillierte Security-Guides großer Distributionen:

- [Debian Security](https://www.debian.org/doc/manuals/securing-debian-manual/)
- [Redhat Security](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/security_hardening/index)
- [Suse Security](https://documentation.suse.com/sles/15-SP6/html/SLES-all/book-security.html)

# Zusammenfassung

Was hast du in diesem Abschnitt gelernt?

<!-- TOC -->
* [System-Dienste auditieren](#system-dienste-auditieren)
* [Netzwerk-Dienste mit netstat auditieren](#netzwerk-dienste-mit-netstat-auditieren)
* [Netzwerk-Dienste mit nmap auditieren](#netzwerk-dienste-mit-nmap-auditieren)
* [GRUB mit Passwort sichern](#grub-mit-passwort-sichern)
* [UEFI/BIOS sicher konfigurieren](#uefibios-sicher-konfigurieren)
* [Firmware aktualisieren](#firmware-aktualisieren)
* [Sicherheitscheckliste zum System-Setup nutzen](#sicherheitscheckliste-zum-system-setup-nutzen)
* [ausführliche PE-Scans](#ausführliche-pe-scans)
* [Zehn Maßnahmen zum technischen IT-Basis-Schutz](#zehn-maßnahmen-zum-technischen-it-basis-schutz)
* [Weiterführende Ressourcen](#weiterführende-ressourcen)
<!-- TOC -->
