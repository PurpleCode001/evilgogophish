<p align="center">
  <img width="400" height="550" alt="imagen" src="https://github.com/user-attachments/assets/a5dd7bb7-306c-428e-bd11-8f557e237439" />

  <h1 align="center">evilgogophish v1.0</h1>
</p>

A quick Bash script to automate the [Gophish](https://github.com/gophish/gophish) installation + LetsEncrypt your phishing domain.

Gophish is an open-source phishing toolkit designed for businesses and penetration testers. It provides the ability to quickly and easily setup and execute phishing engagements and security awareness training.

Table of contents
=================

<!--ts-->
   * [Installation](#installation)
   * [Usage](#usage)
   * [Example](#example)
   * [Phishing Server](#phishing-server-vps)
       * [AWS](#aws)
   * [Wildcard SSL Certificate Setup](#wildcard-ssl-certificate-setup)
<!--te-->

## Installation

```
git clone https://github.com/bigb0sss/evilgogophish.git
cd evilgogophish
chmod +x evilgogophish.sh
```

## Usage & Example

This script will help you automate installing + configuring your phishing domain with SSL certificate using [Certbot](https://github.com/certbot/certbot).

### Usage
```
./evilgogophish.sh -h


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

A quick Bash script to install GoPhish server.

Usage: ./evilgogophish.sh [-r <rid name>] [-e] [-s] [-d <domain name> ] [-c] [-h]

One shot to set up:
  - Gophish Server (Email Phishing Ver.)
  - Gophish Server (SMS Phishing Ver.)
  - SSL Cert for Phishing Domain (LetsEncrypt)

Options:
  -e 			Setup Email Phishing Gophish Server
  -s 			Setup SMS Phishing Gophish Server
  -r <rid name>		Configure custom "rid=" parameter for landing page (e.g., https://example.com?rid={{.RID}})
			If not specified, the default value would be "secure_id="
  -d <domain name>      SSL cert for phishing domain
			[WARNING] Configure 'A' record before running the script
  -c 			Cleanup for a fresh install
  -h              	This help menu

Examples:
  ./evilgogophish.sh -e					Setup Email Phishing Gophish
  ./evilgogophish.sh -s					Setup SMS Phishing Gophish
  ./evilgogophish.sh -r <rid name> -e 			Setup Email Phishing Gophish + Your choice of rid
  ./evilgogophish.sh -r <rid name> -s			Setup SMS Phishing Gophish + Your choice of rid
  ./evilgogophish.sh -d <domain name>			Configure SSL cert for your phishing Domain
  ./evilgogophish.sh -e -d <domain name>			Email Phishing Gophish + SSL cert for Phishing Domain
  ./evilgogophish.sh -r <rid name> -e -d <domain name> 	Email Phishing Gophish + SSL cert + rid

```

### Example

```
./evilevilgogophish.sh -e -d phish-me.com

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

[*] Updating source lists...
[+] Unzip already installed
[+] Golang already installed
[+] Git already installed
[*] Installing pip...
[*] Downloading gophish (x64)...
[*] Creating a gophish folder: /opt/gophish
[*] Creating a gophish log folder: /var/log/gophish
[+] Gophish Started: https://18.188.242.148:3333 - [Login] Username: admin, Temporary Password: 9b1463f87a726fd0
[*] Installing certbot...
[*] Installing SSL Cert for phish-me.com...
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator standalone, Installer None
Obtaining a new certificate

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/phish-me.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/phish-me.com/privkey.pem
   Your cert will expire on 2020-12-27. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

[*] Configuring New SSL cert for phish-me.com...
[+] Check if the cert is correctly installed: https://phish-me.com/robots.txt
[+] Gophish Started: https://18.188.242.148:3333 - [Login] Username: admin, Temporary Password: 08dc04c93066b242

```

## Phishing Server Setup (VPS)
### AWS

```
1) Install aws-cli - https://github.com/aws/aws-cli
* MacOS
$ wget https://awscli.amazonaws.com/AWSCLIV2.pkg
$ installer -pkg AWSCLIV2.pkg -target

2) AWS Configure
$ aws configure
	AWS Access Key ID [None]: <Your Access Key>
	AWS Secret Access Key [None]: <Your Secret Access Key>
	Default region name [None]: us-east-2
	Default output format [None]: json

3) SSH Key Pairs
First, 'ssh-keygen' to create a SSH key pair
Second, import the .pub key to AWS EC2 Key Pair

$ aws ec2 import-key-pair \
	--key-name evilgogophish-ssh \
	--public-key-material file:///Users/bigb0ss/tools/aws-cli/.ssh/evilgogophish_id_rsa.pub \
	--region us-east-2
	
4) Create AWS EC2
$ ./ec2_create.sh - https://github.com/bigb0sss/evilgogophish/blob/master/aws/ec2_create.sh

5) Terminate AWS EC2
$ ./ec2_termination.sh - https://github.com/bigb0sss/evilgogophish/blob/master/aws/ec2_termination.sh
```

### Vultr
coming soon...

## Wildcard SSL Certificate Setup

If you are planning to use subdomains with your phishing domain, do the following to add the wildcard SSL certificate. 

```
1) Run the following Certbot command:
$ certbot certonly -d *.phish-me.com --manual --preferred-challenges dns

Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator manual, Installer None
Obtaining a new certificate
Performing the following challenges:
dns-01 challenge for phish-me.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
NOTE: The IP of this machine will be publicly logged as having requested this
certificate. If you're running certbot in manual mode on a machine that is not
your server, please ensure you're okay with that.

Are you OK with your IP being logged?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name
_acme-challenge.phish-me.com with the following value:

yunoNuR-DxwUpypvTGYtWpysYslnAFutagi7swXoi6k

Before continuing, verify the record is deployed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue

2) Configure the above _acme-challege to your domain's DNS TXT record. Use the following command to confirm:
$ dig -t TXT _acme-challenge.phish-me.com

; <<>> DiG 9.10.6 <<>> -t TXT _acme-challenge.phish-me.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 39714
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;_acme-challenge.phish-me.com. IN	TXT

;; ANSWER SECTION:
_acme-challenge.phish-me.com. 3600 IN TXT	"yunoNuR-DxwUpypvTGYtWpysYslnAFutagi7swXoi6k"

3) Run the following Bash script:

#!/usr/bin/bash
domain="<Your Domain>"

cp /etc/letsencrypt/live/$domain-0001/privkey.pem /opt/gophish/domain.key &&
cp /etc/letsencrypt/live/$domain-0001/fullchain.pem /opt/gophish/domain.crt 
service gophish restart
```

## Work In-Progress
* SMS Phishing Server Config is not 100% integrated to evilgogophish. And disclaimer to using fals3s3t python script.
* Adding another function to install Evilginx with GoPhish

## Change Log

* 03/12/26: Evilevilgogophish 1.0 is released
