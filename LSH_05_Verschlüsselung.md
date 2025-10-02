---
title: "Verschlüsselung ![LSH](images/linux_security_hardening_logo.png){width=20 height=20}"
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
* [GNU Privacy Guard](#gnu-privacy-guard)
* [Verschlüsselung unter Linux](#verschlüsselung-unter-linux)
* [Partitionen verschlüsseln mit Linux Unified Key Setup - LUKS](#partitionen-verschlüsseln-mit-linux-unified-key-setup---luks)
* [Verzeichnisse mit ```ecryptfs``` verschlüsseln](#verzeichnisse-mit-ecryptfs-verschlüsseln)
* [Mit VeraCrypt verschlüsselte Container freigeben](#mit-veracrypt-verschlüsselte-container-freigeben-)
<!-- TOC -->

# GNU Privacy Guard

kurze Historie & Zusammenhang:

- 1991 wurde [PGP](https://de.wikipedia.org/wiki/Pretty_Good_Privacy) entwickelt
- 1998 entstand Standard OpenPGP, weil PGP patentierte Algorithmen enthielt und kommerziell wurde
- 1997 ist GnuPG entstanden, das OpenPGP implementiert
  - standardmäßig nur patentfreie Algorithmen und unter GNU-GPL vertrieben

# GnuPG

- [GNU Privacy Guard](https://de.wikipedia.org/wiki/GNU_Privacy_Guard) wird oft abgekürzt mit GnuPG oder GPG
- ein freies Kryptografiesystem
- zum Ver- und Entschlüsseln von Daten
- und zum Erzeugen und Prüfen elektronischer Signaturen

## Nutzung über ```gpg``` oder ```gpg2```

# Warum GPG relevant ist

- Schutz von Infrastruktur, Daten, etc.
- mit öffentlichem Schlüssel
- mit privatem Schlüssel
- mit Signatur
- mit Fingerabdruck

# GPG Anwendungsfall

Ziel: Schutz vor manipulierten Downloads

Variante 1:

- Download 1 Datei von 1 Server = könnte manipuliert sein

Variante 2:

- Download je 1 Datei von 3 Servern
- Dateien vergleichen = etwas sicherer, das nicht manipuliert wurde
- Nachteile: mehr Server, Bandbreite, Speicher, Aufwand nötig

Variante 3:

- Download 1 (große) Datei von 1 Server
- mehrere kleine Dateien (Schlüssel, Prüfsumme) herunterladen zum Prüfen des Downloads

# GPG verstehen

- GPG verwendet **asymmetrische** Funktionen zur Erstellung von Schlüsseln

**symmetrische** Funktion
: zum Beispiel Addition, Subtraktion
: ```4 + 2 = 6``` > ```6 - 2 = 4```

**asymmetrische** Funktion
: zum Beispiel Multiplikation von Primzahlen
: ```97 * 61 = 5917``` > ```5917 / 2``` → falsch, ```5917 / 3``` → falsch, ```5917 / 5``` → falsch, ...

# Öffentliche und private Schlüssel

- GPG ist ein Public Key-Verschlüsselungsverfahren
- zur Verschlüsselung sind keine geheimen Informationen notwendig
- es werden Schlüsselpaare verwendet

privater Schlüssel
: Zugriff nur vom Eigentümer
: mit Passwort/Phrase geschützt
: zum ver- und entschlüsseln

öffentlicher Schlüssel
: muss jedem Kommunikationspartner zur Verfügung stehen
: dient zur Verschlüsselung und Überprüfung signierter Dateien
: damit kann **nicht** entschlüsselt oder signiert werden
: kann über viele Kanäle ausgetauscht werden

# GPG Schlüssel erstellen

- GPG ist auf den meisten Distros schon installiert, weil es vom System selbst verwendet wird

Installation:
```bash
# Debian:
sudo apt install gpg
# Redhat:
sudo dnf install gnupg
sudo dnf install pinentry
```

Version prüfen:
```bash
gpg --version
```

Schlüsselpaar erstellen:
```bash
gpg --full-generate-key
gpg --full-gen-key
```
- dazu die Prompts beantworten (Art des Schlüssels, Schlüsselgröße, Gültigkeit, Name, E-Mail, etc.)

# GPG Schlüssel ansehen

öffentlichen Schlüssel ansehen:
```bash
gpg --list-keys
```

privaten Schlüssel ansehen:
```bash
gpg --list-secret-keys
```

- beide zeigen den gleichen Fingerabdruck

# GPG Schlüssel extrahieren

privaten Schlüssel extrahieren:
```bash
gpg --output private.gpg --armor --export-secret-key your@mail.org
cat private.gpg
```

öffentlichen Schlüssel extrahieren:
```bash
gpg --output public.gpg --armor --export your@mail.org
cat public.gpg
```

- haben jeweils ```BEGIN / END PGP PUBLIC / PRIVATE KEY BLOCK```

# Mit GPG signieren

Datei signieren:
```bash
echo "Mein geheimer Text" > datei.txt
gpg --detach-sign --armor datei.txt
ls -l
```
- dadurch entsteht Signatur-Datei ```datei.txt.asc```
- haben ```BEGIN / END PGP SIGNATURE```

# Mit GPG signierte Datei prüfen

signierte Datei prüfen:
```bash
gpg --verify datei.txt.asc
# kurze Form
gpg -v datei.txt.asc
ls -l
```
- Ausgabe zeigt Fingerabdruck und ob es **Good/BAD signature** ist

Manipulation simulieren:

1. Inhalt der signierten Datei ändern → siehe vorherige Seite
2. signierte Datei prüfen → siehe oben

# GPG-Schlüssel löschen

Schlüssel löschen:
```bash
gpg --delete-secret-key your@mail.org
```

Schlüssel löschen:
```bash
gpg --delete-key your@mail.org
```

Schlüssel anzeigen:
```bash
gpg --list-keys
gpg --list-secret-keys
```

# Mit GPG verschlüsseln

Datei verschlüsseln (encrypt):
```bash
gpg -r empfaenger@email.org -e datei.txt
```
- standardmäßig wird am Dateinamen ein ```.gpg``` angehängt

# Mit GPG entschlüsseln

Datei entschlüsseln (decrypt):
```bash
## auf der Konsole anzeigen
gpg -d datei.txt.gpg
## oder wieder in eine Datei schreiben
gpg -d datei.txt.gpg > datei.txt
```
- Passwort für Entschlüsselung wird dann für bestimmten Zeitraum nicht mehr abgefragt

# Öffentliche Schlüssel importieren

wenn die Schlüssel-Datei lokal vorliegt:
```bash
gpg --import dce3823597f5eac4.txt
# dann den Fingerprint anzeigen lassen, um mit Quelle zu vergleichen:
gpg --fingerprint
```

Schlüssel von einem Schlüssel-Server beziehen:
```bash
gpg --keyserver keyserver --receive-keys key_ID
# konkretes Beispiel:
gpg --keyserver hkps://keyring.debian.org:443 --recv-keys 0x2404C9546E145360
```

Schlüssel auf Schlüssel-Server suchen:
```bash
gpg --keyserver keyserver --search-keys string_to_match
```

# Verschlüsselung unter Linux

Welche Ebene kann man auf Linux-Systemen verschlüsseln?

- Blöcke = ganze Platte oder einzelne Partition(-en)
- Dateien = wenn zum Beispiel nicht das ganze System verschlüsselt ist oder Dateien ausgetauscht werden
- Container = verwendet Extra-Software, die plattformübergreifend arbeiten kann (Linux, Mac, Windows)

# Überblick über Speichermedien erhalten

```bash
sudo pvdisplay
sudo lvdisplay
sudo lsblk -fit
sudo blkid
```

# Bemerkungen zu LUKS

- kann Platten und Partitionen verschlüsseln
- meist kann damit auch bei Installation direkt Verschlüsselung ausgewählt werden
  - nur HOME
  - oder ganze Platte etc.

# Installation

- ist auf vielen gängigen Distributionen vorinstalliert
- auf Debian oft schon installiert
- unter Redhat kann man es auf offiziellen Quellen installieren

Vorgehen:
```bash
sudo dnf install cryptsetup
```
- Eingabe von ```cryptsetup``` zeigt knappe Hilfe an
- Eingabe von ```cryptsetup --help``` zeigt ausführliche Hilfe an

# Partitionen verschlüsseln mit Linux Unified Key Setup - LUKS

- funktioniert wie das Einbinden von Storage auch sonst
- aber es kommt ein Extra-Layer hinzu (Mapper)

wichtige Befehle:

1. ```cryptsetup luksFormat``` = verschlüsselte Partition erstellen
2. ```cryptsetup open``` = verschlüsselte Partition öffnen
3. ```cryptsetup close``` = verschlüsselte Partition schliessen
4. ```cryptsetup luksChangeKey``` = Schlüssel ändern

# Mounten von Speicher **ohne** Verschlüsselung

folgende Punkte zeigen die Schritte zur (dauerhaften) Einbindung von Speichermedien auf Debian-basierten Systemen

1. Blockgeräte anzeigen
```bash
lsblk
sudo fdisk -l
```

2. Gerätedatei anzeigen
```bash
ls -l /dev/sdb
ls -l /dev/sdb1
```

# Mounten von Speicher **ohne** Verschlüsselung

3. Speichergerät aushängen
```bash
umount /dev/[DEVICE_NAME]
# oder
umount /mnt/[MOUNT_PATH]
```

4. alle eingehängten Speichermedien auflisten
```bash
mount
```

# Mounten von Speicher **ohne** Verschlüsselung

5. bestimmtes eingehängtes Speichergerät auflisten
```bash
mount | grep sdb
```

6. Partitionstabelle und Partition auf dem Speichermedium erstellen
```bash
sudo fdisk /dev/sdb
```
- m → Hilfe erhalten
- g → GPT-Partitionstabelle erstellen
- p → Partitionen auflisten
- n → neue Partition erstellen und durch den Prozess geführt werden
- w → schreiben = macht Änderungen endgültig

# Mounten von Speicher **ohne** Verschlüsselung

7. Dateisystem auf dieser Partition erstellen
```bash
sudo mkfs.ext4 /dev/sdb1
# oder
sudo mkfs.ext4 -n "gerät_label" /dev/sdb1
```

8. Gerät einhängen
```bash
sudo mkdir /mnt/disk1
sudo mount /dev/sdb1 /mnt/disk1/
```

9. Überprüfen mit df
```bash
df -h → sollte nun das Gerät auflisten
```

# Mounten von Speicher **ohne** Verschlüsselung

10. Backup von ```fstab``` anlegen
```bash
sudo cp /etc/fstab /etc/fstab.backup
```

11. Gerät dauerhaft einhängen
```bash
sudo nano /etc/fstab
```

12. Geräte-UUID ermitteln
```bash
sudo blkid
```

# Mounten von Speicher **ohne** Verschlüsselung

13. neue Zeile in fstab für Device hinzufügen

Aufbau der Zeile:
```
UUID=xxx-xxx-xxx        Mountpoint	Filesystem	Optionen	0	0
```

konkretes Beispiel:
```
UUID=5918-466a-8ae3c20e /mnt/disk1	ext4		defaults	0	0
```
- Werte sind durch TAB getrennt
- Werte für die letzten drei Spalten können anders sein
- aber meist reicht ```defaults	0	0```

- dann ```fstab``` speichern mit [Ctrl] + [O]
- und ```fstab``` schliessen mit [Ctrl] + [X]

# Mounten von Speicher **ohne** Verschlüsselung

14. neuen Eintrag prüfen mit `mount -a -v`
- was alle Einträge aus `/etc/fstab` einbindet, die aktuell nicht eingebunden sind
- bei Fehlern die Datei anpassen und vorher das System **nicht** neu starten (s. nächster Punkt)

15. System neu starten

- Gerät sollte jetzt unter dem angegebenen Mount-Punkt zu finden sein

# Mounten von Speicher **mit** Verschlüsselung

Überblick:

- Vorgehen wie normales Einbinden (siehe vorheriger Abschnitt)
- zusätzlich werden die `cryptsetup`-Befehle an den richtigen Stellen ausgeführt 
- geschieht über die Extra-Ebene ```/dev/mapper```
- verschlüsselte Volumes stehen in ```/etc/crypttab```

# Mounten von Speicher **mit** Verschlüsselung

Vorgehen:

- Gerät verbinden (zum Beispiel USB-Stick, Platte in Virtualbox)
- GPT-Partitionstabelle erstellen mit ```fdisk``` oder ```gdisk```
- ```cryptsetup -v luksFormat /dev/[PARTITION]```
- ```cryptsetup luksOpen /dev/[PARTITION] [MAPPER_NAME]```
  - dann eingebunden unter ```/dev/mapper/[MAPPER_NAME]```
- Filesystem erstellen mit ```mkfs.ext4```
- Mount-Point erstellen und mounten
- aushängen (`umount`)
- ```cryptsetup luksClose [DEIN_MAPPER_NAME]```

# Mounten von Speicher **mit** Verschlüsselung

Information zur verschlüsselten Partition anzeigen:
```bash
sudo cryptsetup luksDump /dev/sdb1
cd /dev/mapper
sudo dmsetup info [MAPPER_EINTRAG]
```

# Bestehendes Medium mit Verschlüsselung verwenden

- im Prinzip werden verschlüsselte Datenträger wie normale verwendet
- es muss nur eine zusätzliche Ebene beachtet werden
- vor dem Mount ```cryptsetup open``` ausführen
- vor dem Un-Mount ```cryptsetup close``` ausführen

# Bestehendes Medium mit Verschlüsselung verwenden

Schritte:

- verschlüsseltes Device öffnen: ```sudo cryptsetup open /dev/[PARTITION] [MAPPER_NAME]```
  - Passphrase muss eingegeben werden
- Mount durchführen: ```sudo mount /dev/mapper/[MAPPER_NAME] /mnt/[MOUNT_FOLDER]```
- dann kann man mit dem Speicher arbeiten: kopieren, lesen, schreiben, etc.
- Un-Mount durchführen: ```sudo umount /dev/mapper/[MAPPER_NAME]```
- verschlüsseltes Device schliessen: ```sudo cryptsetup close [MAPPER_NAME]```

# Verzeichnisse mit ```ecryptfs``` verschlüsseln

- verfügbar unter Debian
- funktionierte früher auch auf [Redhat](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/storage_administration_guide/ch-efs)
  -  aber weiter unter [Fedora verfügbar](https://src.fedoraproject.org/rpms/ecryptfs-utils/branches?branchname=master)
- also wird dieser Abschnitt nur für Debian gezeigt

# Verzeichnisse mit ```ecryptfs``` verschlüsseln

Schritte zur Verschlüsselung mit ```ecryptfs```:

- ```sudo apt install ecryptfs-utils```
- ```sudo mkdir [ORDNER_NAME]```
- ```sudo mount -t ecryptfs [ORDNER] [MOUNT_POINT]```
  - wenn [ORDNER] = [MOUNT_POINT], dann wird der Ordner wird als sein eigener Mount-Point verwendet 
  - Prompts beantworten

# Verzeichnisse mit ```ecryptfs``` verschlüsseln

dann mit dem Verzeichnis arbeiten
```bash
echo "Das ist ein Geheimnis" > [ORDNER_NAME]/sec.txt
```
- Elemente erstellen, ändern, löschen etc.

Inhalte anzeigen:
```bash
ls -l [ORDNER_NAME]
```
- bei verschlüsselten Dateinamen werden diese nicht sichtbar sein

Ordner wieder "schliessen":
```bash
sudo umount [ORDNER_NAME]
```

# Verzeichnisse mit ```ecryptfs``` verschlüsseln

- Hilfe finden: [ecryptfs(7) - Linux man page](https://linux.die.net/man/7/ecryptfs)

## Empfehlung

- auf LUKS-verschlüsselter Platte ```ecryptfs``` **nicht** nutzen

# Mit VeraCrypt verschlüsselte Container freigeben 

- plattformübergreifend und Open Source
- bietet on-the-fly verschlüsselte Volumes und Container
- unterstützt verschiedene Verschlüsselungs-Algorithmen
- kann Festplatten, Partitionen oder Volumes verschlüsseln
- verschlüsselte Container lassen sich verstecken

Download von [veracrypt.fr](https://www.veracrypt.fr/en/Downloads.html)

# Installation von Veracrypt

Debian:
```bash
# Archiv runterladen:
wget https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-console-1.26.24-Debian-12-amd64.deb
# Signatur runterladen:
wget https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-console-1.26.24-Debian-12-amd64.deb.sig
# Public Key runterladen:
wget https://amcrypto.jp/VeraCrypt/VeraCrypt_PGP_public_key.asc
# Public Key importieren:
gpg --import VeraCrypt_PGP_public_key.asc
# Signatur prüfen:
gpg --verify veracrypt-console-1.26.24-Debian-12-amd64.deb.sig veracrypt-console-1.26.24-Debian-12-amd64.deb
# Installation ausführen:
sudo apt install ./*.deb
```
- die Verfikation von Signaturen ist auch [bei Veracryt](https://veracrypt.io/en/Digital%20Signatures.html) beschrieben
- Installation holt automatisch die notwendigen Abhängigkeiten (Fuse)

Redhat:

- Schritte sind sinngemäss die gleichen, nur eben für das `.rpm`-Paket

# Veracrypt-Volume interaktiv erstellen

- interaktive Erstellung: `veracrypt --create`
- Mount-Point erstellen: `mkdir vc-dir`
- Mount ausführen: `veracrypt --mount vc-volume vc-dir`
- Volume anzeigen: `veracrypt --list`
- jetzt ist das Volume zur Verwendung bereit
- unmount: `veracrypt --unmount vc-volume`
- danach sind die Inhalte in `vc-dir` *verschwunden* (= sicher im `vc-volume` abgelegt)

# Arbeit mit VeraCrypt

Container **wiederverwenden**:
```bash
veracrypt --mount vc-volume vc-dir
veracrypt --list
# Beispiel-Ausgabe:
# 1: /home/tux/vc-volume /dev/mapper/veracrypt1 /home/tux/vc-dir
ls -l vc-dir/
```
- nicht ganz intuitiv, aber Wiederverwendung funktioniert wie `mount` zur Erzeugung

# Arbeit mit VeraCrypt

weitere Befehle:
```bash
# Details zu Volume anzeigen
veracrypt --volume-properties
# Passwort ändern:
veracrypt --change
# komplette Hilfe ansehen:
veracrypt --help
```

# Veracrypt-Volume ohne Interaktion erstellen

```bash
veracrypt -t --create test.vc --password test --hash sha512 \
  --encryption AES --filesystem ext4 --volume-type normal \
  -k "" --pim 0 --size 10M --random-source=/dev/urandom
mkdir test_vc
veracrypt -t --mount test.vc test_vc --password test \
  --pim 0 --keyfiles "" --protect-hidden no --slot 2 \
  --verbose 
# Passwort sicher mitgeben
veracrypt -p ""
```

# Fragen

1. Which of the following is not an advantage of GPG?

A. It uses strong, hard-to-crack algorithms.  
B. It works well for sharing secrets with people you don't know.  
C. Its public/private key scheme eliminates the need to share passwords.  
D. You can use it to encrypt files that you don’t intend to share, for your own personal use.  

# Fragen

2. You need to send an encrypted message to Frank. What must you do before you can encrypt his message with GPG so that you don't have to share a password?

A. Nothing. Just encrypt the message with your own private key.  
B. Import Frank's private key into your keyring and send Frank your private key.  
C. Import Frank's public key into your keyring and send Frank your public key.  
D. Just import Frank's public key into your keyring.  
E. Just import Frank's private key into your keyring.  

# Fragen

3. Which of the following would be the proper choice for whole-disk encryption on a Linux system?

A. Bitlocker  
B. VeraCrypt  
C. eCryptfs  
D. LUKS  

# Fragen

4. If you use eCryptfs to encrypt users' home directories, and you're not using whole-disk encryption, what other action must you take in order to prevent leakage of sensitive data?

A. None.  
B. Ensure that users use strong private keys.  
C. Encrypt the swap partition.  
D. You must use eCryptfs in whole-disk mode.  

# Fragen

5. In which of the following scenarios would you use VeraCrypt?

A. Whenever you want to implement whole-disk encryption.  
B. Whenever you just want to encrypt users' home directories.  
C. Whenever you'd prefer to use a proprietary, closed source encryption system.  
D. Whenever you need to create encrypted containers that you can share with Windows, macOS, and BSD users.  

# Fragen

6. You need to ensure that your web browser trusts certificates from the Dogtag CA. How do you do it?

A. You use pki-server to export the CA certificate and key, and then use openssl pkcs12 to extract just the certificate. Then, import the certificate into your browser.  
B. You import the ca_admin.cert certificate into your browser.  
C. You import the ca_admin_cert.p12 certificate into your browser.  
D. You import the snakeoil.pem certificate into your browser.  

# Antworten

1. B
2. C
3. D
4. C
5. D
6. A

# Zusammenfassung

Was hast du in diesem Abschnitt gelernt?

<!-- TOC -->
* [GNU Privacy Guard](#gnu-privacy-guard)
* [Verschlüsselung unter Linux](#verschlüsselung-unter-linux)
* [Partitionen verschlüsseln mit Linux Unified Key Setup - LUKS](#partitionen-verschlüsseln-mit-linux-unified-key-setup---luks)
* [Verzeichnisse mit ```ecryptfs``` verschlüsseln](#verzeichnisse-mit-ecryptfs-verschlüsseln)
* [Mit VeraCrypt verschlüsselte Container freigeben](#mit-veracrypt-verschlüsselte-container-freigeben-)
<!-- TOC -->
