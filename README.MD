<strong>Deploiement de cluster kubernetes automatisé via ansible</strong>
=========

Ce projet permet de déployer un cluster Kubernetes multi-nœuds en utilisant Vagrant pour l'infrastructure virtuelle et Ansible pour l'automatisation.

**Architecture du Cluster**

- 1 nœud control-plane : controlplane (192.168.56.15)
- 3 nœuds workers : worker1, worker2, worker3 (192.168.56.16-18)

**Prérequis**

Logiciels requis

- Vagrant 2.3+
- VirtualBox 7.1+
- Ansible 2.12+
- SSH keys (~/.ssh/id_rsa et ~/.ssh/id_rsa.pub)

Vérification de l'installation

```
vagrant --version
vboxmanage --version
ansible --version
```

**Structure du Projet**

```
.
├── Vagrantfile                 # Configuration des VMs
├── ansible.cfg                # Configuration Ansible
├── inventory/
│   └── hosts.yml              # Inventaire des hôtes
├── group_vars/
│   └── vbox.yml               # Variables pour les VMs
├── playbook/
│   ├── playbook-install-3k.yml    # Installation Kubernetes
│   ├── playbook-master-setup.yml  # Initialisation control-plane
│   └── playbook-workers-join.yml  # Jointure des workers
└── roles/
    └── ansible-role-k8s-install-3k/
        ├── defaults/main.yml      # Variables par défaut
        ├── vars/main.yml          # Variables fixes
        ├── tasks/main.yml         # Tâches d'installation
        └── handlers/main.yml      # Handlers systemd
```

**Déploiement**

Étape 1 : Déployer l'infrastructure virtuelle

```
cd vagrant
vagrant up
```

Étape 2 : Installer Kubernetes sur tous les nœuds

```
cd ..
ansible-playbook -i inventory/hosts.yml playbook/playbook-install-3k.yml
```

Étape 3 : Initialiser le cluster sur le control-plane

```
ansible-playbook -i inventory/hosts.yml playbook/playbook-master-setup.yml
```

Étape 4 : Joindre les workers au cluster

```
ansible-playbook -i inventory/hosts.yml playbook/playbook-workers-join.yml
```

**Configuration**

Versions installées
- Kubernetes : 1.34.1
- Containerd : 2.1.4
- CNI Plugins : 1.8.0
- Runc : 1.3.1

Réseau
- Réseau Pods : 10.244.0.0/16 (Flannel)
- Réseau Services : 10.96.0.0/12
- CNI : Flannel

**Utilisation**

Accéder au cluster

```
ssh -i ~/.ssh/id_rsa -p 2222 auget@127.0.0.1
kubectl get nodes
```

Commandes utiles

```
# Vérifier l'état du cluster
kubectl get nodes -o wide
kubectl get pods -A

# Vérifier les services système
kubectl get pods -n kube-system

# Informations sur le cluster
kubectl cluster-info
```

**Maintenance**

Redémarrer le cluster

```
cd vagrant
vagrant halt
vagrant up
```

Supprimer le cluster

```
cd vagrant
vagrant destroy -f
```

Nettoyer les configurations Kubernetes

```
ssh -i ~/.ssh/id_rsa -p 2222 auget@127.0.0.1 "sudo kubeadm reset -f"
```

**Dépannage**

Problèmes courants
1. Échec de connexion SSH

```
# Régénérer les clés SSH connues
ssh-keygen -R "[127.0.0.1]:2222"
```

2. Problèmes de réseau entre VMs

```
# Vérifier la connectivité
ansible -i inventory/hosts.yml all -a "ping -c 2 192.168.56.15" --become
```

3. Containerd ne démarre pas

```
# Redémarrer manuellement
ansible -i inventory/hosts.yml all -a "sudo systemctl restart containerd" --become
```

**Variables personnalisables**

Modifiez roles/ansible-role-k8s-install-3k/defaults/main.yml pour changer :
- Versions de Kubernetes
- Versions de Containerd
- Plages IP des réseaux

**Sécurité**

- Utilisateur dédié auget avec sudo sans mot de passe
- Clés SSH pour l'authentification
- Configuration sécurisée de Kubernetes

**Support**

1. En cas de problème, vérifiez :
2. Les logs Ansible avec -vvv
3. Les logs systemd : journalctl -u kubelet
4. L'état des pods : kubectl describe pod <pod-name>