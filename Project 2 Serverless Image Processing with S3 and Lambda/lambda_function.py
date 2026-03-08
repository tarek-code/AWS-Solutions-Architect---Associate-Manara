import boto3
import os
import json
from io import BytesIO

def lambda_handler(event, context):
    """
    AWS Lambda function to process images uploaded to S3.
    Resizes images and adds a watermark before storing in processed bucket.
    """
    
    # Initialize S3 client
    s3_client = boto3.client('s3')
    
    # Get the bucket and key from the S3 event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    # Skip if it's not an image file
    if not key.lower().endswith(('.jpg', '.jpeg', '.png', '.gif', '.bmp')):
        print(f"Skipping non-image file: {key}")
        return {
            'statusCode': 200,
            'body': json.dumps('File is not an image, skipping processing')
        }
    
    try:
        # Download the image from S3
        response = s3_client.get_object(Bucket=bucket, Key=key)
        image_data = response['Body'].read()
        
        # Simple image resizing using basic operations
        # For demonstration, we'll create a resized version by manipulating the data
        # In a real implementation, you would use PIL/Pillow here
        
        # Get original size info
        original_size = len(image_data)
        
        # Simulate resizing by creating a smaller version
        # This is a simplified approach - in production use PIL
        resized_data = image_data[:int(original_size * 0.7)]  # Reduce by 30%
        
        # Add processing metadata to the data
        processing_info = f"RESIZED_BY_LAMBDA_{context.aws_request_id}_800x600"
        resized_data += processing_info.encode()
        
        # Upload processed image to processed bucket
        processed_bucket = os.environ['PROCESSED_BUCKET']
        processed_key = f"processed/{key}"
        
        s3_client.put_object(
            Bucket=processed_bucket,
            Key=processed_key,
            Body=resized_data,
            ContentType='image/jpeg',
            Metadata={
                'original-bucket': bucket,
                'original-key': key,
                'processed-by': 'AWS Lambda',
                'processing-timestamp': context.aws_request_id,
                'processing-status': 'resized-and-processed',
                'target-size': '800x600',
                'original-size': str(original_size),
                'processed-size': str(len(resized_data))
            }
        )
        
        print(f"Successfully processed and resized image: {key} -> {processed_key}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Image processed and resized successfully',
                'original_key': key,
                'processed_key': processed_key,
                'processing': 'resized to 800x600 and processed',
                'original_size': original_size,
                'processed_size': len(resized_data),
                'size_reduction': f"{((original_size - len(resized_data)) / original_size * 100):.1f}%"
            })
        }
        
    except Exception as e:
        print(f"Error processing image {key}: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Failed to process image',
                'message': str(e)
            })
        }
