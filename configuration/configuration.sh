#!/bin/bash

# Générer un certificat auto-signé pour Elasticsearch
generate_certificate() {
    echo "Génération du certificat auto-signé pour l'adresse IP $IP_ADDRESS..."
   
    #check_command "/usr/share/elasticsearch/bin/elasticsearch-certutil"

    # Vérification et création du répertoire de certificats
    CERT_DIR="/etc/elasticsearch/certs"
    rm -rf $CERT_DIR/ca.zip $CERT_DIR/elastic.zi
    rm -rf $CERT_DIR/ca.zip $CERT_DIR/elastic.zip
    if [ ! -d "$CERT_DIR" ]; then
        mkdir -p "$CERT_DIR" || { echo "Erreur : Impossible de créer le répertoire $CERT_DIR."; exit 1; }
    fi

    # Création de l'autorité de certification (CA)
    /usr/share/elasticsearch/bin/elasticsearch-certutil ca --pem --out "$CERT_DIR/ca.zip"
    if [ $? -ne 0 ]; then
        echo "Erreur : Échec de la création de l'autorité de certification."
        exit 1
    fi
    unzip -o "$CERT_DIR/ca.zip" -d "$CERT_DIR"

    # Génération du certificat auto-signé pour l'adresse IP spécifiée
    /usr/share/elasticsearch/bin/elasticsearch-certutil cert \
        --out "$CERT_DIR/elastic.zip" \
        --name elastic \
        --ca-cert "$CERT_DIR/ca/ca.crt" \
        --ca-key "$CERT_DIR/ca/ca.key" \
        --ip "$IP_ADDRESS" \
        --pem
    if [ $? -ne 0 ]; then
        echo "Erreur : Échec de la génération du certificat."
        exit 1
    fi
    unzip -o "$CERT_DIR/elastic.zip" -d "$CERT_DIR"
    
    echo "Certificat généré avec succès dans $CERT_DIR."
}

# Configuration d'Elasticsearch pour utiliser le certificat
configure_elasticsearch() {
    echo "Configuration d'Elasticsearch..."

    # Chemin du fichier elasticsearch.yml
    ELASTICSEARCH_YML="/etc/elasticsearch/elasticsearch.yml"
    cp "$ELASTICSEARCH_YML" "$ELASTICSEARCH_YML.copy"

    # Vérifier si le fichier elasticsearch.yml existe
    if [ ! -f "$ELASTICSEARCH_YML" ]; then
        echo "Le fichier $ELASTICSEARCH_YML n'existe pas."
        exit 1
    fi

    # Nouvelles valeurs pour les variables
    MY_CLUSTER_NAME="$CLUSTER_NAME"
    NETWORK_HOST="$IP_ADDRESS"
    MY_HTTP_PORT="$HTTP_PORT"

    # Modifier les valeurs des variables dans le fichier elasticsearch.yml avec sed
    sed -i -e "s~#*\(cluster\.name:\).*~\1 $MY_CLUSTER_NAME~" \
           -e "s~#*\(network\.host:\).*~\1 $NETWORK_HOST~" \
           -e "s~#*\(http\.port:\).*~\1 $MY_HTTP_PORT~" \
           "$ELASTICSEARCH_YML"

    # Commenter la ligne contenant keystore.path: certs/http.p12
    sed -i 's~^\( *keystore\.path:\s*certs\/http\.p12\)~#\1~' "$ELASTICSEARCH_YML"

    # Ajouter les lignes dans xpack.security.transport.ssl
    awk '/^xpack\.security\.http\.ssl:/ { print; print "  certificate_authorities: certs/ca/ca.crt"; print "  certificate: certs/elastic/elastic.crt";          print "  key: certs/elastic/elastic.key"; next }1' "$ELASTICSEARCH_YML" > "$ELASTICSEARCH_YML.tmp" && mv "$ELASTICSEARCH_YML.tmp" "$ELASTICSEARCH_YML"

    echo "Les variables ont été modifiées dans le fichier $ELASTICSEARCH_YML."

    chown -R elasticsearch:elasticsearch /etc/elasticsearch
}


