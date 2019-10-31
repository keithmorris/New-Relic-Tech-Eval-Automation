#!/usr/bin/env bash
if [ -z "$1" ]
  then
    echo "You need to supply a candidate name. This should be a string like candidate-name."
    exit 1
fi

source creds.sh

CANDIDATE_SLUG=$1
CANDIDATE_DNS=`echo ${CANDIDATE_SLUG} | sed 's/-//'`
EXPIRES=`date -v +1m +"%Y-%m-%d"`
TFVARS=terraform.tfvars
TFPLAN=tf.plan

# Do the thing
git clone https://github.com/davemurphysf/NewRelicCandiateLabEnv.git ${CANDIDATE_SLUG}
cd ${CANDIDATE_SLUG}
ssh-keygen -f ese_rsa -N '' -b 4096

# create variables file
echo subscription_id = \"${SUBSCRIPTION_ID}\" > ${TFVARS}
echo tenant_id = \"${TENANT_ID}\" >> ${TFVARS}
echo expiration = \"${EXPIRES}\" >> ${TFVARS}
echo username = \"${CANDIDATE_DNS}\" >> ${TFVARS}

~/bin/terraform init
~/bin/terraform plan -out ${TFPLAN}
~/bin/terraform apply ${TFPLAN}
