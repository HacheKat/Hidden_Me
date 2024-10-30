#!/bin/bash

# Dossiers et chemins
PACKAGE_DIR="./offline_packages"
CONFIG_DIR="./config"
SERVICE_DIR="./systemd_services"
BACKUP_DIR="./backup"

# Fichiers de configuration source et destination
VPN_CONFIG_SOURCE="$CONFIG_DIR/protonvpn.ovpn"
VPN_CREDENTIALS_SOURCE="$CONFIG_DIR/vpn_proton_credentials.txt"
DNSCRYPT_CONFIG_SOURCE="$CONFIG_DIR/dnscrypt-proxy.toml"
PROXYCHAINS_CONFIG_SOURCE="$CONFIG_DIR/proxychains.conf"
PROXYCHAINS4_CONFIG_SOURCE="$CONFIG_DIR/proxychains4.conf"
TORRC_SOURCE="$CONFIG_DIR/torrc"

VPN_CONFIG_DEST="/etc/openvpn/protonvpn.ovpn"
VPN_CREDENTIALS_DEST="/etc/openvpn/vpn_proton_credentials.txt"
DNSCRYPT_CONFIG_DEST="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
PROXYCHAINS_CONFIG_DEST="/etc/proxychains.conf"
PROXYCHAINS4_CONFIG_DEST="/etc/proxychains4.conf"
TORRC_DEST="/etc/tor/torrc"

# Installation des paquets requis depuis le dossier hors ligne
echo "Installation des paquets requis depuis le dossier hors ligne..."
sudo dpkg -i "$PACKAGE_DIR"/*.deb || echo "Installation partiellement terminée - des paquets peuvent manquer"

# Vérification et installation de resolvconf si nécessaire
if ! which resolvconf &> /dev/null; then
    echo "Installation de resolvconf car il est requis par OpenVPN..."
    sudo apt update && sudo apt install -y resolvconf
fi

# Fonction pour sauvegarder et copier un fichier de configuration
sauvegarder_et_copier() {
    local source_file=$1
    local dest_file=$2

    # Sauvegarder le fichier existant s'il est présent
    if [ -f "$dest_file" ]; then
        sudo cp "$dest_file" "$BACKUP_DIR/$(basename $dest_file).original.$(date +%F_%T)"
    fi
    
    # Copier le fichier de configuration
    sudo cp "$source_file" "$dest_file"
    sudo chmod 600 "$dest_file"
}

# Copie des fichiers de configuration VPN, Proxychains, Tor, et DNSCrypt
echo "Copie des fichiers de configuration aux emplacements requis..."
sauvegarder_et_copier "$VPN_CONFIG_SOURCE" "$VPN_CONFIG_DEST"
sauvegarder_et_copier "$VPN_CREDENTIALS_SOURCE" "$VPN_CREDENTIALS_DEST"
sauvegarder_et_copier "$PROXYCHAINS_CONFIG_SOURCE" "$PROXYCHAINS_CONFIG_DEST"
sauvegarder_et_copier "$PROXYCHAINS4_CONFIG_SOURCE" "$PROXYCHAINS4_CONFIG_DEST"
sauvegarder_et_copier "$DNSCRYPT_CONFIG_SOURCE" "$DNSCRYPT_CONFIG_DEST"
sauvegarder_et_copier "$TORRC_SOURCE" "$TORRC_DEST"

# Fonction pour copier l'exécutable dnscrypt-proxy
installer_executable_dnscrypt() {
    local source_exe="$CONFIG_DIR/dnscrypt-proxy"
    local dest_exe="/usr/local/bin/dnscrypt-proxy"

    # Copier l'exécutable
    sudo cp "$source_exe" "$dest_exe"
    sudo chmod +x "$dest_exe"
}

# Installation de l'exécutable dnscrypt-proxy
echo "Installation de l'exécutable dnscrypt-proxy..."
installer_executable_dnscrypt

# Création du dossier de service Hidden_Me et copie des fichiers de service et script
echo "Création du dossier /etc/systemd/system/Hidden_Me et copie des fichiers de service et script..."
sudo mkdir -p /etc/systemd/system/Hidden_Me

# Copie du service Hidden_Me.service
sudo cp "$SERVICE_DIR/Hidden_Me.service" /etc/systemd/system/

# Copie du script start_hidden_me.sh dans le dossier Hidden_Me
sudo cp "$SERVICE_DIR/start_hidden_me.sh" /etc/systemd/system/Hidden_Me/start_hidden_me.sh
sudo chmod +x /etc/systemd/system/Hidden_Me/start_hidden_me.sh

# Activer Hidden_Me.service pour démarrer les services dans l'ordre
echo "Activation de Hidden_Me.service au démarrage..."
sudo systemctl daemon-reload
sudo systemctl enable Hidden_Me.service

# Désactivation de l'IPv6 pour éviter les fuites
echo "Désactivation de l'IPv6 pour éviter les fuites..."
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "Installation et configuration initiales terminées."

