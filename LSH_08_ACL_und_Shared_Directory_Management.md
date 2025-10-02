---
title: "ACL und Shared Directory Management ![LSH](images/linux_security_hardening_logo.png){width=20 height=20}"
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
* [Zugriffskontrolllisten (ACL)](#zugriffskontrolllisten-acl)
* [Shared Directory Management](#shared-directory-management)
* [Setzen von SGID und Sticky-Bit](#setzen-von-sgid-und-sticky-bit)
* [Mit ACL nur bestimmten Usern Zugriff erlauben](#mit-acl-nur-bestimmten-usern-zugriff-erlauben)
<!-- TOC -->

# Zugriffskontrolllisten (ACL)

- normale Rechte für User, Gruppe, Welt sind okay, aber oft nicht ausreichend
- dafür gibt es ACL = Access Control List
- so kann man feiner definieren welcher Prinzipal welches Recht hat
- eine Datei/Ordner kann mehr als einen ACL-Eintrag haben

# Erstellung von ACLs

Berechtigungen auf bestehendem Element ändern:
```bash
chmod 600 acl_demo.txt
```

ACL anzeigen:
```bash
getfacl [DATEI_ODER_ORDNER]
```
- funktioniert **nicht** für Listen, wie mit ```ls -l```

# Erstellung von ACLs

ACL erstellen:
```bash
setfacl -m u:maria:r acl_demo.txt
setfacl -m g:sales:rw acl_demo.txt
```

Prüfung:
```bash
ls -l acl_demo.txt
```
- zeigt hinter Permission-String ein ```.``` an, wenn keine ACL vorhanden sind
- und ein ```+```, falls ACL existieren
- damit ist klar, die Datei hat ACLs
- Details zu den ACLs erhalten wir über ```getfacl```

# Erstellung von vererbten ACLs

- man will, dass alle Elemente in einem Ordner die gleichen Rechte haben, wie der Ordner selbst
- klappt nur, wenn alle Elemente im Ordner mit 600-Berechtigung erstellt werden
  - weil sonst der Standard 755-Berechtigung ist
  - damit wären ACL *sinnlos*

# Erstellung von vererbten ACLs

Beispiel:

```bash
mkdir vererbte_acl_demo
chmod 700 vererbte_acl_demo/
setfacl -m d:u:frank:r vererbte_acl_demo
ls -ld vererbte_acl_demo
getfacl vererbte_acl_demo
```
- Option ```d``` setzt ACL auf Verzeichnis

```bash
cd vererbte_acl_demo
touch datei.txt
chmod 600 datei.txt
ls -l
getfacl datei.txt
```

# Rechte aus ACLs entfernen

gesamte ACL für User/Gruppe entfernen:
```bash
setfacl -x u:maria acl_demo.txt
```

bestimmte ACL für User/Gruppe entfernen:
```bash
setfacl -m m::r acl_demo.txt
```
- ```m``` setzt neue Maske
- zeigt dann zum Beispiel ```group:sales:rw-   #effective:r--```

# Verlust von ACLs verhindern

- beim Backup mit ```tar``` gehen ACL verloren
- es sei denn man verwendet die Option ```--acls```

Backup und Wiederherstellung **ohne** ACL:
```bash
tar cJvf vererbte_acl_demo.tar.xz vererbte_acl_demo
rm -rf vererbte_acl_demo/
tar xJvf vererbte_acl_demo.tar.xz
cd vererbte_acl_demo/
ls -l
```
- ```getfacl``` gar nicht notwendig, weil ```ls -l``` schon am Ende ```.``` statt ```+``` anzeigt

# Verlust von ACLs verhindern

Backup **mit** ACL:
```bash
tar cJvf vererbte_acl_demo.tar.xz vererbte_acl_demo --acls
```

ACL behalten beim Kopieren:
```bash
cp -p acl_demo.txt acl_demo_2.txt
```

# Shared Directory Management

- nachfolgend betrachten wir, wie man ACL und Sonderrechte für gemeinsam genutzte Ordner verwendet
- typisches Beispiel: Gruppen-Ordner für eine Abteilung / Team

# Gruppe anlegen und User hinzufügen

Gruppe anlegen:
```bash
sudo groupadd marketing
```

Möglichkeiten, um User zur Gruppe hinzuzufügen:

1. mit ```useradd``` neue Nutzer erstellen und gleich zur Gruppe hinzufügen
2. bestehende Nutzer mit ```usermod``` zur Gruppe hinzufügen
3. die Datei ```/etc/group``` editieren

# Gruppe anlegen und User hinzufügen

Option 1 unter Redhat:
```bash
sudo useradd -G marketing susanne
groups susanne
```

Option 1 unter Debian:
```bash
sudo useradd -m -d /home/susanne -s /bin/bash -G marketing susanne
groups susanne
```

in beiden Fällen:
```bash
sudo passwd susanne
```

# Gruppe anlegen und User hinzufügen

Option 2:
```bash
sudo usermod -a -G marketing maria
```
- Option ```-a``` verhindert, dass User bereits bestehende Gruppen **verliert**

Option 3:
```bash
# Eintrag in /etc/group
marketing:x:1005:susanne,maria,victoria,markus
# Überprüfung
groups markus
```
- einfaches hinzufügen vieler User zu einer Gruppe

# Gruppen-Ordner mit geeigneten Rechten anlegen

```bash
cd /
sudo mkdir /marketing
ls -ld marketing
# "nobody" ist Pseudo-User
sudo chown nobody:marketing marketing
sudo chmod 770 marketing
ls -ld marketing
```

# Elemente im Gruppen-Ordner erstellen

mit anderem User Datei in diesem Ordner erstellen:
```bash
su - susanne
cd /marketing
touch susanne_file.txt
ls -l
```
- Problem: Datei gehört dem User, der sie erstellt hat
- Lösung: SGID setzen

# Setzen von SGID und Sticky-Bit

Beispiel von letzter Seite funktioniert, aber es gibt zwei Probleme:

1. Dateien gehören nicht der Gruppe ```marketing```
2. jeder kann Dateien von anderen löschen

Lösung zu 1: SGID setzen
```bash
sudo chmod 2770 marketing
# oder
sudo chmod g+s marketing
```

Lösung zu 2: Sticky Bit setzen
```bash
sudo chmod 3770 marketing
# oder
sudo chmod o+t marketing
```

# Mit ACL nur bestimmten Usern Zugriff erlauben

das tut Vitoria:
```bash
echo "Diese Datei ist für meine Freundin Susi." > victorias.txt
chmod 600 victorias.txt
setfacl -m u:susanne:r victorias.txt
ls -l
getfacl victorias.txt
```
- kann Susanne/Markus/andere auf die Datei ```victorias.txt``` zugreifen?

# Fragen

1. When creating an ACL for a file in a shared directory, what must you first do to make the ACL effective?

A. Remove all normal permissions from the file for everyone except for the user.  
B. Ensure that the file has the permissions value of ```644``` set.  
C. Ensure that everyone in the group has read/write permissions for the file.  
D. Ensure that the SUID permission is set for the file.  

# Fragen

2. What is the benefit of setting the SGID permission on a shared group directory?

A. None. It's a security risk and should never be done.  
B. It prevents members of the group from deleting each other's files.  
C. It makes it so that each file that gets created within the directory will be associated with the group that's also associated with the directory.  
D. It gives anyone who accesses the directory the same privileges as the user of the directory.  

# Fragen

3. Which of the following commands would set the proper permissions for the ```marketing``` shared group directory, with the SGID and sticky bit set?

A. ```sudo chmod 6770 marketing```  
B. ```sudo chmod 3770 marketing```  
C. ```sudo chmod 2770 marketing```  
D. ```sudo chmod 1770 marketing```  
 
# Fragen

4. Which of the following ```setfacl``` options would you use to just remove one specific permission from an ACL?

A. ```-x```  
B. ```-r```  
C. ```-w```  
D. ```m: :```  
E. ```-m```  
F. ```x: :```  

# Fragen

5. Which of the following statements is true?

A. When using ```.tar```, you must use the ```--acls``` option for both archive creation and extraction, in order to preserve the ACLs on the archived files.  
B. When using ```.tar```, you need to use the ```--acls``` option only for archive creation in order to preserve the ACLs on the archived files.  
C. When using ```.tar```, ACLs are automatically preserved on archived files.  
D. When using ```.tar```, it's not possible to preserve ACLs on archived files.  

# Fragen

6. Which two of the following are not a valid method for adding the user Lionel to the ```sales``` group?

A. ```sudo useradd -g sales lionel```  
B. ```sudo useradd -G sales lionel```  
C. ```sudo usermod -g sales lionel```  
D. ```sudo usermod -G sales lionel```  
E. By hand-editing the ```/etc/group``` file  

# Fragen

7. What happens when you create an inherited ACL?

A. Every file that gets created in the directory with that inherited ACL will be associated with the group that's associated with that directory.  
B. Every file that gets created in the directory with that inherited ACL will inherit that ACL.  
C. Every file that gets created in that directory with that inherited ACL will have the same permissions settings as the directory.  
D. Every file that gets created in that directory will have the sticky bit set.  

# Fragen

8. Which of the following commands would you use to grant read-only privilege on a file to the user Frank?

A. ```chattr -m u:frank:r somefile.txt```  
B. ```aclmod -m u:frank:r somefile.txt```  
C. ```getfacl -m u:frank:r somefile.txt```  
D. ```setfacl -m u:frank:r somefile.txt```  

# Fragen

9. You've just done an ```ls -l``` command in a shared group directory. How can you tell from that whether an ACL has been set for any of the files?

A. Files with an ACL set will have ```+``` at the beginning of the permissions settings.  
B. Files with an ACL set will have ```-``` at the beginning of the permissions settings.  
C. Files with an ACL set will have ```+``` at the end of the permissions settings.  
D. Files with an ACL set will have ```-``` at the end of the permissions settings.  
E. The ```ls -l``` command will show the ACL for that file.  

# Fragen

10. Which of the following would you use to view the ACL on the ```somefile.txt``` file?

A. ```getfacl somefile.txt```  
B. ```ls -l somefile.txt```  
C. ```ls -a somefile.txt```  
D. ```viewacl somefile.txt```  

# Antworten

1. A
2. C
3. B
4. D
5. A
6. A, C
7. B
8. D
9. C
10. A

# Zusammenfassung

Was hast du in diesem Abschnitt gelernt?

<!-- TOC -->
* [Zugriffskontrolllisten (ACL)](#zugriffskontrolllisten-acl)
* [Shared Directory Management](#shared-directory-management)
* [Setzen von SGID und Sticky-Bit](#setzen-von-sgid-und-sticky-bit)
* [Mit ACL nur bestimmten Usern Zugriff erlauben](#mit-acl-nur-bestimmten-usern-zugriff-erlauben)
<!-- TOC -->
