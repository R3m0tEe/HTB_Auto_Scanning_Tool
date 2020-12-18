#!/bin/bash


#------------------------------------------------------------------------------------------#
#					 AUTOMATED TOOL FOR HTB MACHINES		   #
#				              						   #
#	               									   #
#						       					   #
#	/* Purpose: Automate HTB machine scanning					   # 
#	/* Author: R3m0tEe								   #
#	/* Last updated on: Fri December, 18 2020				           #
#	/* Github: @https://github.com/R3m0tEe	             				   #
#------------------------------------------------------------------------------------------#
                  

echo -e "AUTOMATED TOOL FOR HTB MACHINES 
	Purpose: Automate HTB machine scanning 
	Author: R3m0tEe
	Last updated on: Fri December, 18 2020
	Github: @https://github.com/R3m0tEe" | boxes -d c


echo -e "Choose one:  
1. Nmap 
2. Gobuster
3. Nikto
4. All
5. Quit" | boxes -d ada-box

read -r -p 'Select: ' choice

while [[ ! "$choice" =~ ^[1-4]$ ]]
do
	if [[ "$choice" -eq 5 ]]; then
		exit 1
	fi
	echo "Please give an option from the menu!"
	read -r -p 'Select:' choice
done

username=$(whoami)
FILE=~/Desktop/htb
answer_yes=("y" "yes" "Y")
flag=1

# You can change the wordlist here...
wordlist="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"

read -r -p 'Give directory name: ' dir_name
	if [ -d "$FILE" ]; then
		if [ -d "$FILE/$dir_name" ]; then
			echo "Cannot create directory "$FILE/$dir_name": File exists"
			exit 1
		else
			`mkdir ~/Desktop/htb/$dir_name`
		fi
	else
		echo "Directory $FILE does not exist."
		read -r -p 'Would you like to create it? ' answer
		for item in $answer_yes
		do	
			if [ "$answer" = "$answer_yes" ]; then
				`mkdir ~/Desktop/htb && mkdir ~/Desktop/htb/$dir_name `
				echo "Directory ~/Desktop/htb/$dir_name created successfully."
			else
				exit 1
			fi
		done
	fi


ip_url_validation() {
	link1=$link_gobuster
	link2=$link_nikto
	url_val_flag1=gobuster_validation_flag
	url_val_flag2=nikto_validation_flag
	choice_flag=$flag_ch
	regex='(https?)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
	regex_ip='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
	#Validate both URL and IP address 
	if [[ ! $link1 =~ $regex ]] && [[ ! $link1 =~ $regex_ip ]] && [[ $url_val_flag1 -eq 1 ]]; then
		echo "Please enter a valid link. Exiting..."
		`rm -rf ~/Desktop/htb/$dir_name`
		exit 1
	elif [[ ! $link2 =~ $regex ]] && [[ ! $link2 =~ $regex_ip ]] && [[ $url_val_flag2 -eq 1 ]]; then
		echo "Please enter a valid link. Exiting..."
		`rm -rf ~/Desktop/htb/$dir_name`
		exit 1
	fi
	while ( ( !type gobuster &>/dev/null && !type nikto &>/dev/null ) || [[ $choice_flag -eq 1 ]]  )
	do
	#Validate IP address
		if [[ -z ${link_nikto+x} ]]; then
			read -r -p 'Please give an IP address: ' ip 
			if [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
				echo "Please enter a valid IP address. Exiting..."
				`rm -rf ~/Desktop/htb/$dir_name`
				exit 1
			fi
		fi
		choice_flag=0
	done
}

nmap () {
	ip_url_validation
	sudo nmap -sS -sV -sC -T4 -p- $ip -oN "$FILE"/"$dir_name"/"$dir_name"_nmap
}

gobuster () {
	read -r -p 'Please give a valid link to test with gobuster (e.g http://10.10.10.120/): ' link_gobuster
	gobuster_validation_flag=1
	ip_url_validation "link_gobuster" "gobuster_validation_flag"
	sudo gobuster dir -u $link_gobuster -w $wordlist
}

nikto () {
	read -r -p 'Please give a valid link to test with nikto (e.g http://10.10.10.120/): ' link_nikto
	nikto_validation_flag=1
	ip_url_validation "link_nikto" "nikto_validation_flag"
	sudo nikto -h $link_nikto  | tee $FILE/$dir_name/nikto.log
}

if [[ "$flag" -eq 1  &&  "$choice" -eq 1 ]]; then
	flag_ch=1
	nmap
elif [[ "$flag" -eq 1  &&  "$choice" -eq 2 ]]; then
	gobuster
elif [[ "$flag" -eq 1  &&  "$choice" -eq 3 ]]; then
	nikto
elif [[ "$flag" -eq 1  &&  "$choice" -eq 4 ]]; then	
	flag_ch=1
	ip_url_validation
	gobuster_validation_flag=1
	nikto_validation_flag=1
	read -r -p 'Please give a valid link to test with gobuster (e.g http://10.10.10.120/): ' link_gobuster
	read -r -p 'Please give a valid link to test with nikto (e.g http://10.10.10.120/): ' link_nikto
	ip_url_validation
	gnome-terminal  --tab --title="Nmap Scan" -e "bash -c \"sudo nmap -sS -sV -sC -T4 -p- $ip -oN "$FILE"/"$dir_name"/"$dir_name"_nmap;exec bash\"" --tab --title="Gobuster Scan" -e "bash -c \"gobuster dir -u $link_gobuster -w "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt";exec bash\"" --tab --title="Nikto Scan" -e "bash -c \"nikto -h $link_nikto  | tee $FILE/$dir_name/nikto.log;exec bash\""
fi
