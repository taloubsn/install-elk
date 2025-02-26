# Configuration pour Elasticsearch, Kibana et Logstash

## Auteur
Ce script a été créé par Abibou Diallo, Ingénieur Analyste SOC.

## Description

Ce script configure Elasticsearch, Kibana et Logstash sur une seule machine en fonction des paramètres spécifiés dans le fichier .env et effectue diverses tâches telles que la génération de certificats, la configuration des fichiers de configuration et l'installation de plugins pour l'integration avec wazuh.

Nous allons installer et configurer une stack Elastic (Elasticsearch, Kibana et Logstash) avec des certificats auto-signés pour sécuriser les communications entre les différents composants.
Ce script a été testé sur centos7 et Ubuntu

## Pré-requis
- Système d'exploitation Centos 7 ou ubuntu/20/22
- Accès root ou sudo

## Exigences Matérielles
Pour une installation optimale, la machine doit répondre aux exigences suivantes :
- CPU: 8 cœurs ou plus
- RAM: Minimum 16 Go
- Stockage: Minimum 100 Go

## Utilisation
1. Assurez-vous d'avoir défini les variables nécessaires dans le fichier .env avant d'exécuter ce script.
2. Exécutez le script en tant qu'utilisateur avec les privilèges suffisants.


## Avertissement
Ce script est fourni tel quel, sans aucune garantie. Veuillez l'utiliser avec précaution et assurez-vous de comprendre son fonctionnement avant de l'exécuter.

## Installation
Pour installer et utiliser ce script :
1. Clonez ce dépôt Git sur votre machine locale :
   ```bash
   git clone https://github.com/taloubsn/install-elk.git
   cd votre-depot
   cp env.sample .env #modifier .env selon vos préférences n oublier pas de modifier la valeur IP_ADDRESS à celle de votre machine
   chmod +x main.sh
   sudo ./main.sh

## Réinitialisation du mot de passe Elasticsearch

Si vous n'avez pas sauvegardé le mot de passe généré pour Elasticsearch lors de l'installation, vous pouvez le réinitialiser en exécutant la commande suivante :
1. Command:
   ```bash
   /usr/share/elasticsearch/bin/elasticsearch-reset-password -i -u elastic --url https://ip_address:http_port


## Kibana URL
Après l'installation, vous pouvez accéder à Kibana via l'URL suivante : https://votre-adresse-ip:5601
N'oubliez pas de remplacer `votre-adresse-ip` par l'adresse IP de votre serveur où Kibana est installé. 'username' : elastic et 'password' : celui généré lors de l'installation ou ce que vous venez juste de réinitialiser
N'oublier pas d'autoriser le port de kibana si le firewall est activer
Exemple centos 7 
1. Command:
   ```bash
   firewall-cmd --zone=public --add-port=5601/tcp --permanent
   firewall-cmd --reload

## Contributions
Les contributions sont les bienvenues ! Si vous avez des suggestions d'amélioration, veuillez ouvrir une 
issue ou soumettre une pull request ou envoyer un mail à taloubsn@gmail.com

