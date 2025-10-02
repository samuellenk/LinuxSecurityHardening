---
title: "Obligatorische Zugriffskontrolle (MAC) mit SELinux und AppArmor ![LSH](images/linux_security_hardening_logo.png){width=20 height=20}"
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
* [Wie kann SELinux den Administrator unterstützen?](#wie-kann-selinux-den-administrator-unterstützen)
* [Sicherheitskontexte für Dateien und Ordner einstellen](#sicherheitskontexte-für-dateien-und-ordner-einstellen)
* [Fehlersuche mit ```setroubleshoot```](#fehlersuche-mit-setroubleshoot)
* [Wie kann AppArmor den Administrator unterstützen?](#wie-kann-apparmor-den-administrator-unterstützen)
* [Profile in AppArmor](#profile-in-apparmor)
* [Umgang mit Problemen bei AppArmor](#umgang-mit-problemen-bei-apparmor)
<!-- TOC -->

# Wie kann SELinux den Administrator unterstützen?

drei Nutzungswege von SELinux:

- Eindringlinge vom System fernhalten
- nur Personal mit Sicherheit-Freigabe darf auf klassifizierte Elemente zugreifen
- zusätzlich zu MAC unterstützt SELinux auch RBAC

# Wie kann SELinux den Administrator unterstützen?

einige Einsatzszenarien für SELinux:

- Ausführung von Exploits verhindern
- User-Homes schützen vor Zugriff von NFS, Samba, etc.
- bestimmte Skripte/Sprachen auf Webservern verbieten
- Docker-Container besser abschotten

# Wie kann SELinux den Administrator unterstützen?

- als Open-Source-Projekt von der NSA entstanden
- unter Redhat vorinstalliert
- unter anderen Distributionen muss es erst installiert werden
- unter Debian-basierten Distributionen muss Konflikt mit AppArmor vermieden werden

## SELinux und AppArmor **nicht** gleichzeitig auf einem System betreiben

# Funktionsweise von SELinux

läuft in verschiedenen Modis:

1. ```permissive``` = zum Debugging
2. ```enforce``` = zur Durchsetzung

zu Dateien/Ordnern werden Labels hinzugefügt

- Labels werden auch **Kontext** genannt
- zu System-Prozessen werden Labels hinzugefügt
- Labels auf System-Prozessen werden **Domain** genannt

# Status von SELinux auf dem System

Status von SELinux sehen:
```bash
sestatus
```

aktuellen Modus anzeigen lassen:
```bash
getenforce
```

# Sicherheitskontexte für Dateien und Ordner einstellen

Kontext sehen:
```bash
ls -Z
```
- funktioniert auch in Kombination mit anderen Optionen

Domain sehen:
```bash
ps -Z
```

angezeigte Werte gegenüber normaler Ausgabe:

- (generischer) SELinux User, wie ```unconfined_u```
- (generische) SELinux Rolle, wie ```object_r```
- Typ, wie ```unconfined_t```
- Sensitivität, wie ```s0-s0```
- Kategorie, wie ```c0.c1023```

# Sicherheitskontexte für Dateien und Ordner einstellen

- normaler Linux-Admin benutzt daraus meist den **Typ**, um Angreifer fernzuhalten

allgemeine Funktionsweise:

- System-**Prozesse** sollen nur **Objekte** verwenden, die wir erlaubt haben
  - Prozesse = Webserver, Samba, Datenbank, etc.
  - Objekte = Dateien, Ordner, Ports, etc.
- alle Prozesse und Objekte bekommen einen **Typ** zugeordnet
- über **Richtlinien** definieren wir Zugriff für Prozesse auf Objekte

# Sicherheitskontexte für Dateien und Ordner einstellen

- auf Redhat-Distros gibt es bereits eine eingerichtete Policy, die normale Desktop-Nutzung erlaubt
- nennt sich **targeted policy**
- während der Installation kann man aus verschiedenen vordefinierten Policies auswählen

# Fehlersuche mit ```setroubleshoot```

notwendige Tools installieren:
```bash
sudo dnf install setroubleshoot setools policycoreutils
```
- lädt eine **ganze Menge** an **Abhängigkeiten**

Problemstellung:

- Wie kann ich feststellen, ob ich wegen SELinux nicht auf etwas zugreifen kann? 

# Logs von ```setroubleshoot```

Logging aller Regel-Verletzungen in ```/var/log/audit/audit.log```

- man kann direkt mit dem Log arbeiten
- aber ```sealert``` aus Paket ```setroubleshoot``` übersetzt Logs in besser verständliche Sprache
- zusätzlich enthält es Vorschläge zur Behebung
- davon taugt meist der erste wirklich zur Behebung
- kann auch mit GUI *SELinux Alert Browser* eingesetzt werden

# Logs von ```setroubleshoot```

Beispiel für die Nutzung:
```bash
sudo sealert -a /var/log/messages
```

# Arbeiten mit SELinux-Richtlinien

- in Policies kann man Erlaubnis für bestimmte Aktionen erteilen
- werden als ```boolean```-Werte verwaltet (```0```/```1```, ```true```/```false```)

alle Booleans ansehen:
```bash
getsebool -a | sort
```

bestimmten Boolean ansehen:
```bash
getsebool httpd_enable_homedirs
```

Beispiel-Ausgabe:
```bash
httpd_enable_homedirs --> off
```
- Webserver darf also nicht auf Home-Verzeichnisse zugreifen

# Arbeiten mit SELinux-Richtlinien

Booleans durchsuchen:
```bash
getsebool -a | grep 'http'
```

Booleans setzen:
```bash
sudo setsebool -P samba_enable_home_dirs on
```
- Option ```P``` macht die Änderungen permanent

# Beispiel: Web-Inhalte mit aktivem SELinux bereitstellen

```bash
sudo dnf install httpd
sudo systemctl enable --now httpd
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
ps ax -Z | grep httpd
echo '<html><body>Funktioniert mit SELinux!</body></html>' > index.html
ls -Z
mv index.html /var/www/html
```
- dann über Browser (auf Client) die Seite aufrufen mit ```http://[URL_ODER_HOST]```
- wird wegen unpassendem Context (noch) nicht funktionieren

# Beispiel: Web-Inhalte mit aktivem SELinux bereitstellen

Anpassung vom Context:
```bash
# hier w#re auch "restorecon" oder "semanage" möglich:
sudo chcon -t httpd_sys_content_t index.html
# oder auf dem Verzeichnis ausführen:
chcon -R -t httpd_sys_content_t /var/www/html
ls -Z
```
- dann über Browser (auf Client) die Seite aufrufen mit ```http://[URL_ODER_HOST]```
- sollte jetzt funktionieren
- außer der Browser hat lokal noch die alte Seite im Cache

# Beispiel: Web-Server mit SELinux schützen

```bash
getsebool -a | grep 'http'
# Webserver soll mit PHP-Engine interagieren können
sudo setsebool -P httpd_unified on
# keine CGI-Skripte ausführen
sudo setsebool -P httpd_enable_cgi off
```

# Wie kann AppArmor den Administrator unterstützen?

- AppArmor ist eine Alternative für SELinux auf Debian und Suse
- auf Debian bereits vorinstalliert
- schützt genauso vor unerlaubten Zugriffen
- tut den gleichen Job wie SELinux, aber grundlegend anders

## SELinux vs. AppArmor

- SELinux gibt sofort systemweiten Schutz
- AppArmor verwendet Profile für jede einzelne Anwendung

# Funktionsweise von AppArmor

- statt Labels verwendet AppArmor die Pfadnamen der zu kontrollierenden Dateien und Ordner
- AppArmor verwendet nicht systemweite Profile, sondern Applikations-Profile
- einfacher eigene Policies zu schreiben
- viele Anwendungen bringen eigene Policy bereits mit, die sich anpassen lassen
- Utilities können bei Automatisierung helfen

## SELinux **Policy** = AppArmor **Profil**

# Setup von AppArmor

Anwendung installieren:
```bash
sudo apt install apparmor apparmor-utils
```

Profile installieren, falls nicht automatisch geschehen (z. B. unter OpenSuse):
```bash
sudo apt install apparmor-profiles apparmor-profiles-extra
```

# Prüfen, ob AppArmor aktiv ist

```bash
sudo systemctl status apparmor
sudo aa-status
```

# Profile in AppArmor

Profile sehen:
```bash
ls -l /etc/apparmor.d/
```

neue Anwendung hinzufügen:
```bash
sudo apt install lxc
```

erzeugt neue Profile:
```bash
/etc/apparmor.d/lxc-containers
/etc/apparmor.d/lxc/lxc-default*
```

# Abstractions in AppArmor

**Abstractions** sind Teil-Profile, die in eigenen Profilen verwendet werden können

- Beispiele sind ```apache2-common```, ```authentication```, ```cups-client```

Abstractions sehen:
```bash
ls -l /etc/apparmor.d/abstractions/
```

Zeile aus ```web-data``` abstraction:
```bash
/srv/www/htdocs/** r,
```
- Angabe von relevantem Pfad
- ```**``` = rekursiv
- ```r``` steht für Read-Access
- alles hier nicht enthaltene steht explizit unter diesem Profil nicht zur Verfügung

# Variablen in AppArmor

**Variablen** in ```tunables``` auflisten:
```bash
cd /etc/apparmor/tunables
ls -l
```
- für manche Pakete gibt es zwar AppArmor-Profile, aber die werden nicht zwingend aktiviert
- hier ist individuelle Prüfung und ggf. Anpassung sinnvoll

Beispiel-Regeln:

- ```/var/run/some_program.pid rw,``` = Prozess hat RW-Rechte für dieses PID-File
- ```/etc/ld.so.cache r,``` = Prozess hat R-Rechte für dieses File
- ```/tmp/some_program.* l,``` = Prozess kann man some_program Links erstellen, ändern, löschen
- ```/bin/mount ux``` = Prozess hat unbeschränkte (=ohne Profil) X-Rechte auf mount

# Modis von AppArmor

enforce
: wie **enforcing** in SELinux verbietet es alles, was nicht in Policy ist und schreibt dazu ein Log

audit
: wie **enforce**, aber erlaubte Aktionen werden auch geloggt

complain
: wie **permissive** in SELinux erlaubt es verbotene Aktion, die aber im ```/var/log/audit/audit.log``` oder System-Log geschrieben werden

# Arbeiten mit AppArmor Command-Line Utilities

- sind enthalten im Paket ```apparmor-utils```
- die verschiedenen AppArmor-Utilities heissen ```aa-*```

nach Installation von Samba die dazugehörigen Profile in enforce-Modus versetzen:
```bash
sudo aa-enforce /usr/sbin/nmbd usr.sbin.nmbd
sudo aa-enforce /usr/sbin/smbd usr.sbin.smbd
```
- erster Parameter ist das betreffende Executable
- zweiter Parameter ist das betreffende Profil
- danach entsprechend Dienst/-e neu starten

# Status von AppArmor prüfen

Status von AppArmor sehen:
```bash
sudo aa-status
```

AppArmor deaktivieren:
```bash
sudo systemctl stop apparmor.service
sudo systemctl disable apparmor.service
```

AppArmor re-aktivieren:
```bash
sudo systemctl enable apparmor.service
sudo systemctl start apparmor.service
```

# Modis von AppArmor ändern

**ein** Profil in anderen Modus bringen:
```bash
sudo aa-complain /path/to/bin
sudo aa-audit /path/to/bin
sudo aa-enforce /path/to/bin
```

**alle** Profile in anderen Modus bringen:
```bash
sudo aa-complain /etc/apparmor.d/*
sudo aa-audit /etc/apparmor.d/*
sudo aa-enforce /etc/apparmor.d/*
```

# Profile neu laden

**ein** Profil neu laden:
```bash
sudo apparmor_parser -r /etc/apparmor.d/profile.name
```

**alle** Profile neu laden:
```bash
sudo systemctl reload apparmor.service
```

# Profile de-/aktivieren

Deaktivierung:

- dazu wird der Ordner ```/etc/apparmor.d/disable``` genutzt
- Alternative ist ```aa-disable```

Beispiel:
```bash
sudo ln -s /etc/apparmor.d/profile.name /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/profile.name
```

Re-Aktivierung:

Beispiel:
```bash
sudo rm /etc/apparmor.d/disable/profile.name
cat /etc/apparmor.d/profile.name | sudo apparmor_parser -a
```

# Mehr über Profile in AppArmor

weitere Profil-Pakete verfügbar:

- ```apport-profiles```
- ```apparmor-profiles-extra```

oder eigene Profile anlegen:

- Profile haben zwei Arten von Einträgen
  1. Pfade zu Applikationen, die der Prozess im Dateisystem verwenden darf
  2. Fähigkeits-Einträge: welche Privilegien ein begrenzter Prozess nutzen darf

# Beispiel-Profil in AppArmor

```bash
#include <tunables/global>
/bin/ping flags=(complain) {
  #include <abstractions/base>
  #include <abstractions/consoles>
  #include <abstractions/nameservice>

  capability net_raw,
  capability setuid,
  network inet raw,

  /bin/ping mixr,
  /etc/modules.conf r,
}
```

# Profile erstellen

1. Test-Plan für neue Applikation entwickeln mit 
- ein paar Standard-Testfällen:
  - Programm starten
  - Programm stoppen
  - Programm neu laden
2. neues Profil generieren:
```bash
sudo aa-genprof slapd
```
3. neues Profil in ```apparmor-profiles``` Package aufnehmen lassen
   - inklusive Test-Cases

# Profile aktualisieren

- Fehl-Verhalten von Apps unter AppArmor wird geloggt
- nach AppArmor-Logs suchen:
```bash
sudo aa-logprof
```
- auf (Ubuntu-) Minimal-Server muss dafür ggf. erst ```rsyslog``` wieder installiert werden
- alternativ mit ```-f /var/log/log``` angeben

# Profile anpassen

Möglichkeiten:

1. Profil-Datei direkt editieren
  - immer möglich
  - könnte aber durch Update überschrieben werden
2. Tunables verwenden
  - diese Variablen können in Templates genutzt werden
  - betreffen nur Profile, die diese nutzen
3. einen lokalen Override modifizieren
  - sollen Nachteile von 1. ausgleichen
  - liegen unter ```/etc/apparmor.d/local/```
  - für Pakete die bekanntermaßen einfache Anpassungen benötigen

# Verweigerungen durch Profile debuggen und prüfen

- landet in Kernel-Log, wie ```dmesg``` oder ```kern.log```
- enthält ```apparmor="DENIED"```

# Umgang mit Problemen bei AppArmor

das Beispiel von oben brachte beim versuchten Re-Start vom Samba-Dienst einen Fehler:
```bash
sudo systemctl restart smbd
```

Ursachen-Suche:

- ```journalctl -xe```, aber das schneidet die Log-Einträge am Bildschirmrand ab
- ```less / tail /var/log/syslog```

Fund:

- ```apparmor="DENIED" operation="mknod" profile="/usr/sbin/smbd" name="/run/samba/msg.```

weiteres Vorgehen:

- Browser & Suchmaschine deiner Wahl mit dem Fund füttern

# Umgang mit Problemen bei AppArmor

notwendige Extra-Zeile im Profil von Samba:
```bash
/run/samba/** rw,
```

dann Profil neu laden:
```bash
sudo apparmor_parser -r usr.sbin.smbd
```

zuletzt Samba-Dienst neu starten;
```bash
sudo systemctl restart smbd
```

# Fragen

1. Which of the following would represent a MAC principle?

A. You can set permissions on your own files and directories however you need to.  
B. You can allow any system process to access whatever you need it to access.  
C. System processes can only access whichever resources MAC policies allow them to access.  
D. MAC will allow access, even if DAC doesn't.  

# Fragen

2. How does SELinux work?

A. It places a label on each system object and allows or denies access according to what SELinux policies say about the labels.  
B. It simply consults a profile for each system process to see what the process is allowed to do.  
C. It uses extended attributes that an administrator would set with the ```chattr``` utility.  
D. It allows each user to set his or her own MACs.  

# Fragen

3. Which of these utilities would you use to fix an incorrect SELinux security context?

A. ```chattr```  
B. ```chcontext```  
C. ```restorecon```  
D. ```setsebool```  

# Fragen

4. For normal day-to-day administration of a Red Hat-type server, which of the following aspects of a security context would an administrator be most concerned about?

A. user  
B. role  
C. type  
D. sensitivity  

# Fragen

5. You’ve set up a new directory that a particular daemon wouldn't normally access, and you want to permanently allow that daemon to access that directory. Which of the following utilities would you use to do that?

A. ```chcon```  
B. ```restorecon```  
C. ```setsebool```  
D. ```semanage```  

# Fragen

6. Which of the following constitutes one difference between SELinux and AppArmor?

A. With SELinux, you have to install or create a policy profile for each system process that you need to control.  
B. With AppArmor, you have to install or create a policy profile for each system process that you need to control.  
C. AppArmor works by applying a label to each system object, while SELinux works by simply consulting a profile for each system object.  
D. It's much easier to write a policy profile for SELinux, because the language is easier to understand.  

# Fragen

7. Which ```/etc/apparmor.d``` subdirectory contains files with pre-defined variables?

A. ```tunables```  
B. ```variables```  
C. ```var```  
D. ```functions```  

# Fragen

8. Which of the following utilities would you use to enable an AppArmor policy?

A. ```aa-enforce```  
B. ```aa-enable```  
C. ```set-enforce```  
D. ```set-enable```  

# Fragen

9. You've already enabled an AppArmor policy for a daemon, but you now need to change the policy. Which utility would you use to reload the modified policy?

A. ```aa-reload```  
B. ```apparmor_reload```  
C. ```aa-restart```  
D. ```apparmor_parser```  

# Fragen

10. You're testing a new AppArmor profile, and you want to find any possible problems before you place the server into production. Which AppArmor mode would you use to test that profile?

A. permissive  
B. enforce  
C. testing  
D. complain  

# Antworten

1. C
2. A
3. C
4. C
5. D
6. B
7. A
8. A
9. D
10. D

# Zusammenfassung

Was hast du in diesem Abschnitt gelernt?

<!-- TOC -->
* [Wie kann SELinux den Administrator unterstützen?](#wie-kann-selinux-den-administrator-unterstützen)
* [Sicherheitskontexte für Dateien und Ordner einstellen](#sicherheitskontexte-für-dateien-und-ordner-einstellen)
* [Fehlersuche mit ```setroubleshoot```](#fehlersuche-mit-setroubleshoot)
* [Wie kann AppArmor den Administrator unterstützen?](#wie-kann-apparmor-den-administrator-unterstützen)
* [Profile in AppArmor](#profile-in-apparmor)
* [Umgang mit Problemen bei AppArmor](#umgang-mit-problemen-bei-apparmor)
<!-- TOC -->
