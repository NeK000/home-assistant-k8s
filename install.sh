#!/bin/bash
set -e
set -o pipefail

source ./Utilities/logging.sh
source ./Utilities/validation.sh
source ./Utilities/action.sh
deploymentName="ha-deployment"
deploymentNamePritty="Home Assitant deployment"
loggingFile="installation-log-$(date +'%d-%m-%Y').txt"
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
    namespaceYaml=$deploymentDirectory/namespace.yaml
    pvcLonghornYaml=$deploymentDirectory/persistance-volume-longhorn.yaml
    pvcNfsYaml=$deploymentDirectory/persistance-volume-nfs.yaml
    deploymentYaml=$deploymentDirectory/deployment.yaml
    serviceYaml=$deploymentDirectory/service.yaml
    ingressRouteYaml=$deploymentDirectory/ingress-route.yaml
    infoMessage "Preparing deployment file"
    IMAGE_NAME=$(yq .deployment.image.name configuration.yaml):$(yq .deployment.image.tag configuration.yaml)    yq -i '.spec.template.spec.containers[0].image = strenv(IMAGE_NAME)'  $deploymentYaml
    HOMEKIT_ENABLED=$(yq .deployment.homekit.enabled configuration.yaml)
    
    if [ "$HOMEKIT_ENABLED" = true ] ; then
        yq -i '.spec.template.spec.hostNetwork = true'  $deploymentYaml
    fi

    infoMessage "Preparing persistance volume files"
    STORAGE_TYPE=$(yq .storage.type configuration.yaml)
    if [ "$STORAGE_TYPE" = "longhorn" ] ; then
        infoMessage "Choosen storage type is longhorn"
        SIZE=$(yq .storage.size configuration.yaml)    yq -i '.spec.resources.requests.storage = strenv(SIZE)' $pvcLonghornYaml
    else
        infoMessage "Choosen storage type is NFS"
        SIZE=$(yq .storage.size configuration.yaml)    yq -i '.spec.resources.requests.storage = strenv(SIZE)' $pvcNfsYaml
        SIZE=$(yq .storage.size configuration.yaml)    yq -i '.spec.capacity.storage = strenv(SIZE)' $pvcNfsYaml
        NFS_PATH=$(yq .storage.nfs.path configuration.yaml)    yq -i '.spec.nfs.path = strenv(NFS_PATH)' $pvcNfsYaml
        NFS_SERVER=$(yq .storage.nfs.server configuration.yaml)    yq -i '.spec.nfs.server = strenv(NFS_SERVER)' $pvcNfsYaml
    fi

    infoMessage "Preparing service files"
    SERVICE_PORT=$(yq .service.port configuration.yaml)    yq -i '.spec.ports[0].port = strenv(SERVICE_PORT)' $serviceYaml
    ROUTE=$(yq .service.ingressHost configuration.yaml)

    SERVICE_INGRESS_ROUTE="Host('$ROUTE')"    yq -i '.spec.routes[0].match = strenv(SERVICE_INGRESS_ROUTE)' $ingressRouteYaml
    cat $ingressRouteYaml

    #### Reusable end part in the action script
    removeTempDirectory "$deploymentDirectory"
    scriptEndMessage "Succesfull installation of Home Assistant !!!"
    #### End of reusable end part

}