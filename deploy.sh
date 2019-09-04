#!/bin/bash
# Script, jehož funkcí je přidat soubory s překladem do českého jazyka v Zimbra Collaboration Server Open Source Edition (8.8.15) #
# Můžeme také nastavit důležité proměnné v konfiguraci serveru Zimbra (související se zobrazením implementovaného jazyka) #

echo ""
echo " ##################################################################################"
echo " ###									      									  ###"
echo " ###								-- Cesky preklad pro Zimbru --			      ###"
echo " ###									     									  ###"
echo " ###			Zimbra Collaboration Server Open Source Edition (8.8.15)	      ###"
echo " ###																		      ###"
echo " ###						Autor: Jiricka Jakub		Date: 04.09.2019	      ###"
echo " ###							Kontakt: info@root4u.cz						      ###"
echo " ###									      									  ###"
echo " ##################################################################################"
echo ""

num1=0
while [ $num1 == 0 ]
do
	read -p "· Chcete implementovat cesky preklad na Zimbru? [A / N]:" INSTALACE;
	if [ "$INSTALACE" == "A" ] || [ "$INSTALACE" == "a" ]; then
		# Zmena prav a uzivatle k jazykovym souborum.
		/bin/chmod 664 messages/*
		/bin/chmod 664 keys/*
		/bin/chown zimbra:zimbra messages/*
		/bin/chown zimbra:zimbra keys/*

		# Zkopírujeme jazykové soubory na jejich odpovídající místa.
		cp -fp messages/* /opt/zimbra/jetty/webapps/zimbra/WEB-INF/classes/messages/
		cp -fp keys/* /opt/zimbra/jetty/webapps/zimbra/WEB-INF/classes/keys/
		cp -fp messages/* /opt/zimbra/jetty/webapps/zimbraAdmin/WEB-INF/classes/messages/
		cp -fp keys/* /opt/zimbra/jetty/webapps/zimbraAdmin/WEB-INF/classes/keys/

		# Přidejte localeName_cs_CZ = Czech do souborů ZmMsg_XX.properties jednotlivých jazyků.
		for file1 in /opt/zimbra/jetty/webapps/zimbra/WEB-INF/classes/messages/ZmMsg_*; 
			do
				echo "localeName_cs_CZ = Czech" >> $file1;
			done

		for file2 in /opt/zimbra/jetty/webapps/zimbraAdmin/WEB-INF/classes/messages/ZmMsg_*;
			do
				echo "localeName_cs_CZ = Czech" >> $file2;
			done

		# Zkopírujeme soubory nápovědy.
		su - zimbra -c "cp -fpr /opt/zimbra/jetty/webapps/zimbra/help/en_US/ /opt/zimbra/jetty/webapps/zimbra/help/eu"
		su - zimbra -c "cp -fpr /opt/zimbra/jetty/webapps/zimbraAdmin/help/en_US/ /opt/zimbra/jetty/webapps/zimbraAdmin/help/eu"

		echo "";
		echo " Jazyk byl spravne implementovan";
		echo " Poznámka: V některých částech Zimbry, které jsou závislé na Zimlets, nemusí být uvedeným jazykem cestina. Preklad zimletu nespada do rozsahu tohoto projektu.";
		echo "";
		num1=1;
	fi
	if [ "$INSTALACE" == "N" ] || [ "$INSTALACE" == "n" ]; then
		echo "";
		echo " Instalace byla zrusena!";
		echo "";
		num1=1;
	exit;
	fi
done

num2=0
while [ $num2 == 0 ]
do
	read -p "· Chcete nastavit cestinu jako výchozí jazyk pro všechny uživatele v rozhraní Zimbra? (Pokud používají výchozí CoS) [A / N]: " DEFAULT;
	if [ "$DEFAULT" == "A" ] || [ "$DEFAULT" == "a" ]; then
		# ZimbraPrefLocale jsme nastavili do cestiny
		su - zimbra -c "zmprov mc default zimbraPrefLocale cz"
		echo "";
		echo " Nastavena cestina jako vychozi jazyk ve webovem rozhrani Zimbry";
		echo " Poznámka: Pokud uživatel provede vlastní konfiguraci jazyka z jejich předvoleb, bude jejich volba nad výchozí konfigurací serveru.";
		echo " Poznámka: Pokud je CoS vlastní / specifické pro vaše skupiny uživatelů, musíte je ručně změnit příkazem: 'zmprov mc NONMBRE_DE_TU_CoS zimbraPrefLocale cz'" 
		echo "";
		num2=1;
	fi
	if [ "$DEFAULT" == "N" ] || [ "$DEFAULT" == "n" ]; then
		echo "";
        	echo " Krok byl vynechán.";
		echo "";
		num2=1;
	fi
done

num3=0
while [ $num3 == 0 ]
do
	read -p "· Chcete-li nový jazyk zpřístupnit, musíte restartovat službu Zimbra. Chcete jej nyní restartovat? [A / N]: " RESTART;
	if [ "$RESTART" == "A" ] || [ "$RESTART" == "a" ]; then
		echo ""
		echo " Restartování služby Zimbra. Tento proces může trvat pár minut ...";
		echo ""
		# Restartujeme sluzby
		su - zimbra -c "zmcontrol stop";
		sleep 10;
		echo "";
		su - zimbra -c "zmcontrol start";
		sleep 10;
		echo "";
		echo " Služba Zimbra byla restartována. Instalace byla dokončena.";
		echo "";
		num3=1;
	fi
	if [ "$RESTART" == "N" ] || [ "$RESTART" == "n" ]; then
		echo "";
		echo " Rozhodli jste se vynechat službu RESTART služby Zimbra. Nezapomeňte, že nový jazyk nebude dostupný, dokud nebude služba Zimbra restartována.";
		echo "";
		num3=1;
	fi
done