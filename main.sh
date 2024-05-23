#!/bin/bash

# Chemins vers les répertoires de configuration et de scripts
CONFIGURATION_DIR="./configuration"
SCRIPTS_DIR="./scripts"

# Inclure le script utils.sh
source "$SCRIPTS_DIR/utils.sh"

# Vérifier si l'utilisateur a les droits administratifs
veirifier_root

# Détection de la distribution Linux
detect_linux_distribution

# Exemple d'appel de la fonction install_java
install_java

# Charger les variables d'environnement depuis le fichier .env
load_environment_variables

# Appel des autres scripts
source "$SCRIPTS_DIR/download.sh"
source "$CONFIGURATION_DIR/configuration.sh"
source "$SCRIPTS_DIR/start.sh"
