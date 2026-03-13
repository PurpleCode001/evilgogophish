#!/bin/bash

<<com
# Version         : 1.1 - Bait version
# Last update     : 03/12/2026
# Author          : PSDT - PurpleCode
# Description     : Automated script to install EvilgoGoPhish and configure SSL certificate with certbot, compatible with Evilginx 3.3.0+
# Release Note    : 
	03/12/26:
		- Updated to EvilgoGoPhish v1.0
		- Changed default port from 3333 to 8443
		- The Gophish repository was switched to kgretzky's version.
		- 
		- Install ultimate version go with snap
		- Updated author information
	xx/xx/26:
	- Updated to EvilgoGoPhish v1.1 - Bait Version
	- Add script bait.sh for install dependencies foor Evilginx 3.3+ and Gophish
	- Script bait.sh configure ufw firewall for all port needs
	
	  
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
   <===  |=== | --------------------------------v1.1 - Bait version
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

	### Deleting Previous EvilgoGoPhish Source
	rm -rf /opt/evilgogophish 2>/dev/null

	### Installing EvilgoGoPhish
    	echo "${blue}${bold}[INFO] Downloading the latest EvilgoGoPhish from the source...${clear}"
    	cd /opt &&
	git clone https://github.com/kgretzky/gophish.git evilgogophish

	if [ "$rid" != "" ]
	then
		echo "${blue}${bold}[INFO] Updating \"rid\" to \"$rid\"${clear}"
	    	sed -i 's!rid!'$rid'!g' /opt/evilgogophish/models/campaign.go
		ridConfirm=$(cat /opt/evilgogophish/models/campaign.go | grep $rid)
		echo "${blue}${bold}[INFO] Confirming the update: $ridConfirm (campaign.go)${clear}"
    	fi

	cd /opt/evilgogophish &&
	go build &&
	
	# Renombrar el binario
	if [ -f /opt/evilgogophish/gophish ]; then
		mv /opt/evilgogophish/gophish /opt/evilgogophish/evilgogophish
	fi
	
	# Configurar archivo de configuración
	sed -i 's!127.0.0.1!0.0.0.0!g' /opt/evilgogophish/config.json &&
	sed -i 's!3333!8443!g' /opt/evilgogophish/config.json &&

    	echo "${blue}${bold}[INFO] Creating EvilgoGoPhish log folder: /var/log/evilgogophish${clear}"
    	mkdir -p /var/log/evilgogophish &&

	### start Script Setup - CORREGIDO
	echo "${blue}${bold}[INFO] Configuring EvilgoGoPhish service...${clear}"
	
	# Obtener la ruta del directorio donde se está ejecutando este script
	SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
	
	# Verificar si el archivo evilgogophish_start existe en el directorio del script
	if [ -f "${SCRIPT_DIR}/evilgogophish_start" ]; then
		cp "${SCRIPT_DIR}/evilgogophish_start" /etc/init.d/evilgogophish &&
		chmod +x /etc/init.d/evilgogophish &&
		update-rc.d evilgogophish defaults
		echo "${green}${bold}[INFO] Service script installed successfully from ${SCRIPT_DIR}${clear}"
	else
		echo "${yellow}${bold}[WARNING] evilgogophish_start not found in ${SCRIPT_DIR}. Creating a default one...${clear}"
		
		# Crear un archivo de inicio por defecto
		cat > /etc/init.d/evilgogophish << 'EOFINIT'
#!/bin/bash
# /etc/init.d/evilgogophish
# Description: Initialization file: service evilgogophish {start|stop|status} 
# Config: /opt/evilgogophish/config.json

processName=EvilgoGoPhish
process=evilgogophish
appDirectory=/opt/evilgogophish
logfile=/var/log/evilgogophish/evilgogophish.log
errfile=/var/log/evilgogophish/evilgogophish.error

