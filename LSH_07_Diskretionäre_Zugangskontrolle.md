---
title: "Diskretionäre Zugriffskontrolle (DAC) ![LSH](images/linux_security_hardening_logo.png){width=20 height=20}"
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
* [Verschiedene Modelle für die Zugriffskontrolle](#verschiedene-modelle-für-die-zugriffskontrolle)
* [Zugriffskontrolle unter Linux](#zugriffskontrolle-unter-linux)
* [Zugriffskontrollliste (ACL)](#zugriffskontrollliste-acl)
* [Berechtigungen von Dateien und Ordnern ändern](#berechtigungen-von-dateien-und-ordnern-ändern)
* [Vererbung von Besitztum und Rechten](#vererbung-von-besitztum-und-rechten)
* [Schutz sensibler Dateien und Ordner](#schutz-sensibler-dateien-und-ordner)
<!-- TOC -->

# Verschiedene Modelle für die Zugriffskontrolle

- regeln den Zugriff auf Ressourcen
- wie Dateien, Ordner, Drucker, ...
- betrachten wir auf den folgenden Seiten zunächst theoretisch und dann praktisch

# Modell 1: Discretionary Access Control (DAC) 

= [diskretionäre Zugriffskontrolle](https://de.wikipedia.org/wiki/Discretionary_Access_Control)

- Benutzer entscheiden über Zugriff auf ihre eigenen Ressourcen
- Zugriffsrechte für (Daten-)Objekte werden pro Benutzer festgelegt
- tendenziell weniger sicher, da es von Benutzern selbst verwaltet wird

# Modell 2: Role Based Access Control (RBAC)

= [rollenbasierte Zugriffskontrolle](https://de.wikipedia.org/wiki/Role_Based_Access_Control)

- Rollen können über Rechte auf Ressourcen zugreifen
- Benutzer werden Rollen zugeordnet und erhalten so Zugriff auf Ressourcen
- RBAC zur Verwaltung von Benutzerrechten weitgehend als bestes Verfahren angesehen
- Verwendung in Kubernetes, Active Directory, SELinux, Postgres, ...

# Modell 3: Mandatory Access Control (MAC)

= [obligatorische Zugangskontrolle](https://de.wikipedia.org/wiki/Mandatory_Access_Control)

- Zugriff basiert auf Sicherheitsklassifikationen und -freigaben
- Entscheidung über Zugriffsberechtigung nicht nur mit User-Identität (Benutzer, Prozess) und Ressource getroffen
- sondern zusätzlich mit Regeln und Eigenschaften, wie Kategorien, Labels, Codes
- komplexer durch Einbeziehung von IT-Systemen und Anwendungsprogrammen
- vor allem in sensiblen Bereichen verwendet, wie Militär und Behörden

# Zugriffskontrolle unter Linux

was das für Linux-Systeme bedeutet:

- User- und Gruppen-Verwaltung basiert allgemein auf DAC und RBAC
- sowie ACLs (Access Control List)
- viele Distributionen implementieren auch MAC-Konzepte mithilfe von
  - SELinux (Redhat) 
  - und AppArmor (Debian)

# Zugriffskontrollliste (ACL)

- ACL sind feiner einstellbar als Zugriffsrechte für Eigentümer, Gruppe, Rest der Welt
- unter Linux unterstützen Dateisysteme Btrfs, ext2/3/4, JFS, XFS und ReiserFS vollständig ACLs

# Berechtigungen

für Eigentümer, Gruppe und Welt existieren nachstehende Zugriffsrechte:

| Recht   | oktal | Bedeutung                                     |
|---------|-------|-----------------------------------------------|
| read    | 4     | Lesen                                         |
| write   | 2     | Schreiben (Anlegen, Modifizieren, Löschen)    |
| execute | 1     | Ausführen (Dateien) / Durchschreiten (Ordner) |

# Berechtigungen von Dateien und Ordnern ändern

```bash
chmod 664 datei
chmod u=rw,g=rw,o=r datei
```

# Besitzer von Dateien und Ordnern ändern

```bash
chgrp gruppe datei
chown anton:gruppe datei
```

# Vererbung von Besitztum und Rechten

1. **Besitzer und Gruppe**:
  - Besitzer von einer Datei oder eines Ordners wird vom Ersteller übernommen
  - Gruppe wird standardmäßig vom übergeordneten Verzeichnis übernommen
2. **Standard-Berechtigungen**:
  - Dateien werden mit ```666``` erstellt
  - Ordner werden mit ```777``` erstellt 
  - die ```umask``` subtrahiert jeweils davon
3. **Anpassungen**:
  - Besitzer kann Berechtigungen und Eigentümer mit `chmod` und `chown` ändern
  - Änderungen am Ordner betreffen nicht die Dateien darin
  - es sei denn, sie werden rekursiv durchgeführt

# Effektive Berechtigungen

- sie ergeben sich für User aus individuellen, Gruppen- und anderen Berechtigungen
- sowie möglichen zusätzlichen Berechtigungen durch Access Control Lists (ACLs) oder anderen Sicherheitsmechanismen

# Sicherheitsmechanismen

- auf den nachfolgenden Seiten betrachten wir einige Sicherheitsmechanismen unter Linux im Detail
- und auch die nächsten Abschnitte erweitern und vertiefen das Thema Zugriffskontrolle

# Verwendung von SUID, SGID und Sticky Bit

neben üblichen Rechten (rwx) für User und Gruppen existieren besondere Rechte

1. SUID (Set User ID)
  - Programm mit Rechten des Besitzers ausführen
  - nützlich, wenn Programm spezielle Rechte benötigt
  - gutes Beispiel ist ```passwd```
2. SGID (Set Group ID)
   - wie SUID, aber für Gruppe
   - Dateien erben Gruppe des Ordners
3. Sticky Bit
   - nur Ersteller kann Datei löschen
   - gutes Beispiel ist ```/tmp```-Verzeichnis

# Verwendung von SUID, SGID und Sticky Bit

Buchstaben-Notation:

- SUID gesetzt: ```rwsr-xr-x```
- SGID gesetzt: ```rwxr-sr-x``` 
- Sticky Bit gesetzt: ```rwxr-xr-t```  

oktale Notation:

- ohne = 0
- Sticky = 1
- SGID = 2
- SUID = 4
- Kombination = Summe der jeweiligen Werte

# Verwendung von SUID, SGID und Sticky Bit

SUID setzen:
```bash
chmod u+s [FILE_FOLDER]
```

SGID setzen:
```bash
chmod g+s [FILE_FOLDER]
```

Sticky-Bit setzen:
```bash
chmod o+t [FILE_FOLDER]
```

# Wo es zum Beispiel in Linux eingesetzt wird

```bash
ll /usr/bin/passwd
```

# Beispiel für Einsatz: Gruppen-Ordner

Teil 1:

- Gruppe *sales* anlegen: ```groupadd sales```
- User *juergen* anlegen: ```useradd juergen```
- *juergen* zu *sales* hinzufügen: ```usermod -aG sales juergen```
- Ordner *salesFolder* anlegen: ```mkdir /salesFolder```
- Rechte von *salesFolder* anzeigen: ```ll -d /salesFolder```
- Gruppe für *salesFolder* auf *sales* setzen: ```chown nobody:sales /salesFolder```
- Rechte von *salesFolder* anzeigen: ```ll -d /salesFolder```

# Beispiel für Einsatz: Gruppen-Ordner

Fortsetzung:

- nur der Gruppe *sales* alle Rechte auf dem *salesFolder* geben: ```chmod 070 /salesFolder```
- *juergen* legt Datei in *salesFolder* an: ```cd salesFolder && touch juergensDatei```
- Rechte von *salesFolder* anzeigen: ```ll```
- SGID setzen für *salesFolder*: ```chmod g+s /salesFolder```
- *juergen* legt Datei in *salesFolder* an: ```cd salesFolder && touch juergensDatei2```
- Rechte von *salesFolder* anzeigen: ```ll```
- Sticky Bit setzen für *salesFolder*: ```chmod o+t /salesFolder```

# Dateien mit SUID und SGID finden

weil SUID und SGID ein Sicherheitsrisiko darstellen, ist es sinnvoll nach deren Vorkommen zu suchen

```bash
sudo find / -type f \( -perm -4000 -o -perm -2000 \) > suid_sgid.txt
# alternativ mit Parameter
sudo find / -type f \( -perm -4000 -o -perm -2000 \) -ls > suid_sgid.txt
# alternativ 4000 und 2000 zusammenfassen
sudo find / -type f -perm /6000 -ls > suid_sgid.txt
# Vergleich verschiedener Versionen vom Ergebnis
diff suid_sgid.txt suid_sgid_old.txt
```

# Verwendung von SUID und SGID auf Partition verbieten

dafür kann man die Option ```nosuid``` in ```fstab``` verwenden

- aber bitte **nicht** auf Partition ```/```
- **sondern** nur auf ```/home/```
- sonst funktioniert das System nicht ordnungsgemäß
- Details in der [mount Man-Page](https://linux.die.net/man/8/mount)

# Schutz sensibler Dateien und Ordner

wichtige Dateien/Ordner für extra Schutz:

- ```/bin```, ```/sbin```, ```/usr/bin```, ```/usr/local/bin```
- ```/etc/passwd```, ```/etc/shadow```, ```/etc/group```, ```/etc/gshadow```
- ```/etc/pam.d```
- ```/etc/profile```, ```~/.bash_profile```, ```~/.bash_login```, ```~/.profile```, ```/home/tux/.bashrc```, ```/etc/bash.bashrc```, ```/etc/profile.d/```
- ```/proc/cmdline```
- ```/etc/rc.*```, ```/etc/init.*```
- Konfigurations-Dateien von wichtigen Diensten auf einem Server

# Option 1: Mit grundlegenden Berechtigungen schützen

- viele Server sind physisch abgesichert
- aber bei IoT-Geräten sieht es meist anders aus
- beide haben aber gemeinsam, dass sie viele Dateien für "Welt" als lesbar zur Verfügung stellen
- also lohnt sich Änderung der Berechtigungen in Betracht zu ziehen

mögliches Vorgehen:
```bash
# Berechtigungen anzeigen:
sudo find / -iname '*.conf' -exec ls -l {} \;
# Berechtigungen ändern:
sudo find / -iname '*.conf' -exec chmod 600 {} \;
```

# Option 2: Mit erweiterten Attributen schützen

genutzte Utilities:

- [lsattr/chattr](https://en.wikipedia.org/wiki/Chattr) zum Anzeigen und ändern von Attributen für Dateien

Wichtige, mögliche Dateiattribute:

| Flag | Bedeutung       |
|------|-----------------|
| i    | immutable       |
| u    | undeleteable    |
| s    | secure deletion |
| a    | append only     |
| d    | no dump         |

- hier findet man die [vollständige Liste](https://manned.org/chattr)

# Verwendung von ```lsattr``` und ```chattr```

Datei-Attribute anzeigen:
```bash
lsattr [ -RVadv ] [ files...  ]
```
- ```R``` = listet rekursiv Attribute von Ordnern und deren Inhalt
- ```V``` = zeigt Programmversion an
- ```a``` = listet alle Dateien in Ordnern, einschließlich Punktdateien auf
- ```d``` = listet Ordner wie andere Dateien auf, anstatt Inhalt aufzulisten

# Verwendung von ```lsattr``` und ```chattr```

Datei-Attribute ändern:
```bash
chattr [-RVf] [-+=AacDdijsTtSu] [-v version] files...
```
- ```R``` = rekursiv Attribute von Ordnern und deren Inhalt ändern
- ```V``` = soll ausführlich sein und die Programmversion ausgeben
- ```f``` = unterdrückt die meisten Fehlermeldungen
- ```+``` = Option hinzufügen
- ```-``` = Option entfernen

# Beispiel für ```lsattr``` und ```chattr```

```bash
echo "etwas Text" > attr_demo.txt
lsattr attr_demo.txt
sudo chattr +a attr_demo.txt
sudo chattr +u attr_demo.txt
lsattr attr_demo.txt
echo "Ich will die Datei überschreiben." > attr_demo.txt
rm attr_demo.txt
sudo chattr -a attr_demo.txt
sudo chattr -u attr_demo.txt
echo "Ich will die Datei überschreiben." > attr_demo.txt
rm attr_demo.txt
```

# Fragen

1. Which of the following partition mount options would prevent setting the SUID and SGID permissions on files?

A. ```nosgid```  
B. ```noexec```  
C. ```nosuid```  
D. ```nouser```  

# Fragen

2. Which of the following represents a file with read and write permissions for the user and the group, and read-only permissions for others?

A. ```775```  
B. ```554```  
C. ```660```  
D. ```664```  

# Fragen

3. You want to change the ownership and group association of the ```somefile.txt``` file to Maggie. Which of the following commands would do that?

A. ```sudo chown maggie somefile.txt```  
B. ```sudo chown :maggie somefile.txt```  
C. ```sudo chown maggie: somefile.txt```  
D. ```sudo chown :maggie: somefile.txt```  

# Fragen

4. Which of the following is the numerical value for the SGID permission?

A. ```6000```  
B. ```2000```  
C. ```4000```  
D. ```1000```  

# Fragen

5. Which command would you use to view the extended attributes of a file?

A. ```lsattr```  
B. ```ls -a```  
C. ```ls -l```  
D. ```chattr```  

# Fragen

6. Which of the following commands would search through the entire filesystem for regular files that have either the SUID or SGID permission set?

A. ```sudo find / -type f -perm \6000```  
B. ```sudo find / \( -perm -4000 -o -perm -2000 \)```  
C. ```sudo find / -type f -perm -6000```  
D. ```sudo find / -type r -perm \6000```  

# Fragen

7. Which of the following statements is true?

A. Using the symbolic method to set permissions is the best method for all cases.  
B. Using the symbolic method to set permissions is the best method to use in shell scripting.  
C. Using the numeric method to set permissions is the best method to use in shell scripting.  
D. It doesn't matter which method you use to set permissions.  

# Fragen

8. Which of the following commands would set the SUID permission on a file that has read/write/execute permissions for the user and group, and read/execute permissions for others?

A. ```sudo chmod 2775 somefile```  
B. ```sudo chown 2775 somefile```  
C. ```sudo chmod 1775 somefile```  
D. ```sudo chmod 4775 somefile```  

# Fragen

9. Which of the following functions is served by setting the SUID permission on an executable file?

A. It allows any user to use that file.  
B. It prevents accidental erasure of the file.  
C. It allows "others" to have the same privileges as the "user" of the file.  
D. It allows "others" to have the same privileges as the group that's associated with the file.  

# Fragen

10. Why shouldn't users set the SUID or SGID permissions on their own regular files?

A. It unnecessarily uses more hard drive space.  
B. It could prevent someone from deleting the files if needed.  
C. It could allow someone to alter the files.  
D. It could allow an intruder to compromise the system.  

# Fragen

11. Which of the following ```find``` command options allows you to automatically perform a command on each file that ```find``` finds, without being prompted?

A. ```-exec```  
B. ```-ok```  
C. ```-xargs```  
D. ```-do```  

# Fragen

12. For the best security, always use the ```600``` permission setting for every ```.conf``` file on the system.

A. True  
B. False  

# Fragen

13. Which of the following is a true statement?

A. Prevent users from setting SUID on files by mounting the ```/``` partition with the ```nosuid``` option.  
B. You must have the SUID permission set on certain system files for the operating system to function properly.  
C. Executable files must never have the SUID permissions set.  
D. Executable files should always have the SUID permission set.  

# Fragen

14. Which two of the following are security concerns for configuration files?

A. With a default configuration, any normal user with command-line access can edit configuration files.  
B. Certain configuration files may contain sensitive information.  
C. With a default configuration, any normal user with command-line access can view configuration files.  
D. The configuration files on servers require more protection than the configuration files on IoT devices.  

# Antworten

1. C
2. D
3. C
4. B
5. A
6. A
7. C
8. D
9. C
10. D
11. A
12. B. Some configuration files, such as the ```/etc/resolv.conf``` file, have to be world-readable for the system to function properly.
13. B
14. B, C

# Zusammenfassung

Was hast du in diesem Abschnitt gelernt?

<!-- TOC -->
* [Verschiedene Modelle für die Zugriffskontrolle](#verschiedene-modelle-für-die-zugriffskontrolle)
* [Zugriffskontrolle unter Linux](#zugriffskontrolle-unter-linux)
* [Zugriffskontrollliste (ACL)](#zugriffskontrollliste-acl)
* [Berechtigungen von Dateien und Ordnern ändern](#berechtigungen-von-dateien-und-ordnern-ändern)
* [Vererbung von Besitztum und Rechten](#vererbung-von-besitztum-und-rechten)
* [Schutz sensibler Dateien und Ordner](#schutz-sensibler-dateien-und-ordner)
<!-- TOC -->
