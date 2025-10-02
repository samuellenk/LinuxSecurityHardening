---
title: "virtuelle Linux-Umgebung ![LSH](images/linux_security_hardening_logo.png){width=20 height=20}"
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
* [Bedrohungslandschaft und Sicherheitsnachrichten](#bedrohungslandschaft-und-sicherheitsnachrichten)
* [Einführung in Virtualbox](#einführung-in-virtualbox)
* [Debian- und Redhat-Familie](#debian--und-redhat-familie)
* [Rocky Linux in Virtualbox aufsetzen](#rocky-linux-in-virtualbox-aufsetzen)
* [Debian in Virtualbox aufsetzen](#debian-in-virtualbox-aufsetzen)
* [Debian: Installation](#debian-installation)
* [Rocky Linux: Installation](#rocky-linux-installation)
* [Netzwerk-Einstellungen anpassen für SSH](#netzwerk-einstellungen-anpassen-für-ssh)
* [Snapshot von VMs erstellen](#snapshot-von-vms-erstellen)
<!-- TOC -->

# Bedrohungslandschaft und Sicherheitsnachrichten

Überblick:

- jeder Admin/DevOps muss sich mit Sicherheit auskennen
- Bedrohungslandschaft wird dargestellt
- wie man bei Sicherheitsnachrichten auf dem Laufenden bleibt

# Beispiel: Malware Botnet

Ausgangspunkt:
 
- Hacker → C&C → verteilt auf andere Maschinen

genutzt für:

- Spam, Malware, Crypto-Mining, DoS-Attacken, etc.

Ergebnis:

- Daten-Diebstahl, wie Anmeldedaten, Kreditkarten, sensible Informationen, ...
- Reputations-Schäden
- Ausfälle im Business

# Sicherheitspannen

- Adobe postet PGP-Schlüssel in [Sicherheitsblog](https://www.golem.de/news/e-mail-adobe-veroeffentlicht-versehentlich-privaten-pgp-key-im-blog-1709-130215.html)

# Sicherheitsnachrichten

[cve.org](https://www.cve.org/)
temporär: [cve.mitre.org](https://cve.mitre.org/)

allgemeine Webseiten:

- [Packet Storm Security](https://packetstormsecurity.com/)
- [The Hacker News](https://thehackernews.com/)
- [LXer](http://lxer.com/)

ausgewählte Distributions-spezifische Seiten

- [Debian](https://www.debian.org/security/)
- [Redhat](https://access.redhat.com/security/security-updates/cve)
- [Suse](https://www.suse.com/security/cve/)

# Einführung in Virtualbox

- Kurs verwendet [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
- erlaubt die Erstellung und den Import von VMs
- wir verwenden Vertreter aus zwei Distributions-Familien
- Debian aus der **Debian-Familie**
- Rocky Linux aus der **Redhat-Familie**
- optional *(Open)Suse*

# Debian- und Redhat-Familie

wir verwenden im Kurs:

- **Debian** mit aktueller Version (12)
  - alle Angaben lassen sich (meist) auf andere *Debian*-Derivate übertragen
- **Rocky Linux** mit aktueller Version (9)
  - als Nachfolger von CentOS  
  - alle Angaben lassen sich (meist) auf andere *Redhat*-Derivate übertragen
- teilweise gibt es hervorgehobene Unterschiede
- beides wird in Minimal-Version (Server) verwendet

# Rocky Linux in Virtualbox aufsetzen

- CentOS existiert nicht mehr in der *alten* Form
- [Rocky Linux](https://rockylinux.org/) wird als Nachfolger aus der Redhat-Familie verwendet

# Debian in Virtualbox aufsetzen

- behandeln wir im Detail auf den nachfolgenden Seiten
- erledigen wir gemeinsam am echten System

# Download ISO

Beispiel:

[Debian](https://www.debian.org/distrib/)

- passende Variante auswählen
- und zusätzlich passende Checksummen-Datei/Signatur herunterladen

# Verifizierung des Downloads unter Linux

```
sha256sum -c linux.iso.sha256
```
- Ausführung kann eine Weile dauern (= großes Archiv)
- dann sollte so eine Meldung erscheinen: `linux.iso: OK`

# Verifizierung des Downloads unter Windows

PowerShell starten
```
Get-FileHash linux.iso -Algorithm SHA256 | Format-List
```
- dann Hash vergleichen von Webseite

# Debian: Installation

- klicke "Neu", dann Name und Betriebs-System: Debian
- Speichergröße: 4096 MB
- Platte: Festplatte erzeugen
- Dateityp der Festplatte: VDI
- Art der Speicherung: dynamisch alloziert
- Dateiname und Größe: 20 GB
- klicke "Ändern", dann System → Hauptplatine: "Diskettenlaufwerk" abwählen
- System → Prozessor: 4
- Anzeige → Bildschirm → Grafikspeicher: 128 MB
- Massenspeicher → Eintrag "leer" anklicken → rechts auf das Disk-Symbol und "Abbild" auswählen, dann debian*.iso auswählen
- Änderungen speichern mit "OK", dann klicke "Starten"
- Installation mit Standard-Optionen durchführen

# Debian: offizielle Installations-Anleitung

[offizielle Installations-Anleitung](https://www.debian.org/releases/stable/i386/)

# Debian: Nacharbeiten 

```bash
# Aktualisierung
sudo apt update -y
sudo apt dist-upgrade -y
sudo apt autoremove -y
# SSH
systemctl status sshd
ip -brief a
# weitere Installationen und Konfigurationen
sudo apt install nano -y
sudo apt install rsyslog -y
sudo timedatectl set-timezone Europe/Berlin
```

# Rocky Linux: Installation

- wie [Debian: Installation](#debian-installation)
- nur entsprechendes ISO für Rocky Linux wählen

# Rocky Linux: offizielle Installations-Anleitung

[offizielle Installations-Anleitung](https://docs.rockylinux.org/guides/installation/)

# Rocky Linux: Nacharbeiten

```bash
# Aktualisierung
sudo dnf install epel-release -y
sudo dnf upgrade -y
# SSH
systemctl status sshd
ip -brief a
# weitere Installationen und Konfigurationen
sudo dnf install nano -y
sudo hostnamectl set-hostname rockylinux
```

# Import der fertigen VM in Virtualbox

- Import der fertigen VM ist alternativ zur Installation möglich
- der angelegte User ist `tux` mit dem Passwort `tux`
- nach Abschluss des Imports und einer Funktionsprüfung der VM empfiehlt sich die [Erstellung eines Sicherungs-Punktes](#snapshot-von-vms-erstellen)
  - auf den man bei Bedarf zurückgehen kann

# Netzwerk-Einstellungen anpassen für SSH

funktioniert für Debian und Rocky Linux:

- in Virtualbox den Netzwerk-Adapter "Bridged Adapter" und "Alle erlauben" wählen
- kann für SSH-Verbindung vom Host aus genutzt werden

# Snapshot von VMs erstellen

- nach Abschluss der Installation inklusive Nacharbeiten ist es ratsam einen Snapshot von den VMs zu machen
- auf den Stand kann man schnell zurück ohne erneute Installation

Vorgehen:

1. öffne Virtualbox
2. wähle die betreffende VM aus
3. klicke das Dreipunkt-Menü rechts neben dem Namen der Maschine
4. wähle Snapshots
5. klicke dann auf erstellen
6. und **warte** bis Erstellung beendet ist

# Zusammenfassung

Was hast du in diesem Abschnitt gelernt?

<!-- TOC -->
* [Bedrohungslandschaft und Sicherheitsnachrichten](#bedrohungslandschaft-und-sicherheitsnachrichten)
* [Einführung in Virtualbox](#einführung-in-virtualbox)
* [Debian- und Redhat-Familie](#debian--und-redhat-familie)
* [Rocky Linux in Virtualbox aufsetzen](#rocky-linux-in-virtualbox-aufsetzen)
* [Debian in Virtualbox aufsetzen](#debian-in-virtualbox-aufsetzen)
* [Debian: Installation](#debian-installation)
* [Rocky Linux: Installation](#rocky-linux-installation)
* [Netzwerk-Einstellungen anpassen für SSH](#netzwerk-einstellungen-anpassen-für-ssh)
* [Snapshot von VMs erstellen](#snapshot-von-vms-erstellen)
<!-- TOC -->
