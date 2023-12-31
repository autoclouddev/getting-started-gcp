# AutoCloud Infrastructure as Code Catalog Getting Started Blueprint - Google Cloud Platform



## Overview
AutoCloud Terraform Blueprints are a way for organizations to deploy consistent, well-architected patterns that meet organization standards and requirements across many teams, with less friction between application, security, and platform concerns.

This "write-once, deploy-many" strategy allows pattern architects to design, define, and maintain best practice patterns with cost, security, and compliance standards baked in, and makes them available for consumption to end users in a self-service portal. These consumers are shown a form wizard that quickly gathers the required configuration input. Upon submission, AutoCloud runs cost, security, and compliance analysis, and autogenerates Terraform code implementing the assets. This code is then submitted in a git pull request for review and deployment using your existing Terraform tooling and workflows.

The example pattern created by this blueprint addresses a very common use case for Google Cloud Platform users that is a frequent source of misconfiguration: the deployment of a private, encrypted cloud storage bucket.



## Deploying This Blueprint

### Download Code

The first step to deploying this getting started blueprint is to set up a local copy of this codebase.

If you have gone through the getting started process in AutoCloud, you have downloaded this code already, and it has been pre-configured with API access for you. You are ready for the next step.

If you are reading this on Github, you can clone this repository or [download the code here](https://github.com/autoclouddev/getting-started-gcp/archive/refs/heads/main.zip).

### Configure Access Credentials

Before executing the Terraform actions to create the AutoCloud Terraform blueprint, you will need to ensure that your terminal environment has been configured to authenticate to AutoCloud. Similarly, to execute the Terraform generated by the AutoCloud blueprint, you will need to configure your terminal environment to authenticate to Google Cloud Platform.

#### AutoCloud

The AutoCloud provider requires an API token to authenticate and access the AutoCloud service. The provider is configured in the file `./provider.tf`. See the comments in that file for details on configuring AutoCloud access.

#### Google Cloud Platform

The Azure Terraform provider will use the authentication mechanism set up in your terminal environment by default. Before you run Terraform commands, you will need to authenticate to Google Cloud Platform in the terminal you will be using to execute the generated Terraform code. How you do this authentication will depend on your organization, but logging into the Google Cloud Platform console and authenticating using the Google Cloud Platform CLI works for most users: 

Log into the [Google Cloud Platform Console](https://console.cloud.google.com/).

Choose the project that you want to deploy the example resources into (e.g. `autocloud-sandbox`)

Authenticate using the Azure CLI:

```bash
% gcloud auth login
```

For more information on configuring access for the Google Cloud Platform provider, see the [official provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration). 

### Run Terraform to Create Blueprint

You are now ready to deploy the Terraform blueprint. In the terminal you used to configure access in the previous step, execute the Terraform to create the IaC blueprint in AutoCloud:

```bash
% terraform init
% terraform plan
% terraform apply
```

You should see the new IaC Terraform Blueprint in the [drafts section of your Iac Catalog](https://app.autocloud.io/iac-catalog/drafts):

![New IaC Catalog Blueprint](https://static1.autocloud.io/iac/getting-started/gcp/getting-started-gcp-card.png)

### Generate Code from Blueprint in AutoCloud

The Terraform blueprint is now deployed to AutoCloud. Next, test the blueprint to ensure proper functionality before publishing the blueprint to your organization.

#### Complete the Generation Form

In the [drafts section of your Iac Catalog](https://app.autocloud.io/iac-catalog/drafts), find the card labeled `[Getting Started] KMS Encrypted Google Cloud Storage Bucket`, and click the `Test` button. You will be brought to the code generation form wizard. 

- Choose an environment
- Add a name for the cloud storage bucket assets
- Select the location
- Provide the project ID
- Add any labels that you wish to apply
  

![Complete the form](https://static1.autocloud.io/iac/getting-started/gcp/getting-started-gcp-form.png)

When you are done, click the `Next` button to continue to the review step.

#### Review the Submission

Review the submitted values, as these will be passed to the Terraform module. You can preview the Terraform code that will be generated with the `Review Code` button. You may return to the code generation wizard to make any corrections that you desire. Once you are satisfied, click the `Create` button to submit the configuration to AutoCloud to generate the code.


![Completed form](https://static1.autocloud.io/iac/getting-started/gcp/getting-started-gcp-completed.png)

#### Download the Generated Code

You have successfully completed the AutoCloud Terraform Blueprint code generation process. Click the `Download` button to download the generated code.


#### Run Terraform to Create Cloud Storage Bucket

In the terminal you configured access for, navigate to the downloaded code. Execute the Terraform to create the encrypted cloud storage bucket:

```bash
% terraform init
% terraform plan
% terraform apply
```

Once complete, you will see the key ring, key, and cloud storage bucket in your project.

Your AutoCloud Terraform Blueprint is now ready to be deployed to the rest of your organization.

## Security

We deeply appreciate any effort to discover and disclose security vulnerabilities responsibly.

If you would like to report a vulnerability in one of our products, or have security concerns regarding AutoCloud software, please email security@autocloud.io.

In order for us to best respond to your report, please include any of the following:

Steps to reproduce or proof-of-concept
Any relevant tools, including versions used
Tool output