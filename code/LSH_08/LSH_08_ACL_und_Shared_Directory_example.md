# Shared Directory Management

- nachfolgend betrachten wir, wie man **ACL** und **Sonderrechte** verwendet
- typisches Beispiel: Gruppen-Ordner für eine Abteilung

# Gruppe anlegen und User hinzufügen

Gruppe anlegen:
```bash
G=marketing
sudo groupadd "$G"
```

User hinzufügen:
```bash
for U in susanne maria markus victoria; do
  sudo useradd -m -s /bin/bash -G "$G" "$U"
  sudo passwd "$U"
  groups "$U"
done
```

# Gruppen-Ordner mit geeigneten Rechten anlegen

```bash
cd /
D=marketing
sudo mkdir "$D"
ls -ld "$D"
sudo chown nobody:"$G" "$D"
sudo chmod 070 "$D"
ls -ld "$D"
```

# Elemente im Gruppen-Ordner erstellen

mit anderem User eine Datei in diesem Ordner erstellen:
```bash
sudo -iu susanne
cd /marketing
touch susanne.txt
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
sudo chmod g+s "$D"
```

Lösung zu 2: Sticky Bit setzen
```bash
sudo chmod o+t "$D"
```

# Mit ACL nur bestimmten Usern Zugriff erlauben

das tut Victoria:
```bash
cd /marketing
echo "Das ist für meine Freundin Susi." > victoria.txt
chmod 600 victoria.txt
setfacl -m u:susanne:r victoria.txt
ls -l
getfacl victoria.txt
```
- kann Susanne/Markus/andere auf die Datei ```victoria.txt``` zugreifen?
