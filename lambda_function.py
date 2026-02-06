import boto3
import json
import os

# On récupère l'ID depuis les variables d'environnement
# Si la variable n'existe pas, on met une valeur par défaut pour ne pas crasher
INSTANCE_ID = os.environ.get('TARGET_INSTANCE_ID') 
REGION = 'us-east-1'

ec2 = boto3.client('ec2', region_name=REGION)

def lambda_handler(event, context):
    params = event.get('queryStringParameters') or {}
    action = params.get('action', '').lower()
    
    # Vérification de sécurité
    if not INSTANCE_ID:
        return {
            'statusCode': 500,
            'body': json.dumps({'status': 'error', 'message': 'Erreur config: Aucun ID Instance trouvé'})
        }

    message = f"Cible : {INSTANCE_ID}. Action : {action}. "

    try:
        if action == 'start':
            ec2.start_instances(InstanceIds=[INSTANCE_ID])
            message += "Instance demarree."
        elif action == 'stop':
            ec2.stop_instances(InstanceIds=[INSTANCE_ID])
            message += "Instance arretee."
        else:
            message += "Utilisez ?action=start ou stop."

        return {
            'statusCode': 200,
            'body': json.dumps({'status': 'success', 'message': message})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'status': 'error', 'error': str(e)})
        }
