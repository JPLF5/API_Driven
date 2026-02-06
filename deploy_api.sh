#!/bin/bash

FUNCTION_NAME="GestionEC2"
API_NAME="EC2ControllerAPI"
REGION="us-east-1"
STAGE="prod"

echo "🧹 Nettoyage préventif (suppression des anciennes ressources)..."
# On supprime sans vérifier si ça existe (pour éviter les erreurs d'existant)
awslocal lambda delete-function --function-name $FUNCTION_NAME > /dev/null 2>&1
awslocal apigateway delete-rest-api --rest-api-id $(awslocal apigateway get-rest-apis --query "items[?name=='$API_NAME'].id" --output text) > /dev/null 2>&1
rm -f function.zip

echo "🚀 1. Démarrage d'une nouvelle Instance EC2..."
# Création et récupération immédiate de l'ID
INSTANCE_ID=$(awslocal ec2 run-instances \
    --image-id ami-ff0000 \
    --count 1 \
    --instance-type t2.micro \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "✅ Instance créée avec succès : $INSTANCE_ID"

echo "📦 2. Packaging de la Lambda..."
zip function.zip lambda_function.py > /dev/null

echo "🔧 3. Déploiement de la Lambda avec Injection de l'ID..."
# C'est ici qu'on passe la variable d'environnement --environment
awslocal lambda create-function \
    --function-name $FUNCTION_NAME \
    --runtime python3.9 \
    --zip-file fileb://function.zip \
    --handler lambda_function.lambda_handler \
    --role arn:aws:iam::000000000000:role/lambda-role \
    --environment Variables="{TARGET_INSTANCE_ID=$INSTANCE_ID}"

echo "🌐 4. Configuration API Gateway..."
API_ID=$(awslocal apigateway create-rest-api --name "$API_NAME" --query 'id' --output text)
PARENT_ID=$(awslocal apigateway get-resources --rest-api-id $API_ID --query 'items[0].id' --output text)

awslocal apigateway put-method \
    --rest-api-id $API_ID \
    --resource-id $PARENT_ID \
    --http-method GET \
    --authorization-type "NONE"

LAMBDA_ARN=$(awslocal lambda get-function --function-name $FUNCTION_NAME --query 'Configuration.FunctionArn' --output text)

awslocal apigateway put-integration \
    --rest-api-id $API_ID \
    --resource-id $PARENT_ID \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations

awslocal apigateway create-deployment --rest-api-id $API_ID --stage-name $STAGE

echo ""
echo "🎉 DEPLOIEMENT TERMINE !"
echo "--------------------------------------------------"
echo "Instance ID pilotée : $INSTANCE_ID"
echo "URL API : http://localhost:4566/restapis/$API_ID/$STAGE/_user_request_/?action=stop"
echo "--------------------------------------------------"
