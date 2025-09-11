```bash

######
######  EXAMPLE
######

## update & install
sudo apt update && sudo apt install apparmor-utils -y
## ss works:
ss -tuna
## could generate (full) profile:
sudo aa-genprof /usr/bin/ss
## but rather generate raw profile:
aa-easyprof /usr/bin/ss > usr.bin.ss
cat usr.bin.ss
## move profile to apparmor folder:
sudo cp usr.bin.ss /etc/apparmor.d/
## enforce blank profile = application stops working
sudo aa-enforce /etc/apparmor.d/usr.bin.ss
## no more output:
ss -tuna
## dump journaldata for next step:
sudo journalctl | grep DENIED > ss.log
## read data from log and enhance profile:
sudo aa-logprof -f ss.log
## press "A" to allow the respective entries
## finally "S" save the changes
## profile usr.bin.ss has been updated
## see the updated profile:
sudo less /etc/apparmor.d/usr.bin.ss
## profile shoudl still be enfored:
sudo aa-status
## but now command should work as expected:
ss -tuna

######
######  TASKS
######

#### simple follow-up task for students:
#### modify the profile to disallow UDP

#### intermediate follow-up task for students:
#### modify the profile to make ss -tulpen work

#### advanced follow-up task for students:
#### create a profile for a local apache web server
sudo apt update
sudo apt install apache2 curl
curl localhost # shows default page
echo "<h1>my apache</h1>" > index.html
sudo cp index.html /var/www/html/
curl localhost # shows custom page
aa-easyprof /usr/sbin/apache2 > usr.sbin.apache2
sudo cp usr.sbin.apache2 /etc/apparmor.d/

sudo aa-complain /etc/apparmor.d/usr.sbin.apache2
sudo systemctl restart apache2
curl localhost # complain is logging now
http://192.168.122.49 # complain is logging now
sudo journalctl | grep DENIED > aa.log
grep apache aa.log > a2.log
sudo aa-logprof -f a2.log

sudo aa-enforce /etc/apparmor.d/usr.sbin.apache2
sudo systemctl restart apache2 # fails
sudo journalctl --since 12:00 | grep -i apparmor > aa.log
sudo aa-logprof -f aa.log

# manual editing:
sudo nano /etc/apparmor.d/usr.sbin.apache2
# check profile syntax:
sudo apparmor_parser -Q /etc/apparmor.d/usr.sbin.apache2
echo $? # exit code should be zero
# reload edited profile
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.apache2
sudo aa-enforce /etc/apparmor.d/usr.sbin.apache2
sudo systemctl restart apache2

# works now:
curl localhost # enforce is logging now
http://192.168.122.49 # enforce is logging now
# profile status:
sudo aa-status | grep -C 8 --color /usr/sbin/apache2
```
