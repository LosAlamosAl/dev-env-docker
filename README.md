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
   -X GET  https://RESTAPI_ID.execute-api.us-west-1.amazonaws.com/RESOURCE_PATH
HTTP/2 200 
date: Wed, 10 Nov 2021 02:24:25 GMT
content-type: application/json
content-length: 26
x-amzn-requestid: ad0fbd3f-02f0-4f3e-8ddf-fd66be78eb68
x-amz-apigw-id: IkQGBF0myK4FXzQ=

{"message": "blow chunks"}
```

### Create an HTTP API to HTTP endpoint

First, create the API. Specifying a `target` at this point will define a `$default` (catch all) route that will hit the specified endpoint. A `$default` stage and (auto) deployment are also created. If you don't specify a `target` you'll need to add stage and deply with additional commands.
```sh
aws apigatewayv2 create-api --name hole --protocol-type HTTP --target http://httpbin.org/anything
```

Now we define the integrations. These are done first so that we can attach them to the routes as we create them. Don't know why it's a `HTTP_PROXY` when there is an `HTTP` available (but that fails). Also don't know why the requirement for payload format (2.0 fails).
```sh
aws apigatewayv2 create-integration --api-id HTTP_API_ID --integration-type HTTP_PROXY \
   --integration-method GET --payload-format-version 1.0 --integration-uri http://httpbin.org/get
aws apigatewayv2 create-integration --api-id HTTP_API_ID --integration-type HTTP_PROXY \
   --integration-method POST --payload-format-version 1.0 --integration-uri http://httpbin.org/post
```

Now we can crteate the routes with their matching integrations.
```sh
aws apigatewayv2 create-route --api-id HTTP_API_ID --route-key 'GET /get' --target integrations/GET_INTEGRATION_ID
aws apigatewayv2 create-route --api-id HTTP_API_ID --route-key 'POST /post' --target integrations/POST_INTEGRATION_ID
```

Test with cURL:
```sh
curl -i -H "Accept: application/json" -H "Content-Type: application/json" \
   -X GET https://HTTP_API_ID.execute-api.us-west-1.amazonaws.com/RESOURCE_PATH
```

#### Adding a log

First, create the log group (note that you must have appropriate priveleges; my used is group `developer` has them by default):
```sh
aws logs create-log-group --log-group-name crusty-api-log
aws logs describe-log-groups --log-group-name crusty-api-log
{
    "logGroups": [
        {
            "logGroupName": "crusty-api-log",
            "creationTime": 1641949720910,
            "metricFilterCount": 0,
            "arn": "arn:aws:logs:us-west-1:xxxxxxxxxxx:log-group:crusty-api-log:*",
            "storedBytes": 0
        }
    ]
}
```

Next, attach the log group to a stage of the API.

Quoting the JSON format is a mother. This works, but adding another K:V pair screws it up.
```sh
aws apigatewayv2 update-stage --api-id novyodwbr8 --stage-name '$default' --access-log-settings DestinationArn='arn:aws:logs:us-west-1:ACCOUNT_ID:log-group:hole-http-api',Format=\'{\"requestId\":\"\$context.requestId\"}\'
```

After much screwing around, this works. Note the quoting required:
```sh
aws apigatewayv2 update-stage --api-id novyodwbr8 --stage-name '$default' --access-log-settings '{"DestinationArn": "arn:aws:logs:us-west-1:ACCOUNT_ID:log-group:hole-http-api", "Format": "{ \"requestId\":\"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\",\"routeKey\":\"$context.routeKey\", \"status\":\"$context.status\",\"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"}'
```

You can view the log:
```sh
aws logs tail --since 2h crusty-api-log
2022-01-12T01:18:16.705000+00:00 xxxxxxxxx_.default-2022-01-12-01-18 {"requestId":"yyyyyyyyyyyyyy"}
```

### Monitoring

I have tried to look at the default metrics that are supposed to be captured for every API call. They don't show up in the default CloudWatch dashboard. I cab add them if I specifically select APIs, but they should show up automatically. Likewise, the following style of CLI request should work, but returns empty.
```sh
aws cloudwatch get-metric-statistics --namespace AWS/ApiGateway --metric-name Count --start-time 2021-01-12T23:00:00Z --end-time 2021-01-16T23:00:00Z --period 300 --statistics Sum
{
    "Label": "Count",
    "Datapoints": []
}
```
However, searching for log events **does** work:
```sh
aws cloudwatch get-metric-statistics --namespace AWS/Logs --metric-name IncomingLogEvents --start-time 2021-01-12T23:00:00Z --end-time 2021-01-16T23:00:00Z --period 3600 --statistics Sum
{
    "Label": "IncomingLogEvents",
    "Datapoints": [
        {
            "Timestamp": "2021-01-14T00:00:00+00:00",
            "Sum": 13.0,
            "Unit": "None"
        },
        {
            "Timestamp": "2021-01-14T02:00:00+00:00",
            "Sum": 53.0,
            "Unit": "None"
        },
        {
            "Timestamp": "2021-01-14T23:00:00+00:00",
            "Sum": 45.0,
            "Unit": "None"
        },
        {
            "Timestamp": "2021-01-14T21:00:00+00:00",
            "Sum": 28.0,
            "Unit": "None"
        },
        {
            "Timestamp": "2021-01-14T22:00:00+00:00",
            "Sum": 33.0,
            "Unit": "None"
        },
        {
            "Timestamp": "2021-01-14T01:00:00+00:00",
            "Sum": 8.0,
            "Unit": "None"
        },
        {
            "Timestamp": "2021-01-14T03:00:00+00:00",
            "Sum": 12.0,
            "Unit": "None"
        }
    ]
}
```

### Creating the routes

Here are some routes:

- /l1
- /l1/l2
- /l1/l2/l3
- /zip{code}            -->   api.zippopotam.us/us/{code}            US only
- /zip/{state}/{city}   -->  api.zippopotam.us/us/{state}/{city}     US only

Query strings? Body? Forms?

Only solves half the problem. REST APIs can extract data from response. Maybe HTTP APIs will follow suit at some point.


```sh
fc -IA  # save Zsh history NOW
fc -R   # read Zsh history into new shell
```

Testing Permalink.
https://github.com/LosAlamosAl/dev-env-docker/blob/f4b2383fbf27d6eba8d03744b0cff8a99ca20c50/explore-cfn.yml#L125-L131