start() 
{
echo 'Starting '${processName}'...'
cd ${appDirectory}

if [ -f "./evilgogophish" ]; then
    nohup ./evilgogophish >>$logfile 2>>$errfile &
    echo "${processName} started"
else
    echo "ERROR: Binary not found"
    exit 1
fi
sleep 2
}

stop() 
{
echo 'Stopping '${processName}'...'
pid=$(pidof evilgogophish)
if [ -n "$pid" ]; then
    kill ${pid}
    echo "${processName} stopped"
else
    echo "${processName} is not running"
fi
sleep 1
}

status() 
{
pid=$(pidof evilgogophish)
if [[ "$pid" != "" ]]; then
    echo "${processName} is running (PID: $pid)"
else
    echo "${processName} is not running"
fi
}

case $1 in
    start) start ;;
    stop) stop ;;
    status) status ;;
    restart) stop; sleep 2; start ;;
    *) echo "Usage: $0 {start|stop|status|restart}"; exit 1 ;;
esac
EOFINIT
		chmod +x /etc/init.d/evilgogophish
		update-rc.d evilgogophish defaults
		echo "${green}${bold}[INFO] Default service script created${clear}"
	fi
}

cleanUp() {
    echo "${green}${bold}[INFO] Cleaning...1...2...3...${clear}"
    
    # Detener servicio
    service evilgogophish stop 2>/dev/null
    
    # Eliminar directorio de instalación
    rm -rf /opt/evilgogophish 2>/dev/null
    
    # Eliminar script de inicio
    rm -f /etc/init.d/evilgogophish 2>/dev/null
    
    # Eliminar certificados (opcional)
    echo "${yellow}${bold}[INFO] Do you want to remove Let's Encrypt certificates? (y/n)${clear}"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf /etc/letsencrypt/live/* 2>/dev/null
        rm -rf /etc/letsencrypt/archive/* 2>/dev/null
        rm -rf /etc/letsencrypt/renewal/* 2>/dev/null
        echo "${green}${bold}[INFO] Certificates removed${clear}"
    fi
    
    echo "${green}${bold}[INFO] Cleanup completed!${clear}"
}

setupSMS() {
	### Cleaning Port 80
	fuser -k -s -n tcp 80

	### Installing EvilgoGoPhish
    	echo "${blue}${bold}[INFO] Downloading the latest EvilgoGoPhish from the source...${clear}"
    	rm -rf /opt/evilgogophish 2>/dev/null &&

    	cd /opt &&
	git clone https://github.com/kgretzky/gophish.git evilgogophish

	if [ "$rid" != "" ]
	then
		echo "${blue}${bold}[INFO] Updating \"rid\" to \"$rid\"${clear}"
	    	sed -i 's!rid!'$rid'!g' /opt/evilgogophish/models/campaign.go
		ridConfirm=$(cat /opt/evilgogophish/models/campaign.go | grep $rid)
		echo "${blue}${bold}[INFO] Confirming the update: $ridConfirm (campaign.go)${clear}"
    	fi

	cd /opt/evilgogophish &&
	go build &&
	
	# Renombrar el binario
	if [ -f /opt/evilgogophish/gophish ]; then
		mv /opt/evilgogophish/gophish /opt/evilgogophish/evilgogophish
	fi
	
	# Configurar archivo de configuración
	sed -i 's!127.0.0.1!0.0.0.0!g' /opt/evilgogophish/config.json &&
	sed -i 's!3333!8443!g' /opt/evilgogophish/config.json &&

    	echo "${blue}${bold}[INFO] Creating EvilgoGoPhish log folder: /var/log/evilgogophish${clear}"
    	mkdir -p /var/log/evilgogophish &&

	### Getting gosmish.py
	echo "${blue}${bold}[INFO] Pulling gosmish.py to: /opt/evilgogophish...${clear}"
	mkdir -p /opt/evilgogophish/gosmish
	wget -q https://raw.githubusercontent.com/fals3s3t/gosmish/master/gosmish.py -O /opt/evilgogophish/gosmish/gosmish.py 2>/dev/null &&
	chmod +x /opt/evilgogophish/gosmish/gosmish.py

	### Installing Twilio
	echo "${blue}${bold}[*] Installing Twilio...${clear}"
	pip install -q twilio >/dev/null 2>&1 &&

	echo "${blue}${bold}[INFO] Installing and configuring Postfix for SMS SMTP blackhole...${clear}"
	name=$(hostname)
	echo "postfix postfix/mailname string sms.sms" | debconf-set-selections
	echo "postfix postfix/main_mailer_type string 'Local Only'" | debconf-set-selections
	apt -y install postfix >/dev/null 2>&1
	apt -y install postfix-pcre >/dev/null 2>&1

	sed -i "/myhostname/c\myhostname = $name" /etc/postfix/main.cf >/dev/null 2>&1 &&
	echo 'virtual_alias_maps = pcre:/etc/postfix/virtual' >> /etc/postfix/main.cf
	echo '/.*/nonexist' > /etc/postfix/virtual
	service postfix stop &&
	service postfix start &&

	### Start Script Setup - CORREGIDO
	echo "${blue}${bold}[INFO] Configuring EvilgoGoPhish service...${clear}"
	
	# Obtener la ruta del directorio donde se está ejecutando este script
	SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
	
	# Verificar si el archivo evilgogophish_start existe en el directorio del script
	if [ -f "${SCRIPT_DIR}/evilgogophish_start" ]; then
		cp "${SCRIPT_DIR}/evilgogophish_start" /etc/init.d/evilgogophish &&
		chmod +x /etc/init.d/evilgogophish &&
		update-rc.d evilgogophish defaults
		echo "${green}${bold}[INFO] Service script installed successfully from ${SCRIPT_DIR}${clear}"
	else
		echo "${yellow}${bold}[WARNING] evilgogophish_start not found in ${SCRIPT_DIR}. Using default service script...${clear}"
		
		# Usar el mismo script por defecto que en setupEmail
		if [ ! -f /etc/init.d/evilgogophish ]; then
			cat > /etc/init.d/evilgogophish << 'EOFINIT'
#!/bin/bash
# /etc/init.d/evilgogophish
# Description: Initialization file: service evilgogophish {start|stop|status} 
# Config: /opt/evilgogophish/config.json

processName=EvilGoPhish
process=evilgogophish
appDirectory=/opt/evilgogophish
logfile=/var/log/evilgogophish/evilgogophish.log
errfile=/var/log/evilgogophish/evilgogophish.error

start() 
{
echo 'Starting '${processName}'...'
cd ${appDirectory}

if [ -f "./evilgogophish" ]; then
    nohup ./evilgogophish >>$logfile 2>>$errfile &
    echo "${processName} started"
else
    echo "ERROR: Binary not found"
    exit 1
fi
sleep 2
}

stop() 
{
echo 'Stopping '${processName}'...'
pid=$(pidof evilgogophish)
if [ -n "$pid" ]; then
    kill ${pid}
    echo "${processName} stopped"
else
    echo "${processName} is not running"
fi
sleep 1
}

status() 
{
pid=$(pidof evilgogophish)
if [[ "$pid" != "" ]]; then
    echo "${processName} is running (PID: $pid)"
else
    echo "${processName} is not running"
fi
}

case $1 in
    start) start ;;
    stop) stop ;;
    status) status ;;
    restart) stop; sleep 2; start ;;
    *) echo "Usage: $0 {start|stop|status|restart}"; exit 1 ;;
