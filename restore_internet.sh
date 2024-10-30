#!/bin/bash

echo "Restauration des configurations réseau et rétablissement de la connexion Internet..."

# 1. Désactiver le Kill Switch (pare-feu UFW)
echo "Désactivation du Kill Switch UFW..."
sudo ufw disable
echo "Pare-feu UFW désactivé."

# 2. Arrêter le VPN
echo "Arrêt du VPN (OpenVPN)..."
sudo pkill openvpn
echo "VPN arrêté."

# 3. Arrêter le service Tor
echo "Arrêt du service Tor..."
sudo systemctl stop tor
echo "Service Tor arrêté."

# 4. Arrêter dnscrypt-proxy
echo "Arrêt de dnscrypt-proxy..."
sudo systemctl stop dnscrypt-proxy
echo "Service dnscrypt-proxy arrêté."

# 5. Réinitialisation des DNS si nécessaire
echo "Réinitialisation de la configuration DNS..."
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
echo "Configuration DNS réinitialisée avec les DNS Google."

# 6. Vérification de la connexion Internet
echo "Vérification de la connexion Internet..."
if curl -s ifconfig.me &> /dev/null; then
    echo "Connexion Internet restaurée avec succès."
else
    echo "Erreur : Impossible de restaurer la connexion Internet. Veuillez vérifier manuellement."
fi

