#!/bin/bash

# DVA233 - Linux
# Erik Kamph
# Challenge Lab D

SERVICES=uniqueservices.txt
TMP=/tmp/services.sh.$$								#TMP, TMP2 är temporära filer som försvinner när programmet körts
TMP2=/tmp/service.sh.$$

grep -o '^[^#]*' /etc/services > $TMP				#Strippa /etc/services filen på kommentarer och skicka outputen till TMP fil
cut $TMP -f1,1-1 > $TMP2							#Vi tar bara ett fält från utskriften och skickar resultatet till TMP2
sort -n $TMP2 > $TMP								#Sortera TMP2 och skicka till TMP(skriv över gamla outputen)
grep -o '^[^\ ]*' $TMP > $TMP2						#Ta bort kvarvarande siffror och kommentarer som kan finnas efter varje tjänst namn
uniq -u $TMP2 > $SERVICES							#Ta bort dubletter och skicka till uniqueservices.txt


[ -f $TMP ] && rm $TMP								#Ta bort de temporära filerna som använts under programmets gång testa med en ls /tmp för att se så att det inte finns filer i /tmp
[ -f $TMP2 ] && rm $TMP2
