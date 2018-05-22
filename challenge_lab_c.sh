#!/bin/bash

# DVA233 - Linux
# Erik Kamph
# Challenge Lab C

directory="/var/log"

mkdir ~/archive						#Skapa två mappar som används i hemmappen för användaren
mkdir ~/backup

cd ${directory}						#Byt directory till /var/log och sök efter alla filer som slutar med .log
TOOL=`find * -iname "*.log" -type f`

tar -cvf ~/archive/log.tar $TOOL	#Arkivera dessa till en tar fil i archive mappen som heter log.tar
echo " "
tar -tf ~/archive/log.tar			#Lista allt det som finns i log.tar
echo " "
tar -xf ~/archive/log.tar -C ~/backup/	#Extrahera log.tar till mappen backup

ls ~/backup							#Lista det som extraherats till backup mappen
