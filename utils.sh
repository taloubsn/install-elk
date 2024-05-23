#!/bin/bash

# Détection de la distribution Linux
detect_linux_distribution() {
    if [ -f /etc/os-release ]; then
        # Extraction des informations à partir du fichier /etc/os-release
        . /etc/os-release
        if [ -n "$NAME" ] && [ -n "$VERSION_ID" ]; then
            OS=$NAME
            VERSION=$VERSION_ID
        else
            echo "Erreur : Les variables NAME et VERSION_ID ne sont pas définies dans /etc/os-release."
            exit 1
        fi
    elif type lsb_release >/dev/null 2>&1; then
        # Utilisation de la commande lsb_release pour obtenir les informations de distribution
        OS=$(lsb_release -si)
        VERSION=$(lsb_release -sr)
    else
        # Utilisation de la commande uname comme dernière tentative pour obtenir les informations de distribution
        OS=$(uname -s)
        VERSION=$(uname -r)
    fi

    # Vérification si la distribution Linux est détectée correctement
    if [ -z "$OS" ]; then
        echo "Erreur : Impossible de détecter la distribution Linux."
        exit 1
    fi

    echo "Distribution détectée : $OS $VERSION"
}

# Charger les variables d'environnement depuis le fichier .env
load_environment_variables() {
    if [ -f .env ]; then
        dos2unix .env
        sed -i 's/\r//'
        source .env
        if [ -z "$CLUSTER_NAME" ] || [ -z "$IP_ADDRESS" ] || [ -z "$HTTP_PORT" ] || [ -z "$KIBANA_SERVER_PORT" ] || [ -z "$KIBANA_SERVER_HOST" ]; then
            echo "Erreur : Certaines variables d'environnement ne sont pas définies correctement dans le fichier .env."
            exit 1
        fi
    else
        echo "Attention : Le fichier .env n'existe pas. Assurez-vous de définir les variables d'environnement correctement."
        exit 1
    fi

    # Vérifier si l'utilisateur a les droits administratifs
    if [ "$(id -u)" -ne 0 ]; then
        echo "Ce script doit être exécuté en tant qu'administrateur" 1>&2
        exit 1
    fi
}

# Vérifier si l'utilisateur a les droits administratifs
veirifier_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Ce script doit être exécuté en tant qu'administrateur" 1>&2
        exit 1
    fi
}

# Fonction pour vérifier si une commande est disponible
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Erreur : La commande $1 n'est pas disponible. Assurez-vous qu'elle est installée."
        exit 1
    fi
}

# Installation de Java
install_java() {
    echo "Installation de Java..."

    # Vérification de la disponibilité de la commande apt ou yum
    if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian GNU/Linux" ]; then
        check_command "apt-get"
    elif [ "$OS" = "CentOS Linux" ] || [ "$OS" = "Fedora" ] || [ "$OS" = "RHEL" ]; then
        check_command "yum"
    else
        echo "Distribution non supportée pour l'installation de Java."
        exit 1
    fi

    # Installation de Java
    case $OS in
        "Ubuntu" | "Debian GNU/Linux")
            apt-get update && apt-get dist-upgrade && apt-get install -y vim curl gnupg gpg wget net-tools nano apt-transport-https dos2unix unzip
            DEBIAN_FRONTEND=noninteractive apt-get install -yq default-jre
            ;;
        "CentOS Linux" | "Fedora" | "RHEL")
            yum update && yum install -y java-11-openjdk && yum install -y vim curl gnupg gpg wget net-tools nano apt-transport-https dos2unix unzip
            ;;
    esac

    # Vérification de l'installation réussie de Java
    check_command "java"

    echo "Installation de Java réussie."
}

# Autres fonctions...

# Appel des fonctions
# detect_linux_distribution
# load_environment_variables

# Autres appels de fonction...
