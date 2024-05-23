#!/bin/bash

# Inclure le script utils.sh
source ./utils.sh

#Vérifier si l'utilisateur a les droits administratifs
veirifier_root

# Détection de la distribution Linux
detect_linux_distribution

# Exemple d'appel de la fonction install_java
install_java

# Charger les variables d'environnement depuis le fichier .env
load_environment_variables

# Appel des autres scripts
source ./download.sh
source ./configuration.sh
source ./start.sh

