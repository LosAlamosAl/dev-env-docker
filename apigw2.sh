#!/usr/bin/env bash

API_ID=$1

aws apigatewayv2 get-api --api-id $API_ID | jq '.ApiId,.ProtocolType,.Name'
# Took forever to figure out that -r is needed or jq will return a quoted string
# (which subsequent bash commands don't like).
# https://stackoverflow.com/a/60103131/227441
INTEGRATION_IDS=$(aws apigatewayv2 get-integrations --api-id $API_ID | jq -r '.Items[].IntegrationId')

aws apigatewayv2 get-integration --api-id $API_ID --integration-id $INTEGRATION_IDS \
  | jq '.IntegrationId,.IntegrationMethod,.IntegrationType,.IntegrationUri'