esac
EOFINIT
			chmod +x /etc/init.d/evilgogophish
			update-rc.d evilgogophish defaults
		fi
		echo "${green}${bold}[INFO] Service script configured${clear}"
	fi
}

### Setup SSL Cert
letsEncrypt() {
    ### Cleaning Port 80
    fuser -k -s -n tcp 80 
    service evilgogophish stop 2>/dev/null
    
    ### Installing certbot
    echo "${blue}${bold}[INFO] Installing certbot...${clear}" 
    apt install certbot -y >/dev/null 2>&1

    ### Installing SSL Cert	
    echo "${blue}${bold}[INFO] Installing SSL Cert for $domain...${clear}"

    # Asegurar que el puerto 80 esté libre
    fuser -k -s -n tcp 80 2>/dev/null

    # Obtener certificado usando el puerto 80 (NO 8443)
    certbot certonly --non-interactive --agree-tos --email admin@$domain --standalone --preferred-challenges http --http-01-port 80 -d $domain

    if [ $? -ne 0 ]; then
        echo "${red}${bold}[ERROR] Failed to obtain SSL certificate${clear}"
        echo "Check that:"
        echo "  - Domain $domain points to this server"
        echo "  - Port 80 is accessible from internet"
        echo "  - No firewall is blocking port 80"
        exit 1
    fi

    echo "${blue}${bold}[*] Configuring New SSL cert for $domain...${clear}"
    
    # Crear NUEVO archivo de configuración con admin en 8443 y phish en 8080
    cat > /opt/evilgogophish/config.json << EOF
{
    "admin_server": {
        "listen_url": "0.0.0.0:8443",
        "use_tls": true,
        "cert_path": "/etc/letsencrypt/live/$domain/fullchain.pem",
        "key_path": "/etc/letsencrypt/live/$domain/privkey.pem",
        "trusted_origins": []
    },
    "phish_server": {
        "listen_url": "0.0.0.0:8080",
        "use_tls": false,
        "cert_path": "",
        "key_path": ""
    },
    "db_name": "sqlite3",
    "db_path": "gophish.db",
    "migrations_prefix": "db/db_",
    "contact_address": "",
    "logging": {
        "filename": "/var/log/evilgogophish/evilgogophish.log"
    }
}
EOF

    # Crear robots.txt
    mkdir -p /opt/evilgogophish/static/endpoint
    printf "User-agent: *\nDisallow: /" > /opt/evilgogophish/static/endpoint/robots.txt
    
    echo "${green}${bold}[+] SSL configured for https://$domain:8443 (admin) and http://$domain:8080 (phishing)${clear}"
}

