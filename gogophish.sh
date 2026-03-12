#!/bin/bash

<<com
# Version         : 1.0
# Last update     : 03/12/2026
# Author          : PSDT - PurpleCode
# Description     : Automated script to install EvilgoGoPhish and configure SSL certificate with certbot, compatible with Evilginx 3.3.0+
# Release Note    : 
	03/12/26:
		- Updated to EvilgoGoPhish v1.0
		- Changed default port from 3333 to 8443
		- Install ultimate version go with snap
		- Updated author information
	  
com

### Colors
red=`tput setaf 1`;
green=`tput setaf 2`;
yellow=`tput setaf 3`;
blue=`tput setaf 4`;
magenta=`tput setaf 5`;
cyan=`tput setaf 6`;
bold=`tput bold`;
clear=`tput sgr0`;

banner() {
cat <<EOF
${blue}${bold}
                      

--[[
_/\/\/\/\/\/\______________/\/\____/\/\______________________________/\/\/\/\/\______________/\/\/\/\/\____/\/\________/\/\________________/\/\___________
_/\____________/\/\__/\/\__________/\/\______/\/\/\/\____/\/\/\____/\/\____________/\/\/\____/\/\____/\/\__/\/\__________________/\/\/\/\__/\/\___________
_/\/\/\/\/\____/\/\__/\/\__/\/\____/\/\____/\/\__/\/\__/\/\__/\/\__/\/\__/\/\/\__/\/\__/\/\__/\/\/\/\/\____/\/\/\/\____/\/\____/\/\/\/\____/\/\/\/\_______
_/\/\____________/\/\/\____/\/\____/\/\______/\/\/\/\__/\/\__/\/\__/\/\____/\/\__/\/\__/\/\__/\/\__________/\/\__/\/\__/\/\__________/\/\__/\/\__/\/\_____
_/\/\/\/\/\/\______/\______/\/\/\__/\/\/\________/\/\____/\/\/\______/\/\/\/\/\____/\/\/\____/\/\__________/\/\__/\/\__/\/\/\__/\/\/\/\____/\/\__/\/\_____
___________________________________________/\/\/\/\_______________________________________________________________________________________________________
--]]                                                                                              [PSDT - PurpleCode]

        /|
       / |   /|
   <===  |=== | --------------------------------v1.0
       \ |   \|
        \|
${clear}
EOF

}

