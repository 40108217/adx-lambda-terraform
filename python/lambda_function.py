import io
import os
import json
import boto3
from azure.kusto.data import KustoConnectionStringBuilder
from azure.kusto.data.data_format import DataFormat
from azure.kusto.ingest import (
    BlobDescriptor,
    IngestionProperties,
    QueuedIngestClient,
)

def lambda_handler(event,context):
    ## Tenent ID
    tenent_id = os.environ['TENENT_ID']
    ## ADX Cluster Ingestion URL
    cluster_ingest_uri = os.environ['CLUSTER_INGEST_URI']
    ## Database details
    database = os.environ['DATABASE']
    table = os.environ['TABLE']
    mapping = os.environ['MAPPING']
    ## AWS Secret details
    secret_id = os.environ['SECRET_ID']
    ## Get Azure and AWS Credentials from AWS Secret Manager
    client = boto3.client('secretsmanager', region_name='us-east-1')
    response = client.get_secret_value(
        SecretId=secret_id
        )
    data = json.loads(response['SecretString'])
    ## Fetch credentials
    appId = data['app_id']
    appKey = data['app_key']
    aws_key = data['iam_id']
    aws_secret = data['iam_key']
    
    
    ingestion_connection = KustoConnectionStringBuilder.with_aad_application_key_authentication(cluster_ingest_uri, appId, appKey, tenent_id)
    m_client = QueuedIngestClient(ingestion_connection)
    
    ## Create Ingest Uri from AWS s3 event notification metadata
    for record in event["Records"]:
        bucket_name = record.get("s3").get("bucket").get("name")
        key = record.get("s3").get("object").get("key")
        size = record.get("s3").get("object").get("size")
        region=record.get("awsRegion")
        uri = 'https://{bucket}.s3.{region}.amazonaws.com/{key};AwsCredentials={aws_key},{aws_secret}'.format(bucket=bucket_name,region=region,key=key,aws_key=aws_key,aws_secret=aws_secret)

    try:
        ingestion_properties = IngestionProperties(database=database, table=table, data_format=DataFormat.PARQUET,ingestion_mapping_reference=mapping)
        ## FILE_SIZE is the raw size of the data in bytes
        blob_descriptor = BlobDescriptor(uri, size)
        m_client.ingest_from_blob(blob_descriptor, ingestion_properties)
        print('Done queuing up ingestion with Azure Data Explorer')
    except Exception as ex:
        raise
