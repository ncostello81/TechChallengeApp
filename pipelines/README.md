# Servian DevOps Tech Challenge - Pipelines

## Pre-requisites

1. A pre-existing Azure subscription
1. Docker (w/ Docker Compose)

## Running Jenkins

1. Create an Azure Service Principal via [the Azure Portal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) and note its Subscription ID, Client ID, Client Secret, and Tenant ID.
1. With your Service Principal details, populate the corresponding environment variables in your chosen shell (or in a .env file if you like, but **DO NOT** check it in):
    * `export AZ_SP_SUBSCRIPTION_ID=uogr` for Shell/Bash, or `$env:AZ_SP_SUBSCRIPTION_ID = 'uogr'` for PowerShell
    * `export AZ_SP_CLIENT_ID=uogr` for Shell/Bash, or `$env:AZ_SP_CLIENT_ID = 'uogr'` for PowerShell
    * `export AZ_SP_CLIENT_SECRET=uogr` for Shell/Bash, or `$env:AZ_SP_CLIENT_SECRET = 'uogr'` for PowerShell
    * `export AZ_SP_TENANT_ID=uogr` for Shell/Bash, or `$env:AZ_SP_TENANT_ID = 'uogr'` for PowerShell
1. To run Jenkins, execute `docker-compose up`
1. Note the initial Jenkins admin password that is output to your console.

## Logging in to Jenkins

1. In your browser of choice, navigate to http://localhost:8080
1. Login with admin/changeme
    * **Note:** This basic level of security is only in place for the purposes of this exercise, obviously.