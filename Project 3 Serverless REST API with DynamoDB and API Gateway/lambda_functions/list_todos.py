import json
import boto3
import os

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table_name = os.environ['TABLE_NAME']
table = dynamodb.Table(table_name)

def handler(event, context):
    """
    Lambda function to list all todo items
    """
    try:
        # Get query parameters
        query_params = event.get('queryStringParameters') or {}
        
        # Scan the table
        scan_kwargs = {}
        
        # Add filter for completed status if provided
        if 'completed' in query_params:
            completed = query_params['completed'].lower() == 'true'
            scan_kwargs['FilterExpression'] = 'completed = :completed'
            scan_kwargs['ExpressionAttributeValues'] = {':completed': completed}
        
        # Add limit if provided
        if 'limit' in query_params:
            try:
                limit = int(query_params['limit'])
                scan_kwargs['Limit'] = min(limit, 100)  # Max 100 items
            except ValueError:
                pass
        
        # Perform the scan
        response = table.scan(**scan_kwargs)
        
        # Sort by created_at (newest first)
        todos = response.get('Items', [])
        todos.sort(key=lambda x: x.get('created_at', ''), reverse=True)
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
            },
            'body': json.dumps({
                'todos': todos,
                'count': len(todos)
            })
        }
        
    except Exception as e:
        print(f"Error listing todos: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
            },
            'body': json.dumps({
                'error': 'Internal server error'
            })
        }
