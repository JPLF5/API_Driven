#!/bin/bash

DIR="rep_localstack"

echo "🔍 Vérification de l'environnement..."

if [ -d "$DIR" ]; then
    echo "✅ Le dossier $DIR existe déjà. On passe l'installation."
else
    echo "⚙️ Création de l'environnement virtuel..."

    sudo mkdir -p $DIR
    sudo python3 -m venv $DIR
    
    echo "⬇️ Installation des dépendances (LocalStack)..."

    sudo ./$DIR/bin/pip install --upgrade pip
    sudo ./$DIR/bin/pip install localstack awscli-local
    
    echo "✅ Installation terminée."
fi

sudo chmod -R 777 $DIR
