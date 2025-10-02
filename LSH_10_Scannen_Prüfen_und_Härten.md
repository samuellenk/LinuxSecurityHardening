---
title: "Scannen, Prüfen und Härten ![LSH](images/linux_security_hardening_logo.png){width=20 height=20}"
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
* [ClamAV und LMD (Linux Malware Detect)](#clamav-und-lmd-linux-malware-detect)
* [SELinux Überlegungen](#selinux-überlegungen)
* [Scannen nach Rootkits](#scannen-nach-rootkits)
* [Verdächtige Dateien, URLs usw. auf Malware scannen](#verdächtige-dateien-urls-usw-auf-malware-scannen)
* [Audit-Regel zur Steuerung des auditd-Daemons](#audit-regel-zur-steuerung-des-auditd-daemons)
* [Scannen und Härten mit Lynis](#scannen-und-härten-mit-lynis)
* [OpenSCAP-Policies anwenden](#openscap-policies-anwenden)
<!-- TOC -->

# ClamAV und LMD (Linux Malware Detect)

**ClamAV** und ```wget``` auf Debian installieren:
```bash
sudo apt install clamav wget inotify-tools
```

**ClamAV** und ```wget``` auf Redhat installieren:
```bash
sudo dnf install clamav clamav-update wget inotify-tools
```

# ClamAV und LMD (Linux Malware Detect)

**LMD (Linux Malware Detect)** installieren:
```bash
# in root-Shell ausführen, um Berechtigungsprobleme zu umgehen
sudo su -
wget http://www.rfxn.com/downloads/maldetect-current.tar.gz
# Alternative: Download lokal und scp von lokaler Maschine
tar xzvf maldetect-current.tar.gz
cd maldetect-1.6.5/
./install.sh
# bei Rocky linux ggf. zusätzlich Installation von Perl notwendig 
cp README /home/[DEIN_HOME]
logout
# unter Rocky Linux SELinux Context berichtigen
sudo restorecon /lib/systemd/system/maldet.service
```
- Installer erstellt Link für ```maldet```-Dienst
- und lädt automatisch neue Signaturen für Malware runter

# Updates von ClamAV und LMD (Linux Malware Detect)

- für beide laufen Cron-Jobs, die bei Installation erstellt werden
- nutzt ```/lib/systemd/system/clamav-freshclam.service```
- Durchführung von Updates kann man in System-Logs überprüfen

Debian ```/etc/clamav/freshclam.conf```:
```bash
# Check for new database 24 times a day
Checks 24
DatabaseMirror db.local.clamav.net
DatabaseMirror database.clamav.net
```

Redhat ```/etc/cron.d/0hourly```:
```bash
01 * * * * root run-parts /etc/cron.hourly
```
- bei Änderung auch in ```/etc/freshclam.conf``` anpassen

# Konfiguration von ```maldet```

Konfiguration mit guter Dokumentation unter:
```bash
/usr/local/maldetect/conf.maldet
```

aus dem hier:
```bash
default_monitor_mode="users"
# default_monitor_mode="/usr/local/maldetect/monitor_paths"
```

das machen:
```bash
# default_monitor_mode="users"
default_monitor_mode="/usr/local/maldetect/monitor_paths"
```

# Konfiguration von ```maldet```

Verzeichnisse für Scan konfigurieren:
```bash
sudo nano /usr/local/maldetect/monitor_paths
```
- sonst funktioniert ```maldet``` nicht
- dort entsprechende Pfade eintragen, wie ```/home```, ```/root```, ```/var/tmp```, ```/tmp```
- sollten Pfade sein, die gemeinsam mit Windows genutzt werden

# Konfiguration von maldet

weitere mögliche Konfiguration:
```bash
email_alert="1"
email_addr="[DEIN_USER_NAME]"
quarantine_hits="1"
```

Dienst starten:
```bash
sudo systemctl start maldet
```
- ggf. muss dafür noch ```ed``` installiert werden

# Scannen mit ClamAV und maldet

**Malware-Simulation** für Funktionstest:

- von European Institute for Computer Antivirus Research (EICAR) ein [Anti-Malware-Testfile](https://www.eicar.org/download-anti-malware-testfile/) im beliebigen Format herunterladen
- zum Beispiel das txt-File mit ```curl https://secure.eicar.org/eicar.com.txt > eicar.txt```
- das im Home-Verzeichnis mit beliebigem Namen speichern
- sollte dann nach kurzer Zeit automatisch verschwinden
- und in Quarantäne-Ordner zu finden sein
  - zum Beispiel mit ```sudo find / -type f -name '*2.txt*'```
- sowie Log zeigen unter ```/usr/local/maldetect/logs/event_log```

## mehr dazu im ```README```

# SELinux Überlegungen

- *früher* führten Malware-Scans unter Redhat-Systemen zu *Alerts*
- scheint nicht mehr der Fall zu sein

falls man explizit Alerts von SELinux für Virus-Scans auslösen will:
```bash
sudo setsebool -P antivirus_can_scan_system on
getsebool -s | grep 'virus'
antivirus_can_scan_system --> on
antivirus_use_jit --> off
```

# Scannen nach Rootkits

- relevant (auch) unter Linux
- oft gut versteckt, z. B. durch Ersetzung von ```ps```, ```ls```
- **wichtigste Gegenmaßnahme**: ```root``` sehr sparsam verwenden und ```sudo``` bevorzugen

## Rootkits lassen sich haufenweise finden (zum Beispiel auf Github), installieren und weder Rootkit Hunter, SELinux, noch Apparmor finden sie

# Scannen nach Rootkits mit Rootkit Hunter

Installation unter Debian:
```bash
sudo apt install rkhunter
```

Installation unter Redhat:
```bash
sudo dnf install rkhunter
```
- dafür muss das `epel-repository` vorher installiert sein

# Scannen nach Rootkits mit Rootkit Hunter

Signaturen aktualisieren:
```bash
sudo rkhunter --update
```

nach Malware scannen:
```bash
sudo rkhunter -c --rwo
```
- ```c``` = check
- ```rwo``` = report warnings only
- gibt eventuell Aufforderung aus ```rkhunter --propupd``` auszuführen, um ein System File Properties Update auszuführen
  - damit wird Datenbank erstellt, gegen die dann verglichen wird 

Scan-Log unter:
```bash
/var/log/rkhunter.log
```

# Scannen nach Rootkits mit Rootkit Hunter

Cronjob für ```rkhunter``` einrichten:
```bash
sudo crontab -e -u root
```

Cron-Eintrag:
```bash
20 22 * * * /usr/bin/rkhunter -c --cronjob --rwo
```
- kompletten Pfad zum Executable angeben

# Verdächtige Dateien, URLs usw. auf Malware scannen

Online-Dienst dafür ist [Virus Total](https://www.virustotal.com/gui/home/upload)

- nutzt über 50 Scanner für Analyse
- erspart somit lokale Installationen

## keine vertraulichen Daten hochladen

# Audit-Regel zur Steuerung des auditd-Daemons

- ```auditd``` läuft im Kernel-Space, nicht im User-Space
- kann genutzt werden um Dateien, Ordner, Logins zu überwachen/loggen
- ist unter Redhat bereits installiert
- unter Debian mit ```sudo apt install auditd``` installieren

Dienst steuern:
```bash
sudo systemctl start/stop/restart auditd
```

# Steuerung des ```auditd``` Daemon und Erstellung der Audit-Regel

Audit-Regeln anzeigen:
```bash
sudo auditctl -l
```

erstellte Regeln anzeigen:
```bash
sudo less /etc/audit/audit.rules
```
- wird automatisch erstellt = hinzufügen von Regeln über ```auditctl```
- mit ```sudo systemctl restart auditd``` werden neue Regeln aktiv

Regeln in eigene Datei schreiben:
```bash
sudo sh -c "auditctl -l > /etc/audit/rules.d/custom.rules"
```

# Dateien überwachen

Audit-Regeln erstellen:
```bash
sudo auditctl -w /etc/passwd -p wa -k passwd_changes
```
- ```w``` = where = wo überwacht werden soll
- ```p``` = permissions = zu überwachende Berechtigungen
- ```k``` = key = Name der Regel

# Dateien überwachen

Problem: auditd-Regeln werden standardmäßig nicht persistiert, sondern gehen mit Reboot verloren

Lösung: Hinterlegung in ```/etc/audit/audit.rules```

schon vorhandene Datei:
```bash
## This file is automatically generated from /etc/audit/rules.d
-D
-b 8192
-f 1
```

dort anhängen:
```bash
sudo sh -c \
  "echo '-w /etc/passwd -p wa -k passwd_changes' >> /etc/audit/audit.rules"
```

# Ordner überwachen

Ordner und Rechte anlegen:
```bash
sudo mkdir /geheim_ordner
sudo groupadd geheim_gruppe
sudo chown nobody:geheim_gruppe /geheim_ordner/
sudo chmod 3770 /geheim_ordner/
ls -ld /geheim_ordner/
```
Audit-Regeln erstellen:
```bash
sudo auditctl -w /geheim_ordner/ -k geheim_ordner_watch
```

# Systemaufrufe überwachen

Audit-Regeln erstellen:
```bash
sudo auditctl -a always,exit -F arch=b64 -S openat -F auid=1006
```
- ```a``` = action = Aktion
- ```F``` = field = Parameter
- ```S``` = system = System-Aufruf

mehr Hilfe: ```man auditctl```

Systemcalls: ```man syscalls```

# Verwendung von ```ausearch``` und ```aureport```

- Log unter ```/var/log/audit/audit.log``` direkt lesbar
- aber einfacher mit ```ausearch``` und ```aureport```

Datei-Alerts finden:
```bash
sudo ausearch -i -k passwd_changes
```
- ```i``` = Zahlen in Text verwandeln, z. B. ```auid=1000``` in ```auid=cleopatra```
- ```k``` = key = Audit-Regel

Ordner-Alerts finden:
```bash
sudo ausearch -i -k geheim_ordner_watch | less
```

# Verwendung von ```ausearch``` und ```aureport```

- bei zu viel Information mit ```ausearch``` einfach ```aureport``` verwenden

Systemaufruf-Alerts finden:
```bash
sudo aureport -s -i | grep 'openat'
```

Authentifizierungsberichte erstellen:
```bash
sudo aureport -au
```

# Scannen und Härten mit Lynis

- weiteres FOSS-Tool zum Scan nach Schwachstellen und schlechter Sicherheitskonfiguration
- existiert in kostenloser und Enterprise-Version
- wird direkt auf dem zu scannenden System installiert

Installation unter Redhat:
```bash
sudo dnf install lynis
```

Installation unter Debian:
```bash
sudo apt install lynis
```
- neuere Versionen direkt [hier](https://cisofy.com/downloads/lynis/) herunterladen

# Scannen und Härten mit Lynis

Scan durchführen:
```bash
sudo lynis audit system
```
- Ausführung des Scans ist ähnlich wie ein [OpenSCAP](https://www.open-scap.org/getting-started/)-Scan mit generischem Sicherheitsprofil
- zeigt Ergebnisse mit Klassifizierung an, wie Warnung, Empfehlung, Ok, erledigt, deaktiviert
- am Ende der Ausgabe werden konkrete Vorschläge angezeigt
- es wird auch ClamAV oder `maldet` beim Scan mitverwendet
- der angezeigte ```Compliance Status``` ist abhängig von Region, Sektor, etc.

# Scannen und Härten mit Lynis

Scan-Ergebnis ansehen:
```bash
/var/log/lynis.log
```
- oder auf der Konsole

Report-Datei:
```bash
/var/log/lynis-report.dat
```

# OpenSCAP-Policies anwenden

- sind Sicherheits-Profile, die man auf Systeme anwenden kann
- SCAP = Security Content Automation Protocol vom [NIST](https://en.wikipedia.org/wiki/National_Institute_of_Standards_and_Technology)
- kann unter Redhat und Debian installiert werden
- ist aber besser in Redhat integriert
  - man kann ein Profil bereits bei der Installation auswählen 
- als GUI-Tool lässt sich hier die SCAP Workbench nutzen
- nachfolgend betrachten wir - wegen der Unterschiede - Redhat und Debian separat

# OpenSCAP-Policies anwenden - Redhat

Installation auf Redhat:
```bash
sudo dnf install openscap-scanner scap-security-guide
```

# OpenSCAP-Profile ansehen - Redhat

liegen unter ```/usr/share/xml/scap/ssg/content/``` als XML-Dateien

Information zu einem Profil anzeigen:
```bash
sudo oscap info ssg-rl9-ds.xml
```
- enthält Einträge für `profile`, die im Scan verwendet werden (nächste Seite)

# OpenSCAP-Scan anwenden - Redhat

1. Scan starten mit gewünschtem Profil:
```bash
sudo oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_pci-dss \
  --fetch-remote \
  --results scan-xccdf-results.xml \
  --report can-xccdf-results.html \
  /usr/share/xml/scap/ssg/content/ssg-rl9-ds.xml
```
- zeigt Fortschritt auf Screen an
- wichtig sind die mit ```Result fail```

# OpenSCAP-Scan anwenden - Redhat

2. System korrigieren:
```bash
sudo oscap xccdf eval --remediate --profile \
  xccdf_org.ssgproject.content_profile_pci-dss \
  --fetch-remote --results scan-xccdf-results.xml \
  /usr/share/xml/scap/ssg/content/ssg-rl9-ds.xml
```

## Achtung: hier werden direkte Anpassungen vorgenommen und daher in einer VM testen

# OpenSCAP-Policies anwenden - Debian

Installation auf Debian:
```bash
sudo apt -y install openscap-scanner libopenscap25 bzip2
wget https://www.debian.org/security/oval/oval-definitions-\
  $(lsb_release -cs).xml.bz2
bunzip2 oval-definitions-$(lsb_release -cs).xml.bz2
```

# OpenSCAP-Profile ansehen - Debian

Profile an die richtige Stelle kopieren:
```bash
sudo cp oval-definitions-bookworm.xml /usr/share/openscap/
```

Information zu einem Profil anzeigen:
```bash
sudo oscap info oval-definitions-bookworm.xml
```

für Debian andere Profile erhalten:

1. Server-VM mit Fedora erstellen
2. dort das Paket ```scap-security-guide``` installieren
3. kopieren von Fedora ```/usr/share/xml/scap/ssg/content/``` zu Debian

# OpenSCAP-Scan anwenden - Debian

1. Scan unterscheidet sich je nach verwendeten Profil:
```bash
sudo oscap oval eval --report oval-bookworm.html \
  oval-definitions-bookworm.xml
```

2. Bericht anzeigen:
```bash
xdg-open report.html
```

# Fragen

1. Which of the following is true about rootkits?

A. They only infect Windows operating systems.  
B. The purpose of planting a rootkit is to gain root privileges to a system.  
C. An intruder must have already gained root privileges in order to plant a rootkit.  
D. A rootkit isn't very harmful.  

# Fragen

2. Which of the following methods would you use to keep ```maldet``` updated?

A. Manually create a cron job that runs every day.  
B. Do nothing, because maldet automatically updates itself.  
C. Once a day, run the normal update command for your operating system.  
D. Run the maldet update utility from the command line.  

# Fragen

3. Which of the following is true about the ```auditd``` service?

A. On a Debian system, you'll need to stop or restart it with the service command.  
B. On a Red Hat-type system, you'll need to stop or restart it with the service command.  
C. On a Debian system, it comes already installed.  
D. On a Red Hat-type system, you'll need to install it yourself.  

# Fragen

4. You need to create an auditing rule that will alert you every time a particular person reads or creates a file. Which of the following syscalls would you use in that rule?

A. ```openfile```  
B. ```fileread```  
C. ```openat```  
D. ```fileopen```  

# Fragen

5. Which file does the auditd service use to log auditing events?

A. ```/var/log/messages```  
B. ```/var/log/syslog```  
C. ```/var/log/auditd/audit```  
D. ```/var/log/audit/audit.log```  

# Fragen

6. You need to create custom auditing rules for auditd. Where would you place the new rules?

A. ```/usr/share/audit-version_number```  
B. ```/etc/audit```  
C. ```/etc/audit.d/rules```  
D. ```/etc/audit/rules.d```  

# Fragen

7. You're setting up a web server for a bank's customer portal. Which of the following SCAP profiles might you apply?

A. STIG  
B. NISPOM  
C. PCI-DSS  
D. Sarbanes-Oxley  

# Fragen

8. Which of the following is true about OpenSCAP?

A. It can't remediate everything, so you'll need to do advance planning with a checklist before setting up a server.  
B. It can automatically remediate every problem on your system.  
C. It's only available for Red Hat-type distros.  
D. Debian comes with a better selection of SCAP profiles.  

# Fragen

9. Which of the following commands would you use to generate a user authentication report?

A. ```sudo ausearch -au```  
B. ```sudo aureport -au```  
C. Define an audit rule, then do ```sudo ausearch -au```  
D. Define an audit rule, then do ```sudo aureport -au```  

# Fragen

10. Which set of Rootkit Hunter options would you use to have a rootkit scan automatically run every night?

A. ```-c```  
B. ```-c --rwo```  
C. ```--rwo```  
D. ```-c --cronjob --rwo```  

# Antworten

1. C
2. B
3. B
4. C
5. D
6. D
7. C
8. A
9. B
10. D

# Zusammenfassung

Was hast du in diesem Abschnitt gelernt?

<!-- TOC -->
* [ClamAV und LMD (Linux Malware Detect)](#clamav-und-lmd-linux-malware-detect)
* [SELinux Überlegungen](#selinux-überlegungen)
* [Scannen nach Rootkits](#scannen-nach-rootkits)
* [Verdächtige Dateien, URLs usw. auf Malware scannen](#verdächtige-dateien-urls-usw-auf-malware-scannen)
* [Audit-Regel zur Steuerung des auditd-Daemons](#audit-regel-zur-steuerung-des-auditd-daemons)
* [Scannen und Härten mit Lynis](#scannen-und-härten-mit-lynis)
* [OpenSCAP-Policies anwenden](#openscap-policies-anwenden)
<!-- TOC -->
