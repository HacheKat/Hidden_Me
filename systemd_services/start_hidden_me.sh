#!/bin/bash

# Fonction pour vérifier le statut d'un service
check_service_status() {
    if ! systemctl is-active --quiet "$1"; then
        echo "Erreur : $1 n'a pas démarré correctement."
        exit 1
    else
        echo "$1 est actif."
    fi
}

# Fonction pour vérifier et afficher l'IP actuelle
check_ip() {
    local description="$1"
    local ip=$(curl -s ifconfig.me)
    echo "$description - Adresse IP actuelle : $ip"
    echo "$ip"
}

# 1. Vérification de l'IP brute
echo "Vérification de l'IP brute..."
ip_brute=$(check_ip "IP brute initiale")

# 2. Démarrage du VPN et vérification de l'IP
echo "Démarrage du VPN avec OpenVPN en mode permanent..."
sudo openvpn --config /etc/openvpn/protonvpn.ovpn --auth-user-pass /etc/openvpn/vpn_proton_credentials.txt --daemon
sleep 5  # Attendre que la connexion VPN s'établisse
ip_vpn=$(check_ip "Après connexion VPN")

if [ "$ip_brute" = "$ip_vpn" ]; then
    echo "Erreur : l'IP n'a pas changé après la connexion VPN."
    exit 1
else
    echo "Connexion VPN établie avec succès, l'IP a changé."
fi

# 3. Démarrage de Tor et vérification de l'IP
echo "Démarrage de Tor..."
sudo systemctl start tor
check_service_status tor
sleep 5  # Attendre le démarrage de Tor
ip_tor=$(check_ip "Après démarrage de Tor")

if [ "$ip_vpn" = "$ip_tor" ] || [ "$ip_brute" = "$ip_tor" ]; then
    echo "Erreur : l'IP n'a pas changé après le démarrage de Tor."
    exit 1
else
    echo "Tor est actif, l'IP a changé après Tor."
fi

# 4. Vérification et activation du Kill Switch avec UFW
echo "Vérification de l'état actuel du pare-feu UFW..."
if ! sudo ufw status | grep -q "active"; then
    echo "Activation et configuration du pare-feu UFW avec Kill Switch..."
    sudo ufw enable
    sudo ufw default deny incoming
    sudo ufw default deny outgoing  # Bloquer tout sortant par défaut

    # Autoriser les services nécessaires
    sudo ufw allow out on tun0    # Autoriser uniquement le VPN pour le trafic sortant
    sudo ufw allow out 9050/tcp   # Port de Tor pour Proxychains
    sudo ufw allow out 53/tcp     # Port DNS pour dnscrypt-proxy
    sudo ufw reload
else
    echo "Le pare-feu UFW est déjà actif avec le Kill Switch."
fi
echo "Statut UFW :"
sudo ufw status verbose

# 5. Test de Proxychains avec le VPN et Tor actifs
echo "Test de Proxychains avec VPN et Tor actifs..."
proxychains4_ip=$(proxychains4 curl -s ifconfig.me)

if [ "$proxychains4_ip" = "$ip_tor" ] || [ "$proxychains4_ip" = "$ip_brute" ] || [ "$proxychains4_ip" = "$ip_vpn" ]; then
    echo "Erreur : l'IP avec Proxychains n'est pas différente des IP précédentes."
    exit 1
else
    echo "Test réussi avec Proxychains, IP finale différente de toutes les précédentes : $proxychains4_ip"
fi

echo "Tous les services de sécurité sont actifs, le VPN est en cours d'exécution avec le Kill Switch, et les IP ont été vérifiées à chaque étape."

