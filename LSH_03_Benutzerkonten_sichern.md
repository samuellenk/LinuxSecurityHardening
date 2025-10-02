---
title: "Benutzerkonten sichern ![LSH](images/linux_security_hardening_logo.png){width=20 height=20}"
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
* [Gefahren bei Nutzung des ```root```-Users](#gefahren-bei-nutzung-des-root-users)
* [```sudo```-Privilegien einrichten](#sudo-privilegien-für-administrative-user-einrichten)
* [Weitere Tipps und Tricks zur Verwendung von ```sudo```](#weitere-tipps-und-tricks-zur-verwendung-von-sudo)
* [Home-Verzeichnisse sperren](#home-verzeichnisse-sperren---redhat)
* [Durchsetzen starker Passwort-Kriterien](#durchsetzen-starker-passwort-kriterien)
* [Verhindern von Brute-Force-Kennwortangriffen](#verhindern-von-brute-force-kennwortangriffen)
* [Sperren von Benutzerkonten](#sperren-von-benutzerkonten)
* [Sicherheits-Banner einrichten](#sicherheits-banner-einrichten)
* [Erkennung kompromittierter Passwörter](#erkennung-kompromittierter-passwörter)
<!-- TOC -->

# Gefahren bei Nutzung des ```root```-Users

- man kann **unbeabsichtigt** das System beschädigen
- und auch **Böswillige** haben leichteres Spiel

## deshalb unbedingt ```sudo``` nutzen

# Vorteile von ```sudo```

- Differenzierung möglich:
  - bestimmten Benutzern volle Administratorrechte zuweisen
  - anderen Benutzern nur nötige Rechte zuweisen
- ermöglicht Durchführung administrativer Aufgaben durch Eingabe des Benutzer-Passworts
- Eindringlinge haben es schwerer, wenn ```root``` deaktiviert ist
- Sudo-Richtlinien lassen sich im gesamten Unternehmensnetzwerk bereitstellen, auch wenn es aus einer Mischung von Unix-, BSD- und Linux-Maschinen besteht
- man kann besser auditieren, weil man sehen kann, was Benutzer mit ihren Administratorrechten machen

# Überblick über User und Gruppen erhalten

Zu welchen Gruppen gehört mein User aktuell?
```bash
groups
```

Zu welchen Gruppen gehört ein anderer User aktuell?
```bash
cat /etc/passwd | grep [BENUTZER_NAME]
```

Welche Gruppen gibt es auf dieser Umgebung?
```bash
more /etc/group
```

Wer ist Mitglied einer bestimmten Gruppe?
```bash
more /etc/group | grep [BENUTZER_NAME]
```

## Debian-Gruppe *sudo* = Redhat/Suse-Gruppe *wheel*

# ```sudo```-Privilegien für administrative User einrichten

- Benutzer zur vordefinierten Admin-Gruppe hinzufügen
- Erstellen eines Eintrags in der Sudo-Richtliniendatei
- Einrichten von sudo für Benutzer mit nur bestimmten delegierten Berechtigungen

# ```sudo```-Privilegien für administrative User einrichten

**bestehenden** Benutzer zur Admin-Gruppe hinzufügen:
```bash
# Debian
sudo usermod -aG sudo [BENUTZER_NAME]
# Redhat
sudo usermod -aG wheel [BENUTZER_NAME]
```
- Option ```-a``` vermeidet Entfernen des Users von Gruppen
- Option ```-G``` fügt User zu Gruppe hinzu

# ```sudo```-Privilegien für administrative User einrichten

**neue** Benutzer anlegen und direkt zur Admin-Gruppe hinzufügen:
```bash
# Debian
sudo useradd -G sudo -m -d /home/[BENUTZER_NAME] -s /bin/bash [USER]
# Redhat
sudo useradd -G wheel -m -d /home/[BENUTZER_NAME] -s /bin/bash [USER]
```
- Option ```-m``` = ```--create-home```
- Option ```-d``` = Pfad zum Home-Verzeichnis

# ```sudo```-Privilegien für administrative User einrichten

**Cloud**-VMs passend konfigurieren:

- hier ist meist nur der ```root```-User konfiguriert
- also direkt nach Anmeldung einen eigenen normalen Benutzer erstellen
- den eigenen Benutzer zu ```sudo``` hinzufügen
- dann den ```root```-User sperren:
```bash
sudo passwd -l root
```
- und dann nur noch mit dem eigenen User arbeiten

# Syntax und Beispiele zu ```/etc/sudoers```

Einträge verstehen:
```bash
<wer>   <Host>=(<als Benutzer>:<als Gruppe>) <darf ausführen>
```

Beispiel:
```bash
%wheel  ALL = (ALL)  ALL
```

- hier steht ```%``` für eine Gruppe
- Einträge werden in der Reihenfolge des Erscheinens abgearbeitet
- Einträge sind kumulativ

Beispiel:
```bash
frank   ALL=(ALL:ALL) /usr/bin/apt
frank   ALL=(ALL:ALL) /usr/bin/systemctl *
```
- User darf sowohl `apt` als auch `systemctl` nutzen

# ```sudo```-Privilegien mit delegierten Rechten einrichten

- Eintrag in /etc/sudoers hinzufügen in der Form 
```bash
user1 ALL = (root) /usr/bin/apt update, /usr/bin/apt dist-upgrade
```
- oder für ein bestimmtes Skript etc.
```bash
%users ALL = NOPASSWD: /usr/sbin/IRGENDEINSKRIPT
```

## bearbeite ```/etc/sudoers``` immer mit ```visudo```

# Vergleich administrative Benutzer vs. delegierte Rechte

Vorteile von ```/etc/sudoers```:

- wenn man mit nur einer Maschine arbeitet
- oder eine **sudo-Policy** über das ganze Netzwerk deployt, die nur eine Admin-Gruppe nutzt

Aber was tun bei gemischten Netzwerken (Redhat, Ubuntu, Suse, ...) und wenn man nicht an jeder Maschine ändern will?

1. einzelner Eintrag in ```/etc/sudoers``` pro User
2. oder Einträge in ```/etc/sudoers``` mit **Alias / Benutzergruppe** verwenden

→ gute Beispiele im Redhat/Suse ```sudoers```-File

# Weitere Tipps und Tricks zur Verwendung von ```sudo```

Admin auf Zeit:

- Timeout in ```/etc/sudoers``` auf null setzen (Standardwert ist 15 Minuten)
- ```Defaults timestamp_timeout = 0```

visuelles Feedback bei Passworteingabe:

- Sternchen für jedes Zeichen vom eingegebenen Passwort anzeigen
- ```Defaults pwfeedback```

eigene ```sudo```-Berechtigungen betrachten:

- `sudo -l` oder `sudo -l -U frank`

Timer für ```sudo``` zurücksetzen:

- ```sudo -k```

# Programme als anderer User ausführen

Programme können auch unter Namen eines anderen regulären Users gestartet werden

```sudo -H -u [BENUTZERNAME] [PROGRAMM]```

- Option ```H``` = Home setzen
- Option ```u``` = anderer User werden
- ```sudo -i -u [BENUTZERNAME]```

# Zugriff auf Root-Shell verhindern

**nie** den Eintrag aktivieren:
```bash
%wheel  ALL = (ALL)  NOPASSWD: ALL
```
- damit könnten alle Mitglieder der Gruppe `wheel` alle sudo-Befehle ohne Passworteingabe ausführen

**nie** solche Zeilen einfügen:
```bash
tux    ALL=(ALL) /bin/bash, /bin/zsh
```
- damit gibt man dem User/Gruppe effektiv root-Berechtigungen

# Shell-Escapes verhindern

- besonders bei Text-Editoren und Pagern existieren Shell-Escapes
- zum Beispiel `vi`, `emacs`, `less`, `view`, `more`, ...
```bash
:!ls
:shell
```
- kann so zustande kommen (soll nur Editieren einer Datei ermöglichen):
```bash
user ALL=(ALL) /bin/vim /etc/ssh/sshd_config
```
- stattdessen:
```bash
user ALL=(ALL) sudoedit /etc/ssh/sshd_config
```

# gefährliche Programme verhindern

- hier sind zwar keine Shell-Escapes möglich, aber können auch gefährlich sein
- zum Beispiel ```cat, cut, awk, sed```, ...
- wenn man dafür Berechtigungen geben muss, dann möglichst für spezifische Dateien 

# Aktionen mit Befehlen beschränken

- bei diesem Eintrag hat der User volle Kontrolle über den Befehl:
```bash
user ALL=(ALL) /usr/bin/systemctl
```

- besser so einschränken: alle Aktionen auf einen Dienst
```bash
user ALL=(ALL) /usr/bin/systemctl * sshd
```

- besser so einschränken: bestimmte Aktionen auf einen Dienst
```bash
user ALL=(ALL) /usr/bin/systemctl status sshd, \
  /usr/bin/systemctl restart sshd
```

# Benutzer als Andere ausführen lassen

- hier steht ```(ALL)``` für jeden User, wozu auch ```root``` gehört
- gibt also effektiv ```root```-Rechte
- besser so einschränken:
```bash
user ALL=(sudo) /usr/bin/systemctl status sshd, \
  /usr/bin/systemctl restart sshd
```

# Missbrauch durch Shell-Skripte verhindern

- was in ```/etc/sudoers``` steht:
```bash
frank ALL=(ALL) /usr/local/sbin/frank_script.sh
```

- was im Skript stehen **sollte**:
```bash
#!/bin/bash
echo "Das Skript vom $(whoami)."
```

- was **wirklich** im Skript steht:
```bash
#!/bin/bash
echo "Das Skript vom $(whoami)."
sudo -i
```
- könnte dann zum Beispiel ```root```-Rechte auf sein Skript setzen, usw.

# Standardbenutzerkonten erkennen und löschen

- besonders relevant für IoT-Geräte mit vorinstallierten Systemen
- haben oft Standard-Zugangsdaten, die offen zugänglich sind

also folgendes tun:

- eigenes Benutzerkonto anlegen und in ```sudoers``` eintragen
- Passwort für ```root```-User ändern oder ihn komplett sperren

# Besondere sudo-Überlegungen für (Open)Suse

- standardmäßig wird ```root``` mit gleichem Passwort angelegt wie erster User
- also eigenen User zu ```wheel``` hinzufügen:
- und ```/etc/sudoers``` editieren
```bash
# Defaults targetpw
# ALL ALL=(ALL) ALL
%wheel ALL=(ALL:ALL) ALL
```

# Home-Verzeichnisse sperren - RedHat

- verschiedene Standard-Einstellungen je nach Distribution

Konfiguration dafür kommt aus ```/etc/login.defs```, insbesondere:

- ```HOME_MODE 0700``` → Berechtigungen für HOME-Ordner
- ```UMASK 022``` → benutzt für HOME-Rechte, falls HOME_MODE nicht existiert
- ```CREATE_HOME yes``` → HOME wird angelegt

# umask

- Standard-Rechte für Ordner: ```777```
- Standard-Rechte für Dateien: ```666```
- **umask** wird verwendet, um bei neuen Ordnern und Dateien **Berechtigungen** von diesen Werten **wegzunehmen**
  - kommt nur zum Tragen bei Erstellung von Elementen in Datei-System
- mehr zu `umask` unter `man bash`, da `umask` ein Shell-Builtin ist

Standard-umask:

- Redhat: 077 = entfernt alle Rechte für Gruppe und Andere
- nicht Redhat: 022 = HOME wird mit 755 erstellt = jeder darf alle HOME-Ordner öffnen

# Home-Verzeichnisse sperren - Debian

User anlegen mit expliziter Angabe von Home und Shell, damit man es nicht später berichtigen muss:
```bash
sudo useradd -m -d /home/frank -s /bin/bash frank
```
- Option ```m``` = erstellt Home
- Option ```d``` = spezifiziert Home-Pfad
- Option ```s``` = spezifiziert User-Shell
- fehlende Shell und HOME kann man auch mit ```adduser``` umgehen

dann Zugriff einschänken:
```bash
cd home
sudo chmod 700 *
```

# Home-Verzeichnisse sperren - Debian

in der eigenen Shell (vorübergehend) ändern:
```bash
umask 0077
mkdir ordner
touch file
ls -l
```
oder in ```/etc/login.defs``` (dauerhaft) ändern:
```bash
UMASK 077
HOME_MODE 0700
```
- damit HOME-Verzeichnisse wie unter Redhat erstellt werden
- UMASK-Werte sind [hier](https://en.wikipedia.org/wiki/Umask) zu finden

# Durchsetzen starker Passwort-Kriterien

- starke Passwörter sind wichtig, weil sie (immer noch) die Haupt-Variante der Authentifizierung sind
- man kann dafür ```pwquality``` installieren
- und dann damit Kriterien für Passwort-Qualität setzen

# Allgemeine Annahmen für starke Passwörter

- nicht aus Wörterbuch
- keine persönlichen Daten enthalten
- sollen Kombination aus Kleinbuchstaben, Großbuchstaben, Ziffern und Sonderzeichen enthalten
- alle 30+ Tage ändern
- Mindestlänge

# Gegenmeinungen von Experten

- ob man alle x Tage ändern soll
- ob alle Zeichengruppen enthalten sein sollen
- welche die Mindestlänge ist

# Umsetzung auf Redhat

- hier ist ```pwquality``` standardmäßig installiert
- Konfiguration liegt in ```/etc/security/pwquality.conf```

# Umsetzung auf Redhat

```bash
cd /etc/pam.d
grep 'pwquality' *
su -
cd /etc/security
nano pwquality.conf
minlen = 12
minclass = 3
maxclassrepeat = 4
sudo useradd johndoe
sudo passwd johndoe
```

# Umsetzung auf Debian

- hier ist ```pwquality``` nicht standardmäßig installiert
- kann aber erfolgen über:
```bash
sudo apt install libpam-pwquality
```
- Konfiguration erfolgt hier wie unter Redhat über ```/etc/security/pwquality.conf```

# Bemerkungen zu ```pwquality.conf```

- unter ```/etc/login.defs``` gibt es ```PASS_MIN_LEN```, was durch ```minlen``` in ```/etc/security/pwquality.conf``` überschrieben wird
- Passwort-Kriterien gelten für normale User
  - Administrator kann schwaches Passwort festlegen

# Ablauf von Passwort und Konto einstellen und durchsetzen

- wir stellen Ablaufdatum für ```useradd``` ein
- und setzen Kontoablauf für ```useradd```, ```usermod```, ```chage```

## Passwortablauf # Kontoablauf

# Beispiele warum das sinnvoll sein kann

- Nutzerkonten für eine Konferenz wurden erstellt und sind ungenutzt weiter aktiv
- Externe haben aktive Accounts, obwohl ihr Vertrag schon beendet ist

daraus resultierende Sicherheits-Probleme:

- wir brauchen ein System, das uns über temporäre Accounts auf dem Laufenden hält
- Passwörter sollten regelmäßig geändert werden

# Ablaufdatum pro Account setzen

über ```/etc/login.defs```:

- Passwortablauf alle x Tage definieren
- Kontoablauf zu bestimmten Datum definieren

## abgelaufenes Konto kann nur von Admin entsperrt werden

# Settings zum Passwortablauf ändern

Information zum Passwortablauf erhalten:
```bash
chage -l [BENUTZER_NAME]
```
- Werte dazu kommen aus ```/etc/login.defs```: ```PASS_MAX_DAYS```, ```PASS_MIN_DAYS```, ```PASS_WARN_AGE```

# Settings zum Passwortablauf ändern

- für ```useradd``` ändern unter ```/etc/default/useradd```
  - ```EXPIRE``` = nach wie vielen Tagen das Konto abläuft
  - ```INACTIVE``` = nach wie vielen Tagen das Konto gesperrt wird, wenn man das Passwort nicht ändert
- (neue) Konfiguration betrachten über ```sudo useradd -D```

# Settings zum Passwortablauf ändern

Änderung der Konfiguration direkt über Befehle:

- ```sudo useradd -D -f 5``` = setzt ```INACTIVE=5```
- ```sudo useradd -D -s /bin/zsh``` = setzt ```SHELL=/bin/zsh```
- kann sinnvoll sein, um es in einem Shell-Skript zu nutzen

# Settings zum Kontoablauf ändern

- meist auf Account-Basis nötig, zum Beispiel wenn externe Mitarbeiter Unternehmen wieder verlassen

Änderung für einen neuen User:
```bash
sudo useradd -e 2023-12-31 amueller
sudo chage -l amueller
```

# Settings zum Kontoablauf ändern

Änderung für einen bestehenden User:
```bash
sudo chage -l amueller
sudo usermod -e 2023-12-31 amueller
sudo chage -l amueller
```

# Settings zum Kontoablauf ändern

User muss Passwort ändern bei erster Anmeldung:
```bash
sudo useradd kschmidt
sudo chage -d 0 kschmidt
sudo chage -l kschmidt
```

Daten zu Passwortablauf für bestimmten User anzeigen:
```bash
sudo chage -l kschmidt
```

# Verhindern von Brute-Force-Kennwortangriffen

früher war das ein Problem-Szenario:

- Mindestlänge vom Passwort 8 Kleinbuchstaben = auf den ersten UNIX-Systemen
- man hat 3 fehlgeschlagene Versuche erlaubt bevor das Konto gesperrt wurde

Abwägung:

- Wie oft sollte es ein User versuchen können?
- Wann betrachten wir es als Angriff?

# So sieht es heute aus

- User werden frustriert
- zusätzliche Arbeit beim Helpdesk
- Konto gesperrt bevor man Informationen zum Angreifer hat

Empfehlungen:

- 100 fehlgeschlagene Versuche sorgen noch für ausreichend Sicherheit
- und ermöglichen es Informationen über Angreifer zu erhalten
- entlastet User und Helpdesk

# Konfiguration für Redhat

- man kann ```pam_faillock``` über Konfigurations-Dateien editieren
- aber Redhat bietet einen einfachen Weg mit ```authselect```

Profile anzeigen:
```bash
sudo authselect list
```

Details zum ```minimal```-Profil anzeigen:
```bash
sudo authselect list-features minimal
```
- zeigt auch ```with-faillock``` als Funktion

# Konfiguration für Redhat

Profil einschalten:
```bash
sudo authselect select minimal --force
```

Funktion aktivieren:
```bash
sudo authselect enable-feature with-faillock
```

Konfiguration ```/etc/security/faillock.conf``` anpassen:
```bash
silent
deny = 3
unlock_time = 600
even_deny_root
```

# Konfiguration für Debian

- auf Debian ist das ```authselect```-Modul nicht verfügbar
- also muss Konfiguration angepasst werden

in ```/etc/pam.d/common-auth``` oben diese Zeilen einfügen:
```bash
auth    required    pam_faillock.so preauth silent
auth    required    pam_faillock.so authfail
```

in ```/etc/pam.d/common-account``` unten diese Zeilen einfügen:
```bash
auth    required    pam_faillock.so
```

# Konfiguration für Debian

Konfiguration ```/etc/security/faillock.conf``` anpassen:
```bash
silent
deny = 3
unlock_time = 600
even_deny_root
```

# User prüfen, entsperren und Logs betrachten

nach fehlgeschlagenen Login-Versuchen diese anzeigen:
```bash
sudo faillock
```

User vor Ablauf der Sperrzeit freigeben:
```bash
sudo faillock --reset --user [BENUTZER]
```

# Sperren von Benutzerkonten

Nutzung von ```usermod``` und ```passwd``` zum Sperren von User- und Root-Accounts

Beispiele:

- Nutzer verlässt die Firma
- Nutzer ist im Urlaub / länger abwesend
- Ermittlungen gegen Nutzer

## Gesetzeslage beachten

# Optionen um einen Account zu deaktivieren

1. usermod
  - ```sudo usermod -e 2023-04-28 [USER_NAME]``` = Ablaufdatum setzen
  - ```sudo usermod --expiredate 1 [USER_NAME]``` = setzt Ablauf auf 1.1.1970
  - ```sudo usermod -L|U [USER_NAME]``` = sperren/entsperren
2. passwd:
  - ```passwd -l|u [USER_NAME]``` = lock/unlock
  - Vorteil, dass es hier ein kurzes Feedback gibt
3. weitere Variante: direkt in ```/etc/shadow``` vor verschlüsseltes Passwort ein Ausrufezeichen setzen
  - "!" kann bei Verschlüsselung nicht entstehen = Login unmöglich
  - equivalent zu ```sudo usermod -L [USER_NAME]```

# Sperren von Root-Account

Vorgehen nach Logout von Root-Account und Login mit neuem User:
```bash
sudo passwd -l root
```

falls es jemals nötig wird so wieder entsperren:
```bash
sudo passwd -u root
```

# Sicherheits-Banner einrichten

- damit stellt man klar, das nur autorisierte Nutzer auf einem System erlaubt sind
- es gibt zwei Wege:

1. ```/etc/motd```
  - muss unter Debian erzeugt werden, ist unter Redhat bereits vorhanden
  - kommt bei Debian aus dem Verzeichnis ```update-motd.d```
  - Inhalt wird nach Login angezeigt
2. ```/etc/issue```
  - Inhalt wird Start und vor Login angezeigt

# Erkennung kompromittierter Passwörter

auf dedizierten Webseiten kann man kompromittierte Passwörter prüfen:

- [Have I been pwned?](https://haveibeenpwned.com/passwords)
- aber bitte nicht Passwörter aus Produktion senden
- stattdessen API und Passwort-Hashes benutzen

```bash
curl https://api.pwnedpasswords.com/range/21BD1 | wc -l
```

# Erkennung kompromittierter Passwörter - Skript

```bash
#!/bin/bash
candidate_password=$1
echo "Candidate password: $candidate_password"

full_hash=$(echo -n $candidate_password | sha1sum | \
  awk '{print substr($1, 0, 32)}')
prefix=$(echo $full_hash | awk '{print substr($1, 0, 5)}')
suffix=$(echo $full_hash | awk '{print substr($1, 6, 26)}')

if curl -s https://api.pwnedpasswords.com/range/$prefix | grep -i $suffix;
  then echo "Candidate password is compromised";
  else echo "Candidate password is OK for use";
fi
```

# Fragen

1. What is the best way to grant administrative privilege to users?

A. Give every administrative user the root user password.  
B. Add each administrative user to either the sudo group or the wheel group.  
C. Create sudo rules that only allow administrative users to do the tasks that are directly related to their jobs.  
D. Add each administrative user to the sudoers file and grant them full administrative privileges.

# Fragen

2. Which of the following is true?
 
A. When users log in as the root user, all the actions that they perform will be recorded in the auth.log or the secure log file.  
B. When users use sudo, all the actions that they perform will be recorded in the messages or the syslog file.  
C. When users log in as the root user, all the actions that they perform will be recorded in the messages or the syslog file.  
D. When users use sudo, all the actions that they perform will be recorded in the auth.log or the secure log file.

# Fragen

3. Which of the following methods would you use to create sudo rules for other users?

A. Open the /etc/sudoers file in your favorite text editor.  
B. Open the /etc/sudoers file with visudo.  
C. Add a sudoers file to each user's home directory.  
D. Open the /var/spool/sudoers file with visudo.  

# Fragen

4. Which one of the following represents security best practice?

A. Always give the root user password to all users who need to perform administrative tasks.  
B. Always give full sudo privileges to all users who need to perform administrative tasks.  
C. Always just give specific, limited sudo privileges to all users who need to perform administrative tasks.  
D. Always edit the sudoers file in a normal text editor, such as nano, vim, or emacs.  

# Fragen

5. Which of the following statements is true?

A. sudo can only be used on Linux.  
B. sudo can be used on Linux, Unix, and BSD operating systems.  
C. When a user performs a task using sudo, the task does not get recorded in a security log.  
D. When using sudo, users must enter the root user password.  

# Fragen

6. You want specific users to edit a specific system configuration file, but you don't want them to use a shell escape that would allow them to perform other administrative tasks. Which of the following would you do?

A. In the sudoers file, specify that the users can only use vim to open a specific configuration file.  
B. In the sudoers file, specify that the users can use sudoedit to edit a specific configuration file.  
C. In the sudoers file, specify the no shell escape option for these users.  
D. In the sudoers file, place these users into a group that does not have shell escape privileges.  

# Lösungen

1. C
2. D
3. B
4. C
5. B
6. B

# Fragen

1. In which file would you configure complex password criteria?

# Fragen

2. When using the useradd utility on a RHEL 7-type machine, what should the UMASK setting be in the /etc/login.defs file?

# Fragen

3. When using the adduser utility on an Ubuntu 20.04 machine, how would you configure the /etc/adduser.conf file so that new users’ home directories will prevent other users from accessing them?

# Fragen

4. What change did the National Institute for Standards and Technology recently make to its recommended password policy?

# Fragen

5. Which three of the following utilities can you use to set user account expiry data?

A. Useradd  
B. Adduser  
C. Usermod  
D. chage  

# Fragen

6. Why might you want to lock out the user account of a former employee, rather than delete it?

A. It’s easier to lock an account than it is to delete it.  
B. It takes too long to delete an account.  
C. It’s not possible to delete a user account.  
D. Deleting a user account, along with the users’ files and mail spool, might get you into trouble with the law.  

# Fragen

7. You’ve just created a user account for Samson, and you now want to force him to change his password the first time he logs in. Which two of the following commands will do that?

A. sudo chage -d 0 samson  
B. sudo passwd -d 0 samson  
C. sudo chage -e samson  
D. sudo passwd -e samson  

# Fragen

8. Which one of the following is an advantage that the adduser utility has over the traditional useradd utility?

A. adduser can be used in shell scripts.  
B. adduser is available for all Linux distributions.  
C. adduser has an option that allows you to encrypt a user’s home directory as you create the user account.  
D. adduser is also available for Unix and BSD.  

# Fragen

9. In the newest Linux distributions, what is the name of the PAM module that you can use to enforce strong passwords?

A. cracklib  
B. passwords  
C. Secure  
D. pwquality  

# Lösungen

1. /etc/security/pwquality.conf
2. 077
3. Change the DIR_MODE= value to DIR_MODE=750
4. They abandoned their old philosophy about password complexity and password expirations.
5. A, C, D
6. D
7. A, D
8. C
9. D

# Zusammenfassung

Was hast du in diesem Abschnitt gelernt?

<!-- TOC -->
* [Gefahren bei Nutzung des ```root```-Users](#gefahren-bei-nutzung-des-root-users)
* [```sudo```-Privilegien einrichten](#sudo-privilegien-für-administrative-user-einrichten)
* [Weitere Tipps und Tricks zur Verwendung von ```sudo```](#weitere-tipps-und-tricks-zur-verwendung-von-sudo)
* [Home-Verzeichnisse sperren](#home-verzeichnisse-sperren---redhat)
* [Durchsetzen starker Passwort-Kriterien](#durchsetzen-starker-passwort-kriterien)
* [Verhindern von Brute-Force-Kennwortangriffen](#verhindern-von-brute-force-kennwortangriffen)
* [Sperren von Benutzerkonten](#sperren-von-benutzerkonten)
* [Sicherheits-Banner einrichten](#sicherheits-banner-einrichten)
* [Erkennung kompromittierter Passwörter](#erkennung-kompromittierter-passwörter)
<!-- TOC -->
