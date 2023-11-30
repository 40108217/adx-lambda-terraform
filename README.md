# ADX-Lambda-Terraform

Objective: Ingest the cloudtrail or VPC logs been saved in centralized bin to ADX cluster, as and when new log is uploaded to designated S3. There are 2 Phases to it.

Phase 1: As soon new log file is uploaded to S3, the event based lambda will be triggred to fetch the metadata of the event and push this information to ADX cluster, which includes the credentail to read the S3.

Phase 2: ADX will use the credentails that were provided along with URI to fetch the event payload for ingestion in ADX for further processing/analysis.

AWS Eco system: -

1) IAM User: This dedicated user to be used to read the S3. Associated access id and key will be saved in secret manager. At the time of actual Lambda execute, lambda code will pull the secrets and append it to the URI. This URI will be used by ADX to pull the logs from designated S3.

2) Secrets Manager: Used to store the IA credentials that will be used by ADX to read the S3 + app_id & app_key that will be provided from Azure end.

3) S3: Centralized S3 bucket, designated for log consolidation for Cloudtrail / VPC Flow Logs.
  a) CloudTrail : Logs processing in MULTIJSON format
  b) VPC Flow Log : Logs processin in parquet format

4) Lambda: Pythin3.8 is been used to write the lambda function for reacting to the S3 event and sending the metadata to ADX
  a) Layer : MS modules need to exported and layer to be created for this lambda function to work
    a1) azure.kusto.data
    a2) azure.kusto.ingest

5) Cloudwatch: Extremely useful for lambda execution log visibility and troubleshooting.

ADX Eco system: -

1) ADX cluster to be provisioned prioir to the AWS end configuration with below details. Special attention is needed for mapping details and the ingestion data format. if these details are not in-line with the AWS end config then it may not work as expected.
   a) TENENT_ID          = Environment Variable
   b) CLUSTER_INGEST_URI = Environment Variable
   c) DATABASE           = Environment Variable
   d) TABLE              = Environment Variable
   e) MAPPING            = Environment Variable
   f) app_id             = Secret in Secret Manager
   g) app_key            = Secret in Secret Manager
