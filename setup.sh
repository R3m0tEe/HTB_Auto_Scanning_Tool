#!/bin/bash

prerequisites () {
	sudo apt-get update && sudo apt-get upgrade #update system & repositories
	sudo apt-get install boxes	#install boxes for drawings
	sudo apt-get install nmap	#install nmap tool
	sudo apt-get install gobuster	#install gobuster tool
	sudo apt-get install nikto -y	#install nikto tool
}

prerequisites