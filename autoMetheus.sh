#!/bin/bash

# Static variables
source staticVariables.env

# Change file permissions
sudo chmod +x ./Scripts/*

while true;
do 
    # ==== OPTIONS MENU ==============================================================================================
    echo """
    Available options:
    [1] Install Prometheus
    [2] Tweak Prometheus
    [3] Install Exporters
    [4] Query Metrics
    """
    read -p "Please enter the option for the operation that you would like to accomplish: " option

    if $option == "1";
    then 
        # ==== INSTALL PROMETHEUS ========================================================================================
        while true;
        do

        # Target server
        read -p "Enter the IP address of the server that you want to install Prometheus on (Enter 127.0.0.1 for localhost): " targetDestination
        
        # Target server address is valid
        if $targetDestination =~ $IPv4;
        then

            # Server is reachable
            if ping -c 4 $targetDestination &> /dev/null; 
            then 
            
            # 
            if $targetDestination != "127.0.0.1";
            then
                
                while true;
                do 
                    # Prompt for user
                    read -p "Please provide the user on the remote server that'll run the script: " remoteUser

                    # Prompt for password
                    read -p "Please enter the password for the user on the remote server that'll run the script: " remoteUserPassword

                    # Test SSH
                    if sshpass -p $remoteUserPassword ssh StrictHostKeyChecking=no $remoteUser@$targetDestination;
                    then

                        # Copy all dependencies to remote host
                        if scp * $remoteUser@$targetDestination:/home/$remoteUser;
                        then  
                           sshpass -p $remoteUserPassword ssh StrictHostKeyChecking=no $remoteUser@$targetDestination "chmod +x "
                            break
                    fi 
                    echo -e "${RED}[ERROR]${WHITE} Unable to copy files to remote host. Please enter a valid username and password."

                fi
                echo -e "${RED}[ERROR]${WHITE} Unable to SSH to the remote server."

                done 
                break
            else

                # Install Prometheus locally
                if ! sudo systemctl status prometheus.service &> /dev/null;
                then 
                    echo -e "${YELLOW}[NOTICE]${WHITE} Installing Prometheus."
                    ./Scripts/install-Prometheus.sh
                fi 
            fi
            echo -e "${RED}[ERROR]${WHITE}"
            fi
            echo -e "${RED}[ERROR]${WHITE}"
        fi 
        echo -e "${RED}[ERROR]${WHITE} Please enter a valid IPv4 address"
        done

        echo -e "${GREEN}[SUCCESS]${WHITE} Prometheus was successfully installed and running on $targetDestination:9090."


    # ==== PROMETHEUS CONFIGURATION ==================================================================================
    elif $option == "2";
    then

    # ==== EXPORTERS =================================================================================================
    elif $option == "3";
    then

    # ==== PROMQL QUERIES ============================================================================================
    elif $option =="4";
    then 
        python3 ./Scripts/query-MetricOptions.py
    else 
        echo -e "${RED}[ERROR]${WHITE} $option is not a valid option. Please enter a valid option to continue."
    fi 

done 
