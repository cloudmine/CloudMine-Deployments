# CloudMine-Deployments

This package contains a Logic Engine and JavaScript snippet deployment utility script. 

To aid integrating deploying code snippets to CloudMine Logic Engine into client's workflows, we have opened up an API endpoint for deploying code and created a linux shell script that deploys the code to this endpoint and then checks to determine whether the deployment succeeds or fails.

## Deployment Endpoint
The endpoint for deploying a snippet is:

### Request
```http
POST https://api.cloudmine.io/admin/app/${app_id}/code/upload/${language}
X-CloudMine-ApiKey: 8305E8B7F8F51828A997C462B3D35291
Content-Type: multipart/form-data

file=@code-to-deploy.zip
```
# `app_id`: required.
# `language`: required. Indicates the language of the code package being deployed. Supported options include `node` and `java`. 
# `X-CloudMine-ApiKey`: required. This *must* be the Master API Key, available from within the CHC or Compass dashboard. 
# `file`: a form-field which specifies the ZIP package to be uploaded. 

## Checking the deployment status

We have an endpoint for checking the deployment status:

### Request 
```http
GET https://compass.cloudmine.io/dashboard/v1/app/${app_id}/apollo/status
Authorization: Bearer ${token}
```

### Response 
```http
{
    "health": {
        "HealthStatus": "Ok",
        "Status": "Ready",
        "Color": "Green"
    }
}
```
# `token`: required. Refers to your developer token. See [Obtaining a Developer Token](## Obtaining a Developer Token) for information on how to obtain this token. 
# `app_id`: required.


## Obtaining a Developer Token

Developer tokens are issued using the following API call. 

```http
POST https://api.cloudmine.io/v2/auth/developer/login

{
	username: "some-username",
	password: "some-password"
}
```
# `username`: required. 
# `password`: required. 

**Note:** If your developer belongs to an organization in CHC, this should just be your username. If you are a developer on Compass, your username for this call is your CloudMine Developer Id. If you don't know this, please [contact us](mailto: support@cloudmineinc.com) and we will help you.

## Jenkins

This utility can be easily dropped into a Jenkins job. If you set up a parameterized job, you can set each of the variables. You may want to set up a mechanism to lookup the `Master Api Key` outside of directly setting it in Jenkins to keep it secure.