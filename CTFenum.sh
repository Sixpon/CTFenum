#!/bin/bash

k="\e[31m"
g="\e[32m"
s="\e[0m"



until [[ $platform == 1 || $platform == 2 || $platform == 3 || $platform == 4 ]]
do
echo -e "${a}Platformunu seç:${b}
${g}1-TryHackMe
2-Vulnhub
3-HackTheBox${s}

Seçmeden ilerlemek için 4

${k}1 / 2 / 3 / 4${s} :"


read platform
done

#/root dizini altına aşağıdaki klasörleri oluştur.
case $platform in

	1)
		kayit="/root/TryHackMe/lab"
		;;
	2)
		kayit="/root/Vulnhub/lab"
		;;
	3)
		kayit="/root/HackTheBox/lab"
		;;
esac
if [[ $platform == 4 ]]; then
	echo "[!] ${k}Kayıt yeri seçilmeden ilerleniyor!!!${s}"
else
	echo -e "[?] ${g}Makinenin adı ne? :${s}" 
	read makine
	#Makinenin adı ile bir dizin oluştur
	mkdir $kayit/$makine
	sleep 1
	echo -e "[---!---] ${k}$kayit/$makine${s} ${g}dizinine klasör oluşturdum.${s}"
fi
echo -e "[?] ${g}Makinenin IP adresi nedir?${s} :"
read ip
#Hedef makine ayakta mı?
 while true
 do
  if ping -q -c 2 -W 1 $ip > /dev/null; then
   echo -e "[*] ${g}Sistem açık ve ulaşılabilir!${s}"
   break
  else
   echo -e "[!] ${k}$ip hala kapalı ya da arada firewall var!${s}"
  fi
 done
if [[ $platform == 4 ]]; then
	echo -e "[---!---] ${g}Kayıt etmeden hedefin ilk 1000 portunu tarıyorum.${s}"
	nmap -Pn -n --top-ports 1000 -T4 $ip -sV
	sleep 2
	echo -e "[---!---] ${g}Ne olur ne olmaz, hepsini tarıyorum.${s}"
	nmap -Pn -n -p- -T4 -sV $ip
else
	echo -e "[---!---] ${g}Hedefin ilk 1000 Portunu tarıyorum, tarama sonucunu${s} ${k}$kayit/$makine/Top1000Port${s} ${g}dizinine kayıt edeceğim.${s}"
	sleep 2
	nmap -Pn -n -T4 --top-ports 1000 -oA $kayit/$makine/Top1000Port $ip -sV
	#FTP protokolünü kontrol eder. eğer açıksa anonim giriş yapmayı dener.
	grep " 21/open" $kayit/$makine/Top1000Port.gnmap > /dev/null 
	if [ $? -eq 0 ]; then
		echo -e "[---!---] ${g}21 Portu AÇIK. Anonymous login deniyorum!${s}"
		FTP_Login=`ftp -inv $ip > $kayit/$makine/anonymousftplogin.txt <<EOT
			user anonymous asd
			bin
			ls -la
			bye
EOT`
	fi
	grep "success" $kayit/$makine/anonymousftplogin.txt > /dev/null
	if [ $? -eq 0 ]; then
		echo -e "[---!---] ${k}Anonymous FTP Login Tespit Edildi!!!!${s}"
	else
		echo -e "[---!---] ${g}Anonymous Login yok gibi duruyor, ama ben sadece masum bir scriptim. Sen yine de bir kontrol et.${s}"
	fi
	#80,443 ve 8080 portları açıksa dirsearch çalıştır
	grep " 80/open" $kayit/$makine/Top1000Port.gnmap > /dev/null
	if [ $? -eq 0 ]; then
		echo -e "[---!---] ${g}80 portu açık. Dirsearch çalıştırıyorum.${s} ${k}->> $kayit/$makine/dirsearch.txt${s}"
		dirsearch -u $ip -o $kayit/$makine/dirsearch.txt > /dev/null
	fi
	grep " 443/open" $kayit/$makine/Top1000Port.gnmap > /dev/null
	if [ $? -eq 0 ]; then
        	echo -e "[---!---] ${g}443 portu açık. Dirsearch çalıştırıyorum.${s} ${k}->> $kayit/$makine/dirsearch443.txt${s}"
	        dirsearch -u $ip:443 -o $kayit/$makine/dirsearch443.txt > /dev/null
	fi
	grep " 8080/open" $kayit/$makine/Top1000Port.gnmap > /dev/null
        if [ $? -eq 0 ]; then
        	echo -e "[---!---] ${g}8080 portu açık. Dirsearch çalıştırıyorum.${s} ${k}->> $kayit/$makine/dirsearch443.txt${s}"
	        dirsearch -u $ip:8080 -o $kayit/$makine/dirsearch8080.txt > /dev/null
	fi
	echo -e "[---!---] ${g}Ne olur ne olmaz, tüm portları taramak lazım!${s}"
	sleep 2
	nmap -Pn -n -p- -T5 -oA $kayit/$makine/FullPortScan $ip -sV
	sleep 2
	echo -e "[---!---] ${g}Full Tarama bitti. Sonuçlarını${s} ${k}$kayit/$makine/FullPortScan${s} ${g}dizinine kaydettim.${s}"

fi

