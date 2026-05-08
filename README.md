### DEPLOY

* apply in two steps
    - terraform init -backend-config="backend.hcl"
    - terraform plan
    - terraform apply

* second step
    - terraform apply -var="snowflake_iam_user_arn=" -var="snowflake_external_id="

### SET UP DBT

1. clonar repo
2. uv sync
3. llenar profile.yml 
