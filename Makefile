SHELL := /bin/bash

.PHONY: install init deploy clean status help all

# --- AIDE ---
help:
	@echo "Commandes disponibles :"
	@echo "  make install  - Installe les dépendances"
	@echo "  make init     - Démarre LocalStack"
	@echo "  make deploy   - Déploie l'infrastructure"
	@echo "  make status   - Vérifie le statut de LocalStack"
	@echo "  make clean    - Nettoie l'environnement"
	@echo "  make all      - Exécute tout (install + init + deploy)"

# --- 1. INSTALLATION ---
install:
	@echo "--- 📦 Installation des pré-requis ---"
	pip install awscli awscli-local
	./install.sh

# --- 2. DEMARRAGE ---
init:
	@echo "--- 🚀 Démarrage de LocalStack ---"
	source rep_localstack/bin/activate && export S3_SKIP_SIGNATURE_VALIDATION=0 && localstack start -d
	@echo "⏳ Attente que les services soient prêts..."
	sleep 10

# --- 3. DÉPLOIEMENT ---
deploy:
	@echo "--- 🏗 Déploiement de l'infrastructure ---"
	chmod +x deploy_api.sh
	./deploy_api.sh

# --- 4. STATUS ---
status:
	@echo "--- 📊 Statut des services ---"
	localstack status services

# --- 5. NETTOYAGE ---
clean:
	@echo "--- 🧹 Nettoyage complet ---"
	localstack stop || true
	sudo rm -rf rep_localstack
	rm -f function.zip
	@echo "✅ Environnement nettoyé."

# --- COMMANDE TOUT-EN-UN ---
all: install init deploy