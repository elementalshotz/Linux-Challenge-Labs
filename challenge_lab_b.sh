#!/bin/bash

# DVA233 - Linux
# Erik Kamph
# Challenge Lab B

echo Hello type name of the group you wish to add.
read GROUPNAME														#Vi frågar efter ett namn på en grupp

EXISTS=`grep ${GROUPNAME} /etc/group | head -n1 | cut -d: -f1`		#Hämtar sedan gruppen (om den finns) och lagrar i EXISTS

while [ "${GROUPNAME}" == "${EXISTS}" ]								#Om EXISTS är tom körs inte loopen annars om de stämmer överrens så körs loopen och man får mata in på nytt
do
echo Groupname already exists, try another name
read GROUPNAME
EXISTS=`grep ${GROUPNAME} /etc/group | head -n1 | cut -d: -f1`
done

addgroup ${GROUPNAME}

echo The group has been created!
echo Type a name of a user you wish to add to the group
read USERNAME														#Samma sak görs med användare, den enda skillnaden är att vi hämtar användaren från /etc/passwd

EXISTS=`grep ${USERNAME} /etc/passwd | head -n1 | cut -d: -f1`

while [ "${USERNAME}" == "${EXISTS}" ]
do
echo Username already exists, try another name
read USERNAME
EXISTS=`grep ${USERNAME} /etc/passwd | head -n1 | cut -d: -f1`
done

useradd -s /bin/bash -G ${GROUPNAME} ${USERNAME}					#Skapa användaren med bash-login och lägg till i gruppen
passwd ${USERNAME}													#låt användaren skapa ett lösenord för användaren
mkdir /${USERNAME}													#Skapa en mapp som sedan ägs av gruppen och användaren som skapats med stickybit för others och rwx för ägare och grupp
chown ${USERNAME} /${USERNAME}
chgrp ${GROUPNAME} /${USERNAME}
chmod 1770 /${USERNAME}
usermod -d /${USERNAME} ${USERNAME}									#Sätt hem mapp på användare till mapp som skapats

ISINGROUP=`getent group ${GROUPNAME} | cut -d: -f4`
if [ "${ISINGROUP}" == "${USERNAME}" ]								#Kolla så att användaren existerar i gruppen
then
echo The user exists in group ${GROUPNAME}!
else
echo The user does not exist in group ${GROUPNAME}!
fi
