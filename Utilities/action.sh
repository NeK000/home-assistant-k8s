#!/bin/bash

createTempDirectory(){
    folderName=$1
    temporaryDirectory="/tmp/$folderName"
    debugMessage "Creating temporary directory $temporaryDirectory"
    removeTempDirectory $folderName
    mkdir -p "$temporaryDirectory" > /dev/null
}

removeTempDirectory(){
    folderName="/tmp/$1"
    debugMessage "Remove temporary directory $folderName"
    rm -rf "$folderName" > /dev/null
}

copyDeploymentsDirectoryToTemp(){
    folderName="/tmp/$1"
    debugMessage "Copy Deployment files into $folderName"
    cp -r Deployments/* $folderName/ 
}