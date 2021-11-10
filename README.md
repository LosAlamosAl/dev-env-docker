# dev-env-docker
Development environment build with Docker

[![Docker Image CI](https://github.com/losalamosal/dev-env-docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/losalamosal/dev-env-docker/actions/workflows/docker-image.yml)

## Creating REST API with CLI

### Create a MOCK REST API

First, create the API:
```sh
aws apigateway create-rest-api --name butt --endpoint-configuration '{ "types": ["REGIONAL"] }'
```
Note that `id`, you'll need it often for other commands.

For the most basic API, use the `/` resource:
```sh
aws apigateway get-resources --rest-api-id REST_API_ID
```
Note the `id` of the `path: /` resource.

Next, put a `GET` method on the root resource:
```sh
aws apigateway put-method --rest-api-id REST_API_ID --resource-id ROOT_RES_ID --http-method GET --authorization-type NONE
```

We'll make this a MOCK integration:
```sh
aws apigateway put-integration --rest-api-id REST_API_ID --resource-id ROOT_RES_ID --http-method GET \
   --type MOCK --request-templates '{ "application/json": "{\"statusCode\": 200}" }'
```

This ammounts to setting up the integration request. We don't need a method request (?), but we need to define an integration response and a method response:
```sh
aws apigateway put-integration-response --rest-api-id REST_API_ID --resource-id ROOT_RES_ID --http-method GET --status-code 200 --response-templates '{"application/json": "{\"message\": \"blow chunks\"}"}'
aws apigateway put-method-response --rest-api-id REST_API_ID --resource-id ROOT_RES_ID --http-method GET --status-code 200
```

Now we need to deploy it so we can access it over the wire:
```sh
aws apigateway create-deployment --rest-api-id kjlcpip8he --stage-name seejay
```
The stage name, `seejay` in this case, is appended to the API's URL.

Finally, test using cURL:
```sh
curl -i -H "Accept: application/json" -H "Content-Type: application/json" \
   -X GET  https://RESTAPI_ID.execute-api.us-west-1.amazonaws.com/STAGE_NAME
HTTP/2 200 
date: Wed, 10 Nov 2021 02:24:25 GMT
content-type: application/json
content-length: 26
x-amzn-requestid: ad0fbd3f-02f0-4f3e-8ddf-fd66be78eb68
x-amz-apigw-id: IkQGBF0myK4FXzQ=

{"message": "blow chunks"}
```