#!/bin/bash
# Script de création de l'utilisateur auget avec configuration SSH

set -e  # Arrêter le script en cas d'erreur

# Création de l'utilisateur auget
if ! id "auget" &>/dev/null; then
    sudo useradd -m -s /bin/bash auget
    echo "auget:vagrant" | sudo chpasswd
    sudo usermod -aG sudo auget
    echo "auget ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/auget
    sudo chmod 440 /etc/sudoers.d/auget
    echo "Utilisateur auget créé avec succès"
else
    echo "Utilisateur auget existe déjà"
fi

# Configuration SSH pour auget
sudo -u auget mkdir -p /home/auget/.ssh
sudo cp /tmp/id_rsa.pub /home/auget/.ssh/authorized_keys
sudo chown -R auget:auget /home/auget/.ssh
sudo chmod 700 /home/auget/.ssh
sudo chmod 600 /home/auget/.ssh/authorized_keys

# Configuration pour accepter les clés RSA (si nécessaire)
if ! grep -q "PubkeyAcceptedKeyTypes +ssh-rsa" /etc/ssh/sshd_config; then
    echo "PubkeyAcceptedKeyTypes +ssh-rsa" | sudo tee -a /etc/ssh/sshd_config
fi

sudo systemctl restart ssh

# Nettoyage des fichiers temporaires
sudo rm -f /tmp/id_rsa.pub
sudo rm -f /tmp/auget_user_creation_script.sh

echo "Configuration SSH terminée avec succès"