#!/bin/bash
# Script pour changer l'adresse MAC de l'interface réseau au démarrage

INTERFACE="wlan0"
sudo ifconfig $INTERFACE down
sudo macchanger -r $INTERFACE
sudo ifconfig $INTERFACE up
