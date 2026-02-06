# 🚀 API-Driven Infrastructure - LocalStack

> **Orchestration de services AWS via API Gateway et Lambda dans un environnement émulé**

Ce projet implémente une architecture **API-driven** où une simple requête HTTP peut **démarrer** ou **arrêter** une instance EC2, le tout orchestré par **API Gateway** et **Lambda**, dans un environnement **LocalStack** exécuté sur **GitHub Codespaces**.

![Architecture](API_Driven.png)

---

## 📋 Table des matières

- [Prérequis](#-prérequis)
- [Démarrage rapide](#-démarrage-rapide)
- [Architecture technique](#-architecture-technique)
- [Structure du projet](#-structure-du-projet)
- [Commandes Makefile](#-commandes-makefile)
- [Utilisation de l'API](#-utilisation-de-lapi)
- [Dépannage](#-dépannage)

---

## 🔧 Prérequis

- **GitHub Codespaces** (recommandé) ou un environnement Linux avec Docker
- Python 3.x
- pip

---

## ⚡ Démarrage rapide

### 1️⃣ Créer un Codespace

1. Rendez-vous sur [GitHub Codespaces](https://github.com/features/codespaces)
2. Créez un nouveau Codespace connecté à ce repository

### 2️⃣ Lancer l'installation complète

Dans le terminal du Codespace, exécutez simplement :

```bash
make all
```

Cette commande exécute automatiquement :
- ✅ Installation des dépendances (awscli, localstack)
- ✅ Démarrage de LocalStack
- ✅ Création d'une instance EC2
- ✅ Déploiement de la fonction Lambda
- ✅ Configuration de l'API Gateway

### 3️⃣ Rendre le port public

> ⚠️ **Important** : Dans l'onglet **PORTS** de Codespaces, rendez le port **4566** **public** pour pouvoir accéder à l'API.

### 4️⃣ Tester l'API

À la fin du déploiement, le script affiche les commandes `curl` prêtes à l'emploi :

```bash
# Démarrer l'instance EC2
curl "https://votre-codespace-4566.app.github.dev/restapis/xxx/prod/_user_request_/?action=start"

# Arrêter l'instance EC2
curl "https://votre-codespace-4566.app.github.dev/restapis/xxx/prod/_user_request_/?action=stop"
```

---

## 🏗 Architecture technique

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Client HTTP   │────▶│   API Gateway   │────▶│     Lambda      │
│   (curl/browser)│     │   (GET /)       │     │ (GestionEC2)    │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                                         ▼
                                                ┌─────────────────┐
                                                │   Instance EC2  │
                                                │   start/stop    │
                                                └─────────────────┘
```

### Flux de données

1. **Requête HTTP** → L'utilisateur envoie une requête GET avec `?action=start` ou `?action=stop`
2. **API Gateway** → Reçoit la requête et la transmet à la fonction Lambda
3. **Lambda** → Exécute l'action demandée sur l'instance EC2 (via boto3)
4. **Réponse JSON** → Retourne le statut de l'opération

---

## 📁 Structure du projet

```
API_Driven/
├── Makefile              # Automatisation des commandes
├── install.sh            # Script d'installation de LocalStack
├── deploy_api.sh         # Script de déploiement complet
├── lambda_function.py    # Code de la fonction Lambda
├── README.md             # Cette documentation
└── API_Driven.png        # Schéma d'architecture
```

### Description des fichiers

| Fichier | Description |
|---------|-------------|
| `Makefile` | Orchestre toutes les commandes (install, init, deploy, clean) |
| `install.sh` | Crée l'environnement virtuel et installe LocalStack |
| `deploy_api.sh` | Crée l'EC2, déploie Lambda et configure API Gateway |
| `lambda_function.py` | Fonction Lambda qui pilote l'instance EC2 |

---

## 🛠 Commandes Makefile

| Commande | Description |
|----------|-------------|
| `make help` | Affiche l'aide avec toutes les commandes disponibles |
| `make install` | Installe les dépendances (awscli, localstack) |
| `make init` | Démarre LocalStack en arrière-plan |
| `make deploy` | Déploie l'infrastructure (EC2 + Lambda + API Gateway) |
| `make status` | Vérifie le statut des services LocalStack |
| `make clean` | Nettoie complètement l'environnement |
| `make all` | **Exécute tout** : install → init → deploy |

### Exemple d'utilisation

```bash
# Installation et déploiement complet
make all

# Vérifier que LocalStack fonctionne
make status

# Nettoyer pour recommencer
make clean
```

---

## 📡 Utilisation de l'API

### Endpoints disponibles

| Action | Paramètre | Description |
|--------|-----------|-------------|
| Démarrer | `?action=start` | Démarre l'instance EC2 |
| Arrêter | `?action=stop` | Arrête l'instance EC2 |

### Exemples de requêtes

```bash
# Démarrer l'instance
curl "https://<codespace>-4566.app.github.dev/restapis/<api-id>/prod/_user_request_/?action=start"

# Arrêter l'instance
curl "https://<codespace>-4566.app.github.dev/restapis/<api-id>/prod/_user_request_/?action=stop"
```

### Réponses attendues

**Succès :**
```json
{
  "status": "success",
  "message": "Cible : i-xxx. Action : start. Instance demarree."
}
```

**Erreur (action invalide) :**
```json
{
  "status": "success",
  "message": "Cible : i-xxx. Action : invalid. Utilisez ?action=start ou stop."
}
```

---

## 🔍 Dépannage

### LocalStack ne démarre pas

```bash
# Vérifier le statut
localstack status services

# Redémarrer proprement
make clean
make all
```

### L'API retourne une erreur 403

➡️ Assurez-vous que le port **4566** est bien **public** dans l'onglet PORTS de Codespaces.

### La fonction Lambda ne trouve pas l'instance

➡️ L'ID de l'instance est injecté automatiquement lors du déploiement. Relancez :

```bash
make deploy
```

---

## 📚 Technologies utilisées

- **LocalStack** - Émulateur AWS local
- **AWS Lambda** - Fonction serverless
- **AWS API Gateway** - Point d'entrée HTTP
- **AWS EC2** - Instance virtuelle à piloter
- **Python 3 / boto3** - SDK AWS pour Python
- **GitHub Codespaces** - Environnement de développement cloud

---

## 👤 Auteur

Projet réalisé dans le cadre du cours **STAAOC - Orchestration et Conteneurisation Avancée**.