# Configuration de Kibana pour utiliser HTTPS avec TLS
configure_kibana() {
    echo "Configuration de Kibana..."

    # Répertoire des certificats
    CERTS_DIR="/etc/kibana/certs"
    mkdir -p "$CERTS_DIR/ca"

    # Copie des certificats depuis Elasticsearch
    cp "/etc/elasticsearch/certs/ca/ca.crt" "$CERTS_DIR/ca"
    cp "/etc/elasticsearch/certs/elastic/elastic.crt" "$CERTS_DIR/kibana.crt"
    cp "/etc/elasticsearch/certs/elastic/elastic.key" "$CERTS_DIR/kibana.key"

    echo "Certificats copiés avec succès."

    # Chemin du fichier de configuration de Kibana
    KIBANA_YML="/etc/kibana/kibana.yml"
    cp "$KIBANA_YML" "$KIBANA_YML.copy"

    # Nouvelles valeurs
    MY_SERVER_PORT="$KIBANA_SERVER_PORT"
    MY_SERVER_HOST="$KIBANA_SERVER_HOST"
    ELASTICSEARCH_HOST="$IP_ADDRESS"
    ELASTICSEARCH_PORT="$HTTP_PORT"
    CA_CERT="$CERTS_DIR/ca/ca.crt"

    # Configuration du fichier kibana.yml
    sed -i -e "s~#*\(server\.port:\).*~\1 $MY_SERVER_PORT~" \
           -e "s~#*\(server\.host:\).*~\1 \"$MY_SERVER_HOST\"~" \
           -e "s~#*\(server\.ssl\.enabled:\).*~\1 true~" \
           -e "/server\.ssl\.certificate:/a server.ssl.certificateAuthorities: \"$CA_CERT\"" \
           -e "s~#*\(server\.ssl\.certificate:\).*~\1 \"$CERTS_DIR/kibana.crt\"~" \
           -e "s~#*\(server\.ssl\.key:\).*~\1 \"$CERTS_DIR/kibana.key\"~" \
           -e "s~#*\(elasticsearch\.hosts:\).*~\1 [\"https://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT\"]~" \
           -e "s~#*\(elasticsearch\.ssl\.certificateAuthorities:\).*~\1 [\"$CA_CERT\"]~" \
           -e "s~#*\(elasticsearch\.ssl\.verificationMode:\).*~\1 full~" \
           "$KIBANA_YML"

    # Ajout de la ligne de configuration avec awk
    awk '{
    print
    if ($0 == "server.ssl.certificate: /etc/kibana/certs/kibana/kibana.crt") {
        print "server.ssl.certificateAuthorities: /etc/kibana/certs/ca/ca.crt"
    }
}' "$KIBANA_YML" 


    echo "Génération du token Elasticsearch..."
    token=$(/usr/share/elasticsearch/bin/elasticsearch-service-tokens create elastic/kibana kibana-token | awk -F' = ' '{print $2}')

    if [ $? -ne 0 ]; then
        echo "Erreur : Impossible de générer le token Elasticsearch."
        exit 1
    fi

    # Ajout du token dans Kibana
    echo "$token" | /usr/share/kibana/bin/kibana-keystore add elasticsearch.serviceAccountToken --force

    if [ $? -ne 0 ]; then
        echo "Erreur : Impossible d'ajouter le token dans Kibana."
        exit 1
    fi

    echo "Token ajouté avec succès dans Kibana."

    chown -R elasticsearch:elasticsearch /etc/elasticsearch
    chown -R kibana:kibana /etc/kibana

    echo "Modification de $KIBANA_YML terminée avec succès."
}

# Configuration de Logstash
configure_logstash() {
    # Vérification et création du répertoire /etc/logstash/certs/ca
    echo "Création du répertoire /etc/logstash/certs/ca..."
    if [ ! -d "/etc/logstash/certs/ca" ]; then
        mkdir -p /etc/logstash/certs/ca
        if [ $? -ne 0 ]; then
            echo "Erreur : Impossible de créer le répertoire /etc/logstash/certs/ca."
            exit 1
        fi
    fi

    # Copie des certificats depuis Elasticsearch vers Logstash
    echo "Copie des certificats depuis Elasticsearch vers Logstash..."
    cp /etc/elasticsearch/certs/ca/ca.crt /etc/logstash/certs/ca/
    cp /etc/elasticsearch/certs/elastic/elastic.crt /etc/logstash/certs/logstash.crt
    cp /etc/elasticsearch/certs/elastic/elastic.key /etc/logstash/certs/logstash.key

    # Vérification des opérations de copie
    if [ $? -ne 0 ]; then
        echo "Erreur : Impossible de copier les certificats depuis Elasticsearch vers Logstash."
        exit 1
    fi

    echo "Configuration de Logstash terminée avec succès."

    # Installation du plugin logstash-input-beats si ce n'est pas déjà installé
   # check_command "/usr/share/logstash/bin/logstash-plugin"
   # /usr/share/logstash/bin/logstash-plugin install logstash-input-beats
}

main() {
    generate_certificate
    configure_elasticsearch
    configure_kibana
    configure_logstash
   
}
main
