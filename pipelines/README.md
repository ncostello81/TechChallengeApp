# Servian DevOps Tech Challenge - Pipelines

## Pre-requisites

1. A pre-existing (and presumably empty) Azure subscription
1. Docker (w/ Docker Compose)

### Azure Setup

1. [Create an Azure Service Principal with an application secret and **Owner** access via the Azure Portal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal), and note its:
    * Subscription ID, from the Subscription page.
    * Client ID, from the App Registration page.
    * Client Secret, from the Certificates & Secrets page of the App Registration.
    * Tenant ID, from the App Registration page.

## Running Jenkins

1. With your Service Principal details, populate the corresponding environment variables in your chosen shell (or in a .env file if you like, but **DO NOT** check it in):
    * `export AZ_SP_SUBSCRIPTION_ID=xxxxxxxxxxxxxxxxx` for Shell/Bash, or `$env:AZ_SP_SUBSCRIPTION_ID = 'xxxxxxxxxxxxxxxxx'` for PowerShell
    * `export AZ_SP_CLIENT_ID=xxxxxxxxxxxxxxxxx` for Shell/Bash, or `$env:AZ_SP_CLIENT_ID = 'xxxxxxxxxxxxxxxxx'` for PowerShell
    * `export AZ_SP_CLIENT_SECRET=xxxxxxxxxxxxxxxxx` for Shell/Bash, or `$env:AZ_SP_CLIENT_SECRET = 'xxxxxxxxxxxxxxxxx'` for PowerShell
    * `export AZ_SP_TENANT_ID=xxxxxxxxxxxxxxxxx` for Shell/Bash, or `$env:AZ_SP_TENANT_ID = 'xxxxxxxxxxxxxxxxx'` for PowerShell
1. To run Jenkins, execute `docker-compose up`

## Logging in to Jenkins

1. In your browser of choice, navigate to http://localhost:8080
1. Login with admin/changeme
    * **Note:** This basic level of security is only in place for the purposes of this exercise, obviously.

## Build the Azure environment

1. Select the **testchallenge-platform** job.
1. If no branches have appeared, click Scan Multibranch Pipeline Now to register them.
1. Select the branch you would like to run.
1. Click Build to run the job to create the Azure environment.
    * **Note 1:** If you are running a branch for the first time, the environment will be created with this default Postgres password: `gh2387$$!s99`
    * **Note 2:** If you are running a branch for the second time, you will be prompted to set the Postgres password, at which point you may choose to set it how you like, but:
        * it must meet the complexity requirements [described here](https://docs.microsoft.com/en-us/azure/postgresql/quickstart-create-server-database-azure-cli#create-an-azure-database-for-postgresql-server). (At the time of writing, "It must contain 8 to 128 characters from three of the following categories: English uppercase letters, English lowercase letters, numbers, and non-alphanumeric characters.")
        * you will need to update the [conf.toml](../conf.toml) file with the appropriate password before building the app. [In a real-world scenario, we'd be pulling the secret value from Azure Key Vault at build time.]

## Build the application

1. Select the **testchallenge-build** job.
1. If no branches have appeared, click Scan Multibranch Pipeline Now to register them.
1. Select the branch you would like to run.
1. Click Build to run the job to create the app container and push it to the Azure Container Registry.

## Deploy the application

## Use the application

