#!/bin/bash

# Installation d'Elasticsearch
install_elasticsearch() {
    echo "Téléchargement et installation d'Elasticsearch version $ELASTICSEARCH_VERSION..."

    case $OS in
        "Ubuntu" | "Debian GNU/Linux")
            apt-get update  
            wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
            echo "deb https://artifacts.elastic.co/packages/$ELASTICSEARCH_VERSION/apt stable main" | tee /etc/apt/sources.list.d/elastic-$ELASTICSEARCH_VERSION.list
            apt-get update && apt-get install -y elasticsearch 
            ;;
        "CentOS Linux" | "Fedora" | "RHEL")
            yum update && yum install -y vim curl gnupg gpg wget net-tools nano dos2unix 
            rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
            cat <<EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for $ELASTICSEARCH_VERSION packages
baseurl=https://artifacts.elastic.co/packages/$ELASTICSEARCH_VERSION/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
            yum install --enablerepo=elasticsearch elasticsearch
            ;;
    esac

    # Vérification de l'installation réussie de Elasticsearch
    if [ ! -d /etc/elasticsearch ]; then
        echo "Erreur : Échec de l'installation d'Elasticsearch."
        exit 1
    fi

    echo "Installation d'Elasticsearch réussie."
}

# Installation de Kibana
install_kibana() {
    echo "Téléchargement et installation de Kibana version $KIBANA_VERSION..."

    case $OS in
        "Ubuntu" | "Debian GNU/Linux")
            echo "Installation de kibana..."
            apt install -y kibana
            ;;
        "CentOS Linux" | "Fedora" | "RHEL")
            echo "Installation de kibana..."
            yum install -y kibana
            ;;
        *)
            echo "Distribution non supportée pour l'installation de Kibana."
            exit 1
            ;;
    esac

    # Vérification de l'installation réussie de Kibana
    if [ ! -d /etc/kibana ]; then
        echo "Erreur : Échec de l'installation de Kibana."
        exit 1
    fi

    echo "Installation de Kibana réussie."
}

# Installation de Logstash
install_logstash() {
    echo "Téléchargement et installation de Logstash version $LOGSTASH_VERSION..."

    case $OS in
        "Ubuntu" | "Debian GNU/Linux")
            echo "Installation de Logstash..."
            apt-get install -y logstash
            ;;
        "CentOS Linux" | "Fedora" | "RHEL")
            echo "Installation de Logstash..."
            yum install -y logstash
            ;;
        *)
            echo "Distribution non supportée pour l'installation de Logstash."
            exit 1
            ;;
    esac

    # Vérification de l'installation réussie de Logstash
    if [ ! -d /etc/logstash ]; then
        echo "Erreur : Échec de l'installation de Logstash."
        exit 1
    fi

    echo "Installation de Logstash réussie."
}

main() {
    install_java
    install_elasticsearch
    install_kibana
    install_logstash
}
main
