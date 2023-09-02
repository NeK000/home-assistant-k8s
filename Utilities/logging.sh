#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
mkdir -p log

writeToLogFile(){
    echo "$1" | tee -a "log/$loggingFile" >/dev/null
}
scriptStartMessage(){
    writeToLogFile $1
    printf "${YELLOW}$1${NC}\n"
}
scriptEndMessage(){
    writeToLogFile $1
    printf "\n\n\n${YELLOW}$1${NC}\n"
}
debugMessage(){
    writeToLogFile $1
    printf "\t\t${CYAN}$1${NC}\n"
}
infoMessage(){
    writeToLogFile $1
    printf "\t${GREEN}$1${NC}\n"
}
errorMessage(){
    writeToLogFile $1
    printf "\n\n${RED}$1${NC}\n\n"
    exit 1
}
filePrint(){
   writeToLogFile $1
   printf "${GREEN}$1${NC}\n" 
}

