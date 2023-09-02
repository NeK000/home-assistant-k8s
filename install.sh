#!/bin/bash
set -e
set -o pipefail

source ./Utilities/logging.sh
source ./Utilities/validation.sh
source ./Utilities/action.sh
deploymentName="ha-deployment"
deploymentNamePritty="Home Assitant deployment"

{
    ####Reusable start part in the action script
    scriptStartMessage "Starting installation of $deploymentNamePritty towards Kubernetes Cluster"
    deploymentDirectory="$(date +'%d-%m-%Y')-$deploymentName"
    isKubectlPresent
    createTempDirectory "$deploymentDirectory"
    copyDeploymentsDirectoryToTemp "$deploymentDirectory"
    infoMessage "Preparing distribution based on configuration.yaml ===> "
    filePrint "$(<configuration.yaml)"
    #####End of reusable start part

    #### Home Assistant Deployment and configurations.




    #### Reusable end part in the action script
    removeTempDirectory "$deploymentDirectory"
    scriptEndMessage "Succesfull installation of Home Assistant !!!"
    #### End of reusable end part

}