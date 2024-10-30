#!/bin/bash
# Script global pour lancer les services de sécurité, vérifier l'anonymat et activer la connexion internet

# Fonction pour vérifier le statut d'un service
check_service_status() {
    if ! systemctl is-active --quiet $1; then
        echo "Erreur : $1 n'a pas démarré correctement."
        exit 1
    else
        echo "$1 est actif."
    fi
}

# Étape 1 : Démarrage des services de sécurité
echo "Démarrage de dnscrypt-proxy..."
sudo systemctl start dnscrypt-proxy
check_service_status dnscrypt-proxy

echo "Démarrage de Tor..."
sudo systemctl start tor
check_service_status tor

echo "Démarrage de OpenVPN..."
sudo openvpn --config /etc/openvpn/protonvpn.ovpn --auth-user-pass /etc/openvpn/vpn_proton_credentials.txt --daemon
sleep 5  # Attendre pour l'établissement de la connexion VPN
check_service_status openvpn

# Étape 2 : Vérifications des paramètres d’anonymat
echo "Lancement des vérifications d’anonymat..."

# Vérification IP
CURRENT_IP=$(curl -s ifconfig.me)
echo "IP actuelle : $CURRENT_IP"
if [[ "$CURRENT_IP" != "Ton_IP_VPN" ]]; then
    echo "ALERTE : L'IP n'est pas celle du VPN !"
    exit 1
fi

# Vérification des DNS
DNS_SERVERS=$(dig +short example.com)
echo "Serveurs DNS utilisés : $DNS_SERVERS"
if [[ "$DNS_SERVERS" != *"127.0.2.1"* ]]; then
    echo "ALERTE : Fuite DNS détectée !"
    exit 1
fi

# Vérification de l'adresse MAC
CURRENT_MAC=$(ifconfig wlan0 | grep ether | awk '{print $2}')
echo "Adresse MAC actuelle : $CURRENT_MAC"
if [[ "$CURRENT_MAC" == "Ton_adresse_MAC_vraie" ]]; then
    echo "ALERTE : L'adresse MAC n'a pas été changée !"
    exit 1
fi

echo "Toutes les vérifications ont été validées avec succès."

# Étape 3 : Activation de la connexion Wi-Fi
echo "Activation de la connexion Wi-Fi..."
nmcli device wifi connect "SSID" password "PASSWORD"  # Remplace "SSID" et "PASSWORD" par tes informations Wi-Fi

echo "Connexion internet activée."