usage() {
  local ec=0

  if [ $# -ge 2 ] ; then
    ec="$1" ; shift
    printf "%s\n\n" "$*" >&2
  fi

  banner
  cat <<EOF

A quick Bash script to install EvilgoGoPhish server. 

${bold}Usage: ${blue}./$(basename $0) [-r <rid name>] [-e] [-s] [-d <domain name> ] [-c] [-h]${clear}

One shot to set up:
  - EvilgoGoPhish Server (Email Phishing Ver.)
  - EvilgoGoPhish Server (SMS Phishing Ver.)
  - SSL Cert for Phishing Domain (LetsEncrypt)

Options:
  -e 			Setup Email Phishing EvilgoGoPhish Server
  -s 			Setup SMS Phishing EvilgoGoPhish Server
  -r <rid name>		Configure custom "rid=" parameter for landing page (e.g., https://example.com?rid={{.RID}})
			If not specified, the default value would be "secure_id="
  -d <domain name>      SSL cert for phishing domain
			${red}[WARNING] Configure 'A' record before running the script${clear}
  -c 			Cleanup for a fresh install
  -h              	This help menu

Examples:
  ./$(basename $0) -e					Setup Email Phishing EvilgoGoPhish
  ./$(basename $0) -s					Setup SMS Phishing EvilgoGoPhish
  ./$(basename $0) -r <rid name> -e 			Setup Email Phishing EvilgoGoPhish + Your choice of rid
  ./$(basename $0) -r <rid name> -s			Setup SMS Phishing EvilgoGoPhish + Your choice of rid
  ./$(basename $0) -d <domain name>			Configure SSL cert for your phishing Domain
  ./$(basename $0) -e -d <domain name>			Email Phishing EvilgoGoPhish + SSL cert for Phishing Domain
  ./$(basename $0) -r <rid name> -e -d <domain name> 	Email Phishing EvilgoGoPhish + SSL cert + rid 

EOF

exit $ec
 
}

### Exit
exit_error() {
	usage
	exit 1
}

### Initial Update & Dependency Check
dependencyCheck() {
	### Update Sources
	echo "${blue}${bold}[INFO] Updating OS source lists...${clear}"
	apt update -y >/dev/null 2>&1	


	### Checking/Installing unzip
	unzip=$(which unzip)

	if [[ $unzip ]];
	then
		echo "${green}${bold}[INFO] Unzip already installed${clear}"
	else
		echo "${blue}${bold}[INFO] Installing unzip...${clear}"
		apt install unzip -y >/dev/null 2>&1
	fi

	### Checking/Installing go
        gocheck=$(which go)

        if [[ $gocheck ]];
        then
                echo "${green}${bold}[INFO] Golang already installed${clear}"
        else
                echo "${blue}${bold}[INFO] Installing Golang...${clear}"
                snap install go --classic >/dev/null 2>&1
        fi
	
	### Checking/Installing git
        gitcheck=$(which git)

        if [[ $gitcheck ]];
        then
                echo "${green}${bold}[INFO] Git already installed${clear}"
        else
                echo "${blue}${bold}[INFO] Installing Git...${clear}"
                apt install git -y >/dev/null 2>&1
        fi

	### Checking/Installing pip (*Needed to install Twilio lib)
        pipcheck=$(which pip)

	if [[ $pipcheck ]];
        then
                echo "${green}${bold}[INFO] Pip already installed${clear}"
        else
                echo "${blue}${bold}[INFO] Installing pip...${clear}"
                apt install python-pip -y >/dev/null 2>&1
		
        fi

}

### Setup Email Version EvilgoGoPhish
setupEmail() {
	### Cleaning Port 80
	fuser -k -s -n tcp 80

	### Deleting Previous EvilgoGoPhish Source (*Need to be removed to update new rid)
	#rm -rf /root/go/src/github.com/gophish >/dev/null 2>&1 &&

	### Installing EvilgoGoPhish
    echo "${blue}${bold}[INFO] Downloading the latest EvilgoGoPhish from the source...${clear}"
    #mkdir -p /root/go &&
	#export GOPATH=/root/go &&
	#go get github.com/gophish/gophish >/dev/null 2>&1 &&
	rm -rf /opt/evilgogophish 2>/dev/null &&

	#echo "${blue}${bold}[*] Creating a evilgogophish folder: /opt/evilgogophish${clear}"
    cd /opt &&
	git clone https://github.com/gophish/gophish.git evilgogophish

	if [ "$rid" != "" ]
	then
		echo "${blue}${bold}[INFO] Updating \"rid\" to \"$rid\"${clear}"
	    sed -i 's!rid!'$rid'!g' /opt/evilgogophish/models/campaign.go
		ridConfirm=$(cat /opt/evilgogophish/models/campaign.go | grep $rid)
		echo "${blue}${bold}[INFO] Confirming the update: $ridConfirm (campaign.go)${clear}"
    fi

	cd /opt/evilgogophish &&
	go build &&
	#mv ./evilgogophish /opt/evilgogophish/evilgogophish &&
	#cp -R $GOPATH/src/github.com/gophish/gophish/* /opt/evilgogophish &&
	sed -i 's!127.0.0.1!0.0.0.0!g' /opt/evilgogophish/config.json &&
	sed -i 's!3333!8443!g' /opt/evilgogophish/config.json &&

    echo "${blue}${bold}[INFO] Creating EvilgoGoPhish log folder: /var/log/evilgogophish${clear}"
    mkdir -p /var/log/evilgogophish &&

	### Start Script Setup	
	cp /opt/evilgogophish/evilgogophish_start /etc/init.d/evilgogophish &&
	chmod +x /etc/init.d/evilgogophish &&
	update-rc.d evilgogophish defaults
}

setupSMS() {
	### Cleaning Port 80
	fuser -k -s -n tcp 80

	### Installing EvilgoGoPhish
    echo "${blue}${bold}[INFO] Downloading the latest EvilgoGoPhish from the source...${clear}"
    #mkdir -p /root/go &&
	#export GOPATH=/root/go &&
	#go get github.com/gophish/gophish >/dev/null 2>&1 &&
	rm -rf /opt/evilgogophish 2>/dev/null &&

	#echo "${blue}${bold}[*] Creating a evilgogophish folder: /opt/evilgogophish${clear}"
    cd /opt &&
	git clone https://github.com/gophish/gophish.git evilgogophish

	if [ "$rid" != "" ]
	then
		echo "${blue}${bold}[INFO] Updating \"rid\" to \"$rid\"${clear}"
	    sed -i 's!rid!'$rid'!g' /opt/evilgogophish/models/campaign.go
		ridConfirm=$(cat /opt/evilgogophish/models/campaign.go | grep $rid)
		echo "${blue}${bold}[INFO] Confirming the update: $ridConfirm (campaign.go)${clear}"
    fi

	cd /opt/evilgogophish &&
	go build &&
	#mv ./evilgogophish /opt/evilgogophish/evilgogophish &&
	#cp -R $GOPATH/src/github.com/gophish/gophish/* /opt/evilgogophish &&
	sed -i 's!127.0.0.1!0.0.0.0!g' /opt/evilgogophish/config.json &&
	sed -i 's!3333!8443!g' /opt/evilgogophish/config.json &&

    echo "${blue}${bold}[INFO] Creating EvilgoGoPhish log folder: /var/log/evilgogophish${clear}"
    mkdir -p /var/log/evilgogophish &&

	### Start Script Setup	
	cp /opt/evilgogophish/evilgogophish_start /etc/init.d/evilgogophish &&
	chmod +x /etc/init.d/evilgogophish &&
	update-rc.d evilgogophish defaults

	### Getting gosmish.py (Author: fals3s3t)
	echo "${blue}${bold}[INFO] Pulling gosmish.py (Author: fals3s3t) to: /opt/evilgogophish...${clear}"
	wget https://raw.githubusercontent.com/fals3s3t/gosmish/master/gosmish.py -P /opt/evilgogophish/gosmish.py 2>/dev/null &&
	chmod +x /opt/evilgogophish/gosmish.py

	### Installing Twilio
	echo "${blue}${bold}[*] Installing Twilio...${clear}"
	pip install -q  twilio >/dev/null 2>&1 &&

	echo "${blue}${bold}[INFO] Installing and configuring Postfix for SMS SMTP blackhole...${clear}"
	name=$(hostname)
	echo "postfix postfix/mailname string sms.sms " | debconf-set-selections
	echo "postfix postfix/main_mailer_type string 'Local Only'" | debconf-set-selections
	apt -y  install postfix >/dev/null 2>&1
	apt -y  install postfix-pcre >/dev/null 2>&1

	sed -i  "/myhostname/c\myhostname = $name" /etc/postfix/main.cf >/dev/null 2>&1 &&
	echo 'virtual_alias_maps = pcre:/etc/postfix/virtual' >> /etc/postfix/main.cf
	echo '/.*/nonexist' > /etc/postfix/virtual
	service postfix stop &&
	service postfix start &&

	### Start Script Setup	
	cp evilgogophish_start /etc/init.d/evilgogophish &&
	chmod +x /etc/init.d/evilgogophish &&
	update-rc.d evilgogophish defaults
}


### Setup SSL Cert
letsEncrypt() {
	### Clearning Port 80
	fuser -k -s -n tcp 80 
	service evilgogophish stop 2>/dev/null
	
	### Installing certbot-auto
	echo "${blue}${bold}[INFO] Installing certbot...${clear}" 
	#wget https://dl.eff.org/certbot-auto -qq
	#chmod a+x certbot-auto
	apt install certbot -y >/dev/null 2>&1

	### Installing SSL Cert	
	echo "${blue}${bold}[INFO] Installing SSL Cert for $domain...${clear}"

	### Manual
	#./certbot-auto certonly -d $domain --manual --preferred-challenges dns -m example@gmail.com --agree-tos && 
	### Auto
	certbot certonly --non-interactive --agree-tos --email example@gmail.com --standalone --preferred-challenges http -d $domain &&

	echo "${blue}${bold}[*] Configuring New SSL cert for $domain...${clear}" &&
	cp /etc/letsencrypt/live/$domain/privkey.pem /opt/evilgogophish/domain.key &&
	cp /etc/letsencrypt/live/$domain/fullchain.pem /opt/evilgogophish/domain.crt &&
	sed -i 's!false!true!g' /opt/evilgogophish/config.json &&
	sed -i 's!:80!:443!g' /opt/evilgogophish/config.json &&
	sed -i 's!example.crt!domain.crt!g' /opt/evilgogophish/config.json &&
	sed -i 's!example.key!domain.key!g' /opt/evilgogophish/config.json &&
	sed -i 's!gophish_admin.crt!domain.crt!g' /opt/evilgogophish/config.json &&
	sed -i 's!gophish_admin.key!domain.key!g' /opt/evilgogophish/config.json &&
	mkdir -p /opt/evilgogophish/static/endpoint &&
	printf "User-agent: *\nDisallow: /" > /opt/evilgogophish/static/endpoint/robots.txt &&
	echo "${green}${bold}[+] Check if the cert is correctly installed: https://$domain/robots.txt${clear}"
}

evilgogophishStart() {
	service=$(ls /etc/init.d/evilgogophish 2>/dev/null)

	if [[ $service ]];
	then
		sleep 1
		service evilgogophish restart &&
		#ipAddr=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1)
		ipAddr=$(curl ifconfig.io 2>/dev/null)
		pass=$(cat /var/log/evilgogophish/evilgogophish.error | grep 'Please login with' | cut -d '"' -f 4 | cut -d ' ' -f 10 | tail -n 1)
		echo "${green}${bold}[INFO] EvilgoGoPhish Started: https://$ipAddr:8443 - [Login] Username: admin, Temporary Password: $pass${clear}"
	else
		exit 1
	fi
}

cleanUp() {
	echo "${green}${bold}[INFO] Cleaning...1...2...3...${clear}"
	service evilgogophish stop 2>/dev/null
	rm -rf /opt/evilgogophish 2>/dev/null
	rm certbot-auto* 2>/dev/null
	rm -rf /opt/evilgogophish 2>/dev/null
	rm /etc/init.d/evilgogophish 2>/dev/null
	rm /etc/letsencrypt/keys/* 2>/dev/null
	rm /etc/letsencrypt/csr/* 2>/dev/null
	rm -rf /etc/letsencrypt/archive/* 2>/dev/null
	rm -rf /etc/letsencrypt/live/* 2>/dev/null
	rm -rf /etc/letsencrypt/renewal/* 2>/dev/null
	echo "${green}${bold}[INFO] Done!${clear}"
}

domain=''
rid=''

while getopts ":r:esd:ch" opt; do
	case "${opt}" in
		r)
			rid=$OPTARG ;;
		e)
			banner
			dependencyCheck
			setupEmail
			evilgogophishStart ;;
		s)
			banner
			dependencyCheck
			setupSMS
			evilgogophishStart ;;
		d) 
			domain=${OPTARG} 
			letsEncrypt && 
			evilgogophishStart ;;
		c)
			cleanUp ;;
		h | * ) 
			exit_error ;;
		:) 
			echo "${red}${bold}[ERROR] -${OPTARG} requires an argument (e.g., -r page_id or -d evilgogophish.com)${clear}" 1>&2
			exit 1;;
	esac
done

if [[ $# -eq 0 ]];
then
	exit_error
fi
