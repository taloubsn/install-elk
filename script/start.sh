#!/bin/bash

# Démarrage Elasticsearch
start_elasticsearch() {
    echo "Démarrage d'Elasticsearch..."

    # Démarrage du service Elasticsearch
    if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian GNU/Linux" ]; then
        systemctl daemon-reload
        systemctl enable elasticsearch
        systemctl start elasticsearch
    elif [ "$OS" = "CentOS Linux" ] || [ "$OS" = "Fedora" ] || [ "$OS" = "RHEL" ]; then
        systemctl daemon-reload
        systemctl enable elasticsearch
        systemctl start elasticsearch
    else
        echo "Distribution non supportée pour démarrer Elasticsearch."
        exit 1
    fi

    # Vérification de l'état du service Elasticsearch
    sleep 10s
    if systemctl is-active --quiet elasticsearch; then
        echo "Elasticsearch a démarré avec succès."
    else
        echo "Erreur : Échec du démarrage d'Elasticsearch."
        exit 1
    fi
}

# Démarrage Kibana
start_kibana() {
    echo "Démarrage de Kibana..."

    # Démarrage du service Kibana
    if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian GNU/Linux" ]; then
        systemctl daemon-reload
        systemctl enable kibana
        systemctl start kibana
    elif [ "$OS" = "CentOS Linux" ] || [ "$OS" = "Fedora" ] || [ "$OS" = "RHEL" ]; then
        systemctl daemon-reload
        systemctl enable kibana
        systemctl start kibana
    else
        echo "Distribution non supportée pour démarrer Kibana."
        exit 1
    fi

    # Vérification de l'état du service Kibana
    sleep 10s
    if systemctl is-active --quiet kibana; then
        echo "Kibana a démarré avec succès."
    else
        echo "Erreur : Échec du démarrage de Kibana."
        exit 1
    fi
}

# Démarrage Logstash
start_logstash() {
    echo "Démarrage de Logstash..."

    # Démarrage du service Logstash
    if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian GNU/Linux" ]; then
        systemctl daemon-reload
        systemctl enable logstash
        systemctl start logstash
    elif [ "$OS" = "CentOS Linux" ] || [ "$OS" = "Fedora" ] || [ "$OS" = "RHEL" ]; then
        systemctl daemon-reload
        systemctl enable logstash
        systemctl start logstash
    else
        echo "Distribution non supportée pour démarrer Logstash."
        exit 1
    fi

    # Vérification de l'état du service Logstash
    sleep 10s
    if systemctl is-active --quiet logstash; then
        echo "Logstash a démarré avec succès."
    else
        echo "Erreur : Échec du démarrage de Logstash."
        exit 1
    fi
}

# Fonction principale pour le démarrage des services
main() {
    start_elasticsearch
    start_kibana
    #start_logstash
}

# Exécution de la fonction principale
main
