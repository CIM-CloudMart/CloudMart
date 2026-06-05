# Product Service – DynamoDB Configuration

This service can use an in‑memory store (default) or a DynamoDB backend.

## Running a local DynamoDB instance

```bash
# Start DynamoDB Local in a Docker container
docker run -d \
  --name dynamodb-local \
  -p 127.0.0.1:8000:8000 \
  amazon/dynamodb-local
```

Create the table (replace `ProductTable` if you changed the name):

```bash
aws dynamodb create-table \
  --table-name ProductTable \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --endpoint-url http://localhost:8000
```

## Using the service

1. Copy `.env.example` to `.env` and adjust values if needed.
2. Ensure the Docker container is running (`docker ps`).
3. Run the service:
   ```bash
   flask run --host 0.0.0.0 --port 8001
   ```
   The service will automatically pick up `STORE_BACKEND=dynamodb` and connect to the local endpoint.

## Deploying to AWS

When deploying to AWS, set the environment variables to your real AWS credentials and omit `DYNAMODB_ENDPOINT`. The service will then connect to the AWS managed DynamoDB service.

```bash
export STORE_BACKEND=dynamodb
export DYNAMODB_TABLE=YourProductionTable
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1
```

The application uses IAM roles (IRSA / workload identity) when running in Kubernetes; the environment variables are only required for local development.
