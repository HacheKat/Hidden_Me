# Projet HideMe

Ce projet a pour but de créer un environnement sécurisé et anonyme en configurant plusieurs services (VPN, Tor, Proxychains, DNSCrypt) avec une surveillance continue pour éviter les fuites d’informations et maintenir la sécurité réseau.

## Structure du Projet

- `install_and_configure.sh` : Script d'installation initiale et configuration.
- `startup_check_and_connect.sh` : Script de connexion et vérifications au démarrage (sera ajouté plus tard).
- `sentinel_monitoring.sh` : Script de surveillance en continu pour détecter les anomalies réseau (sera ajouté plus tard).
- `config/` : Contient les fichiers de configuration nécessaires.
- `offline_packages/` : Dossier pour les paquets nécessaires à une installation hors ligne.
- `logs/` : Contient les fichiers logs pour surveiller les activités et incidents réseau.
- `backup/` : Dossier pour sauvegarder les fichiers de configuration système, en version originale et modifiée.

---

## Étape 1 : Préparation et Installation Initiale

### Pré-requis

1. **Dépendances hors ligne** :
   - Assurez-vous que les paquets nécessaires (en format `.deb`) sont présents dans le dossier `offline_packages`. Ces paquets permettent une installation sans connexion internet.
   - Liste des paquets à inclure :
     - `openvpn`
     - `tor`
     - `proxychains`
     - `dnscrypt-proxy`
     - Autres paquets spécifiques en fonction de vos besoins

2. **Fichiers de Configuration** :
   - Placez les fichiers suivants dans le dossier `config/` :
     - **`protonvpn.ovpn`** : Fichier de configuration VPN pour ProtonVPN.
       - Ce fichier doit être téléchargé depuis votre compte ProtonVPN.
       - Vérifiez que le fichier est bien configuré avec les bons serveurs.
     - **`vpn_proton_credentials.txt`** : Fichier texte contenant les identifiants pour ProtonVPN.
       - Format attendu :
         ```
         utilisateur_vpn
         mot_de_passe_vpn
         ```

### Exécution de l’Étape 1

Si les fichiers et dépendances sont en place, lancez le premier script `install_and_configure.sh` pour installer les paquets et configurer les services de base.

### Commandes

```bash
# executer le script
chmod +x install_and_configure.sh && sudo ./install_and_configure.sh
```


