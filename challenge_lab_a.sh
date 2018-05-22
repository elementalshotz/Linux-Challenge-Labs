#!/bin/bash

# DVA233 - Linux
# Erik Kamph
# Challenge Lab A

for department in Engineering Sales IS								#Skapa en grupp, en mapp och sätt mappens gruppägare till department som kan vara Engineering, Sales eller IS
do
mkdir /${department}
addgroup --force-badname ${department}
chgrp ${department} /${department}
done

PASSWD="123"														#Skapa 3 administrativa användare för varje avdelning och sätt hemmapp och grupp för varje samt en bash-login
useradd -s /bin/bash -d /Engineering -G sudo,Engineering adm_eng
echo adm_eng:$PASSWD | chpasswd
useradd -s /bin/bash -d /Sales -G sudo,Sales adm_sal
echo adm_sal:$PASSWD | chpasswd
useradd -s /bin/bash -d /IS -G sudo,IS adm_is
echo adm_is:$PASSWD | chpasswd

for user in eng1 eng2												#Tre loopar för att skapa resterande 6 användare 2 för varje department som har som hem mapp /Engineering, /Sales eller /IS
do
useradd -s /bin/bash -G Engineering -d /Engineering ${user}
echo ${user}:$PASSWD | chpasswd
done

for user in sal1 sal2
do
useradd -s /bin/bash -G Sales -d /Sales ${user}
echo ${user}:$PASSWD | chpasswd
done

for user in is1 is2
do
useradd -s /bin/bash -G IS -d /IS ${user}
echo ${user}:$PASSWD | chpasswd
done

chown adm_eng /Engineering											#Sätt ägare på mapparna till administratörerna
chown adm_sal /Sales
chown adm_is /IS

chmod 1770 /Engineering												#Sätt stickybit för andra användare och rwx för både ägare och grupp så alla som är i respektive mapp kan redigera sina saker men ägaren kan göra vad som helst
chmod 1770 /Sales
chmod 1770 /IS

for department in Engineering Sales IS								#För varje department skapar vi en info fil som vi sedan sätter ägare till de respektive administratörs användare och gör så att gruppen kan läsa den men den administrativa användaren enbart kan läsa och skriva information till den.
do
touch /${department}/department-info.txt
chmod 740 /${department}/department-info.txt
if [ "${department}" == "Engineering" ]
then
chown adm_eng /${department}/department-info.txt
elif [ "${department}" == "Sales" ]
then
chown adm_sal /${department}/department-info.txt
else
chown adm_is /${department}/department-info.txt
fi
echo "This file contains confidential information for the department" > /${department}/department-info.txt
done

