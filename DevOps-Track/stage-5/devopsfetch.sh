#!/bin/bash

LOG_DIR="/var/log/devopsfetch"
LOG_FILE="$LOG_DIR/devopsfetch.log"

mkdir -p $LOG_DIR

log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> $LOG_FILE
}

show_help() {
    log "Displaying help message"
    echo "Usage: devopsfetch [OPTIONS]"
    echo "Options:"
    echo "  -p, --port [PORT]       Display active ports and services or details of a specific port"
    echo "  -d, --docker [CONTAINER] List Docker images and containers or details of a specific container"
    echo "  -n, --nginx [DOMAIN]    Display Nginx domains and ports or details of a specific domain"
    echo "  -u, --users [USERNAME]  List users and their last login times or details of a specific user"
    echo "  -t, --time [STARTTIME] [STOPTIME] Display activities within a specified time range"
    echo "  -i, --install           Install missing required services"
    echo "  -h, --help              Show this help message"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_missing_services() {
    log "Installing missing services"
    sudo apt update

    # List of required commands and their corresponding packages
    declare -A packages
    packages=(
        ["ss"]="iproute2"
        ["docker"]="docker.io"
        ["finger"]="finger"
        ["nginx"]="nginx"
        ["journalctl"]="systemd"
    )

    for cmd in "${!packages[@]}"; do
        if ! command_exists $cmd; then
            echo "Installing ${packages[$cmd]}..."
            sudo apt install -y ${packages[$cmd]}
            log "Installed ${packages[$cmd]}"
        else
            echo "${packages[$cmd]} is already installed."
            log "${packages[$cmd]} is already installed."
        fi
    done
}

list_ports() {
    if ! command_exists ss; then
        log "Error: ss command is not installed."
        echo "Error: ss command is not installed."
        exit 1
    fi

    log "Listing active ports and services"
    echo "Active ports and services:"
    ss -tuln | tee -a $LOG_FILE
}

port_details() {
    local port=$1
    if ! command_exists ss; then
        log "Error: ss command is not installed."
        echo "Error: ss command is not installed."
        exit 1
    fi

    log "Displaying details for port $port"
    echo "Details for port $port:"
    ss -tuln | grep ":$port " | tee -a $LOG_FILE
}

list_docker() {
    if ! command_exists docker; then
        log "Error: Docker is not installed."
        echo "Error: Docker is not installed."
        exit 1
    fi

    log "Listing Docker images and containers"
    echo "Docker images:"
    docker images | tee -a $LOG_FILE
    echo "Docker containers:"
    docker ps -a | tee -a $LOG_FILE
}

docker_details() {
    local container=$1
    if ! command_exists docker; then
        log "Error: Docker is not installed."
        echo "Error: Docker is not installed."
        exit 1
    fi

    log "Displaying details for Docker container $container"
    echo "Details for Docker container $container:"
    docker inspect $container | tee -a $LOG_FILE
}

list_nginx() {
    if ! command_exists nginx; then
        log "Error: Nginx is not installed."
        echo "Error: Nginx is not installed."
        exit 1
    fi

    log "Listing Nginx domains and their ports"
    echo "Nginx domains and their ports:"
    grep -r "server_name" /etc/nginx/sites-enabled/ | tee -a $LOG_FILE
}

nginx_details() {
    local domain=$1
    if ! command_exists nginx; then
        log "Error: Nginx is not installed."
        echo "Error: Nginx is not installed."
        exit 1
    fi

    log "Displaying details for Nginx domain $domain"
    echo "Details for Nginx domain $domain:"
    grep -r "server_name $domain" /etc/nginx/sites-enabled/ | tee -a $LOG_FILE
}

list_users() {
    if ! command_exists lastlog; then
        log "Error: lastlog command is not installed."
        echo "Error: lastlog command is not installed."
        exit 1
    fi

    log "Listing users and their last login times"
    echo "Users and their last login times:"
    lastlog | tee -a $LOG_FILE
}

user_details() {
    local username=$1
    if ! command_exists finger; then
        log "Error: finger command is not installed."
        echo "Error: finger command is not installed."
        exit 1
    fi

    log "Displaying details for user $username"
    echo "Details for user $username:"
    finger $username | tee -a $LOG_FILE
}

time_range() {
    local start_time=$1
    local stop_time=$2
    if ! command_exists journalctl; then
        log "Error: journalctl command is not installed."
        echo "Error: journalctl command is not installed."
        exit 1
    fi

    log "Displaying activities from $start_time to $stop_time"
    echo "Activities from $start_time to $stop_time:"
    journalctl --since="$start_time" --until="$stop_time" | tee -a $LOG_FILE
}

# If no options are supplied, show help message
if [[ "$#" -eq 0 ]]; then
    show_help
    exit 1
fi

while [[ "$1" != "" ]]; do
    case $1 in
        -p | --port )
            shift
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                port_details $1
            else
                list_ports
            fi
            ;;
        -d | --docker )
            shift
            if [[ "$1" != "" && "$1" != -* ]]; then
                docker_details $1
            else
                list_docker
            fi
            ;;
        -n | --nginx )
            shift
            if [[ "$1" != "" && "$1" != -* ]]; then
                nginx_details $1
            else
                list_nginx
            fi
            ;;
        -u | --users )
            shift
            if [[ "$1" != "" && "$1" != -* ]]; then
                user_details $1
            else
                list_users
            fi
            ;;
        -t | --time )
            shift
            start_time=$1
            shift
            stop_time=$1
            time_range "$start_time" "$stop_time"
            exit
            ;;
        -i | --install )
            install_missing_services
            exit
            ;;
        -h | --help )
            show_help
            exit
            ;;
        * )
            show_help
            exit 1
    esac
    shift
done