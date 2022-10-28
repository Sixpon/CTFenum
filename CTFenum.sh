#!/bin/bash

k="\e[31m"
g="\e[32m"
s="\e[0m"

until [[ $platform == 1 || $platform == 2 || $platform == 3 ]]
do
echo -e "${a}Platformunu seç:${b}
${g}1-TryHackMe
2-Vulnhub
3-HackTheBox${s}

${k}1 / 2 / 3${s} :"

read platform
done

#/root dizini altına aşağıdaki klasörleri oluştur.
case $platform in

	1)	#eğer yoksa bu dizini OLUŞTUR!
		kayit="/root/TryHackMe/lab"
		;;
	2)	#eğer yoksa bu dizini OLUŞTUR!
		kayit="/root/Vulnhub/lab"
		;;
	3)	#eğer yoksa bu dizini OLUŞTUR!
		kayit="/root/HackTheBox/lab"
		;;
esac

 echo -e "${g}Makinenin adı ne? :${s}" 
read makine
#Makinenin adı ile bir dizin oluştur
 mkdir $kayit/$makine
sleep 1
 echo -e "${k}$kayit/$makine${s} ${g}dizinine klasör oluşturdum.${s}"

 echo -e "${g}Makinenin IP adresi nedir?${s} :"
 read ip
#Hedef makine ayakta mı?
 while true
 do
  if ping -q -c 2 -W 1 $ip > /dev/null; then
   echo -e "${g}Sistem açık ve ulaşılabilir!${s}"
   break
  else
   echo -e "${k}$ip hala kapalı ya da arada firewall var!${s}"
   #break
#Eğer arada firewall varsa ve icmp paketlerine cevap dönmüyorsa üstteki break'i yorum satırından çıkar!
  fi
 sleep 2
 done

echo -e "${g}Hedefin ilk 1000 Portunu tarıyorum, tarama sonucunu${s} ${k}$kayit/$makine/Top1000Port${s} ${g}dizinine kayıt edeceğim.${s}"
sleep 2
nmap -Pn -n -T4 --top-ports 1000 -oA $kayit/$makine/Top1000Port $ip -sV

echo -e "${g}Ne olur ne olmaz, tüm portları taramak lazım!${s}"
sleep 2
nmap -Pn -n -p- -T5 -oA $kayit/$makine/FullPortScan $ip -sV
sleep 2
echo -e "${g}Full Tarama bitti. Sonuçlarını${s} ${k}$kayit/$makine/FullPortScan${s} ${g}dizinine kaydettim.${s}"

