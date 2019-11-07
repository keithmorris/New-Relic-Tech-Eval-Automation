#!/usr/bin/env bash
if [ -z "$1" ]
  then
    echo "You need to supply a candidate name. This should be a string like candidate-name."
    exit 1
fi

source creds.sh

TERRAFORM=~/bin/terraform # path to terraform executable
RESTART_WAIT_TIME=180 # in seconds

CANDIDATE_SLUG=`echo $1 | sed 's/ /-/g' | awk '{print tolower($0)}'`
CANDIDATE_DNS=`echo ${CANDIDATE_SLUG} | sed 's/-//g'` # Strips the `-` out of the candidate name
EXPIRES=`date -v +1m +"%Y-%m-%d"`
TFVARS=terraform.tfvars
TFPLAN=tf.plan
LOCATION=eastus
APP_DNS=${CANDIDATE_DNS}-nr-candidate-lab-app.${LOCATION}.cloudapp.azure.com
INFO_FILE=candidate-info.txt

countdownTimer() {
    for ((COUNTER=$1;$COUNTER>=0;COUNTER--)); do
        sleep 1
        echo -ne "$COUNTER seconds\033[0K\r"
    done
    echo -e "\033[0KDone!"
}

# Do the thing
git clone https://github.com/davemurphysf/NewRelicCandiateLabEnv.git ${CANDIDATE_SLUG}
cd ${CANDIDATE_SLUG}
ssh-keygen -f ese_rsa -N '' -b 4096

# create variables file
echo subscription_id = \"${SUBSCRIPTION_ID}\" > ${TFVARS}
echo tenant_id = \"${TENANT_ID}\" >> ${TFVARS}
echo expiration = \"${EXPIRES}\" >> ${TFVARS}
echo username = \"${CANDIDATE_DNS}\" >> ${TFVARS}
echo location = \"${LOCATION}\" >> ${TFVARS}

${TERRAFORM} init
${TERRAFORM} plan -out ${TFPLAN}
${TERRAFORM} apply ${TFPLAN}

echo app_dns = ${APP_DNS} > ${INFO_FILE}
echo username = ${CANDIDATE_DNS} >> ${INFO_FILE}
echo site_url = http://${APP_DNS}:8080 >> ${INFO_FILE}
echo admin_url = http://${APP_DNS}:8080/admin >> ${INFO_FILE}
echo ssh_access = ssh -i ese_rsa ${CANDIDATE_DNS}@${APP_DNS} >> ${INFO_FILE}
echo expires = ${EXPIRES} >> ${INFO_FILE}

# Zip up SSH Keys and DNS info
zip -9 access-info.zip ese_rsa* candidate-info.txt

# Wait for server restart
echo "Waiting ${RESTART_WAIT_TIME} seconds for server reboot."
countdownTimer ${RESTART_WAIT_TIME}

# Startup Tomcat
echo "Starting up Tomcat on remote server."
ssh \
-o "UserKnownHostsFile=/dev/null" \
-o "StrictHostKeyChecking=no" \
myadmin@${CANDIDATE_DNS}-nr-candidate-lab-app.${LOCATION}.cloudapp.azure.com sudo JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64 bash -c "/opt/tomcat/bin/startup.sh"

# Open browser to candidate site to warm up the app
echo "Waiting for Tomcat to start (10 seconds)"
countdownTimer 10
open http://${APP_DNS}:8080
