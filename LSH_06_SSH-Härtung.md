---
title: "SSH-Härtung ![LSH](images/linux_security_hardening_logo.png){width=20 height=20}"
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
* [SSH-Härtung](#ssh-härtung)
* [SSH-Schlüsselsatz erstellen](#ssh-schlüsselsatz-erstellen)
* [Deaktivierung von Passwort Login](#deaktivierung-von-passwort-login)
* [Logging für SSH anpassen](#logging-für-ssh-anpassen)
* [Weitere Sicherheit für SSH](#weitere-sicherheit-für-ssh)
* [Von Windows-Clients über SSH verbinden](#von-windows-clients-über-ssh-verbinden)
* [SSH-Audit für Client und Server](#ssh-audit-für-client-und-server)
* [2FA mit TOTP](#2fa-mit-totp)
<!-- TOC -->

# SSH-Härtung

- biete Bequemlichkeit remote Server zu verwalten
- wird in vielen Diensten verwendet, die darauf aufbauen: SFTP, SCP, ...
- ist aber in der Standard-Konfiguration eher unsicher
- verwendet unter Linux meist ```openssh-server``` für Server und ```openssh-client``` auf Client

# SSH-Protokoll 1 deaktivieren

Stand 2023:

- unsichere Version 1 des SSH-Protokolls ist nicht mehr in ```/etc/ssh/sshd_config``` aktiviert

Test, indem man versucht Protokoll 1 zu verwenden:
```bash
ssh -1 <server>
```
- zeigt jetzt Fehler "SSH protocol v.1 is no longer supported"

# Verbindungen über SSH

über SSH verbinden:
```bash
ssh [USER]@[HOST_ODER_IP] # verwendet Port 22
ssh -p 2222 [USER]@[HOST_ODER_IP]
```
- mehr Optionen unter ```man ssh```
- User und Passwort werden verschlüsselt übertragen
- bietet aber Einfallstor für Brute-Force-Attacken

# SSH-Schlüsselsatz erstellen

SSH-Schlüssel erstellen:
```bash
ssh-keygen
```
- man muss interaktiv einige Dinge auswählen
- Typ angeben mit `-t ecdsa | ecdsa-sk | ed25519 | ed25519-sk | rsa`
  - Standard ist RSA
  - **nie DSA** verwenden = unsicher nach modernen Standards
- sollte mit Passphrase gesichert werden
- ist immer an den Benutzer gebunden
- mit Standard-Dateinamen werden Schlüssel zum Session Keyring hinzugefügt

# SSH-Schlüsselsatz auflisten

Inhalt vom ```.ssh```-Ordner betrachten:
```bash
ls -l ~/.ssh
```
- öffentlicher und privater Schlüssel taucht in Liste auf
- öffentlicher Schlüssel ist World-readable

# SSH-Schlüssel auf Server kopieren

öffentlichen Schlüssel auf den Server kopieren:
```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub tux@192.168.122.72
```
- damit wird ab nächstem Mal die Anmeldung ohne Passwort möglich
- fragt aber nach Passphrase für SSH-Key

ggf. vorher Schlüssel zum Session Keyring hinzufügen:
```bash
exec /usr/bin/ssh-agent $SHELL
ssh-add
```
- dafür muss Passphrase eingegeben werden
- neues Terminal fragt dann nicht mehr nach Passphrase

# Weitere Punkte zu SSH-Schlüsseln

- oft reicht ein Schlüssel-Paar, um (einige) Server zu administrieren
- manchmal kann es aber ratsam sein pro Server/Zweck/Gruppe ein Schlüssel-Paar zu haben
- zum Beispiel Keys erzeugen mit Hostnamen als Filenamen

bei Verbindung Schlüssel spezifizieren:
```bash
ssh -i ~/.ssh/id_server1 [USER]@[HOST_ODER_IP]
```
- alternativ lokal einen Eintrag in `.ssh/.config` dafür definieren

# Weitere Punkte zu SSH-Schlüsseln

- wenn man für SSH-Schlüsseln nicht den vorgeschlagenen Dateinamen verwendet, dann klappt ```ssh-copy-id``` nicht
- in dem Fall Namen und Pfad mit angeben: ```ssh-copy-id -i path/to/certificate username@remote_host```
- für ```authorized_keys``` ist ggf. ```chmod 600``` notwendig, damit es funktioniert

# Deaktivierung von Passwort Login

- nach Erstellung, Transfer und Test von SSH-Keys kann die Passwort-Authentifizierung in SSH deaktiviert werden
```bash
sudo nano /etc/ssh/sshd_config
```
- **nicht** ```ssh_config``` statt ```sshd_config``` verwenden

ändern in:
```bash
PermitRootLogin no
PasswordAuthentication no
```

# Deaktivierung von Passwort Login

Änderungen werden nach Neustart des SSH-Dienstes wirksam:
```bash
sudo systemctl restart sshd
```

## wichtiger letzter Schritt vor dem Trennen der Verbindung mit dem Server

- anderen Tab öffnen und erneut über SSH verbinden (Pfeil nach oben)
- um zu überprüfen, ob man immer noch eine Verbindung herstellen kann
- also nicht versehentlich sich selbst vom Server aussperren

# Logging für SSH anpassen

Möglichkeit auf Systemen mit ```systemd```:
```bash
journalctl -u ssh
```

andere Möglichkeiten:

- unter Debian loggt SSH in ```/var/log/auth.log```
- unter Redhat loggt SSH in ```/var/log/secure```

## man kann das Log-Level für SSH anpassen in ```sshd_config``` mit `LogLevel [DEBUG]`

- mögliche Werte stehen in der [Man-Page](https://manpages.debian.org/testing/openssh-server/sshd_config.5.en.html#LogLevel)

# Weitere Sicherheit für SSH

ausgewählte Möglichkeiten:

1. in ```sshd_config```:
- White- & Blacklists erstellen
  - Deny-/AllowUsers, Deny-/AllowGroups
  - Werte müssen in Datei eingetragen werden
  - zum Beispiel ```DenyUsers frank```
- ```Banner``` festlegen
- automatischer Logout mit ```ClientAliveInterval```
2. TCP Wrapper mit ```/etc/hosts.allow``` und ```/etc/hosts.deny```
3. Firewall (siehe Kapitel dazu)

# Von Windows-Clients über SSH verbinden

zwei Möglichkeiten:

1. [Putty](https://www.putty.org/)
   - Download und Installation
   - danach Putty öffnen und mit Server/IP und Port verbinden
   - Keys können mit PuttyGen erstellt werden
2. Windows Command Prompt / Powershell
   - einfach ```cmd``` öffnen und dann mit ```ssh``` verbinden
   - Keys können mit ```ssh-keygen``` erstellt werden

## bei beiden müssen die Schlüssel manuell auf SSH-Ziel-Server in ```authorized_keys``` eingetragen werden

# SSH-Audit für Client und Server

- kann über Webseite [ssh-audit.com](https://ssh-audit.com/) erfolgen
- oder über paket `ssh-audit`
- lässt sich für Client und Server verwenden
- und gibt als Ergebnis ein Rating aus, dass die Sicherheit von SSH für das aktuelle System bewertet
- daraus resultierend kann man Verbesserung der Einstellungen auf dem Zielsystem vornehmen

Nutzung:
```bash
apt install ssh-audit
# Server auditieren:
ssh-audit localhost
# Client auditieren:
ssh-audit -c
```
- einige Harding-Guides sind [hier](https://www.ssh-audit.com/hardening_guides.html) zu finden

# 2FA mit TOTP

- funktioniert für viele Distributionen und 2FA/OTP-Tools
- hier wird **beispielhaft** das Setup **mit Debian und Google Authenticator** gezeigt

# 2FA mit TOTP: Umsetzung

1. Paket-Listen auffrischen: `sudo apt update`
2. PAM-Moduls von Google Authenticator installieren: `sudo apt install libpam-google-authenticator`
3. als User ausführen: `google-authenticator`
- Abfragen beantworten
- erstellt Datei `~/.google_authenticator`
4. PAM-Modul anpassen: `sudo nano /etc/pam.d/sshd`
- auskommentieren: `# @include common-auth`
- neu darunter einfügen: `auth required pam_google_authenticator.so`
5. SSH-Konfiguration anpassen: `sudo nano /etc/ssh/sshd_config`
  ```bash
  ChallengeResponseAuthentication yes
  AuthenticationMethods publickey,keyboard-interactive
  UsePAM yes
  ```
- evtl. weitere Methoden hinzufügen (wie Passwort)
6. SSH-Dienst neu starten: `sudo systemctl restart sshd.service`
7. Test: `ssh -i ~/.ssh/dein_key_hier tux@debian`
- andere Session vorher **nicht** trennen

# Fragen

1. Which of the following statements is true?

A. Secure Shell is completely secure in its default configuration.  
B. It’s safe to allow the root user to use Secure Shell to log in across the Internet.  
C. Secure Shell is insecure in its default configuration.  
D. The most secure way to use Secure Shell is to log in with a username and password.  

# Fragen

2. Which three of the following things would you do to conform with the best security practices for Secure Shell?

A. Make sure that all users are using strong passwords to log in via Secure Shell.  
B. Have all users create a public/private key pair, and transfer their public keys to the server to which they want to log in.  
C. Disable the ability to log in via username/password.  
D. Ensure that the root user is using a strong password.  
E. Disable the root user’s ability to log in.  

# Fragen

3. Which one of the following lines in the sshd_config file will cause botnets to not scan your system for login vulnerabilities?

A. PasswordAuthentication no  
B. PasswordAuthentication yes  
C. PermitRootLogin yes  
D. PermitRootLogin no  

# Fragen

4. How would you confine a user of SFTP to his or her own specified directory?

A. Ensure that proper ownership and permissions are set on that user’s directory.  
B. In the sshd_config file, disable that user’s ability to log in via normal SSH and define a chroot directory for that user.  
C. Define the user’s limitations with TCP Wrappers.  
D. Use whole-disk encryption on the server so that SFTP users will only be able to access their own directories.  

# Fragen

5. Which two of the following commands would you use to add your private SSH key to your session keyring?

A. ssh-copy-id  
B. exec /usr/bin/ssh-agent  
C. exec /usr/bin/ssh-agent $SHELL  
D. ssh-agent  
E. ssh-agent $SHELL  
F. ssh-add  

# Fragen

6. Which of the following is not on NIST’s list of recommended algorithms?

A. RSA  
B. ECDSA  
C. Ed25519  

# Fragen

7. Which of the following is the correct directive for creating a custom configuration for Katelyn?

A. User Match katelyn  
B. Match katelyn  
C. Match Account katelyn  
D. Match User katelyn  

# Fragen

8. Which of the following crypto policies provides the strongest encryption on RHEL 8/9-type distros?

A. LEGACY  
B. FIPS  
C. DEFAULT  
D. FUTURE  

# Fragen

9. Which of the following standards defines NIST’s current recommendations for encryption algorithms?

A. FIPS 140-2  
B. FIPS 140-3  
C. CNSA  
D. Suite B  

# Antworten

1. C
2. B, C, E
3. A
4. B
5. C, F
6. C
7. D
8. D
9. C

# Zusammenfassung

Was hast du in diesem Abschnitt gelernt?

<!-- TOC -->
* [SSH-Härtung](#ssh-härtung)
* [SSH-Schlüsselsatz erstellen](#ssh-schlüsselsatz-erstellen)
* [Deaktivierung von Passwort Login](#deaktivierung-von-passwort-login)
* [Logging für SSH anpassen](#logging-für-ssh-anpassen)
* [Weitere Sicherheit für SSH](#weitere-sicherheit-für-ssh)
* [Von Windows-Clients über SSH verbinden](#von-windows-clients-über-ssh-verbinden)
* [SSH-Audit für Client und Server](#ssh-audit-für-client-und-server)
* [2FA mit TOTP](#2fa-mit-totp)
<!-- TOC -->
