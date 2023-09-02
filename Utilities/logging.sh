#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

scriptStartMessage(){
    printf "${YELLOW}$1${NC}\n"
}
scriptEndMessage(){
    printf "\n\n\n${YELLOW}$1${NC}\n"
}
debugMessage(){
    printf "\t\t${CYAN}$1${NC}\n"
}
infoMessage(){
    printf "\t${GREEN}$1${NC}\n"
}
errorMessage(){
    printf "\n\n${RED}$1${NC}\n\n";
    exit 1
}
filePrint(){
   printf "${GREEN}$1${NC}\n" 
}

