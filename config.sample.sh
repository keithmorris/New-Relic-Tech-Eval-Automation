#!/usr/bin/env bash

# Required: The below can be retrieved with the Azure CLI with `az account show` command
SUBSCRIPTION_ID=
TENANT_ID=

## Optional specific preferences. These are shown with their default values.
## Uncomment and Update these with your required values.

## Path to terraform executable
# TERRAFORM=terraform

## Date candidate's account will expire (defaults to 1 month after environment is created)
# EXPIRES=`date -v +1m +"%Y-%m-%d"`

## Azure region (Defaults to `eastus`)
# LOCATION=east