evilgogophishStart() {
    service=$(ls /etc/init.d/evilgogophish 2>/dev/null)

    if [[ $service ]];
    then
        sleep 1
        service evilgogophish restart &&
        
        # Esperar a que se genere el log
        sleep 3
        
        # Determinar las URLs según si hay dominio o no
        if [ -n "$domain" ]; then
            admin_url="https://$domain:8443"
            phish_url="http://$domain:8080"
            echo "${green}${bold}[INFO] EvilgoGoPhish Started:${clear}"
            echo "  → Admin Panel: $admin_url"
            echo "  → Phishing Server: $phish_url"
        else
            # Si no hay dominio, mostrar la IP
            ipAddr=$(curl -s ifconfig.io 2>/dev/null)
            if [ -z "$ipAddr" ]; then
                ipAddr=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)
            fi
            admin_url="https://$ipAddr:8443"
            phish_url="http://$ipAddr:8080"
            echo "${green}${bold}[INFO] EvilgoGoPhish Started:${clear}"
            echo "  → Admin Panel: $admin_url"
            echo "  → Phishing Server: $phish_url"
        fi
        
        # Obtener la contraseña temporal
        if [ -f /var/log/evilgogophish/evilgogophish.error ]; then
            pass=$(cat /var/log/evilgogophish/evilgogophish.error | grep 'Please login with' | tail -1 | awk -F ' ' '{print $NF}')
            if [ -n "$pass" ]; then
                echo "  → Temporary Password: $pass"
            fi
        fi
    fi
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
