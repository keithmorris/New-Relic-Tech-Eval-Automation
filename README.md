# Automated Tech Evaluation Environment Creation

There are a few things you will need to update to use this:

1. Copy `config.sample.sh` to `config.sh`
2. Get your credentials using the `az account show` command and fill in the values in the `config.sh`
3. There is a variable set within the `setup-assessment.sh` file called `$TERRAFORM`. This is the path to your locally installed Terraform. I needed this because I had two versions installed. You will need to point this to your terraform executable. You should be able to run the command `which terraform` to get the path to your installed version.
4. There is a `$LOCATION` variable that is set to `eastus`. If you'd like the environment to be created in the Azure West region, change this to `westus`
5. There is an $EXPIRES variable that sets the candidate user to expire 1 month from the time the script is run. Feel free to update this if needed.

## How to use:
1. You can put these scripts in the root directory of wherever you check out the eval repository (like below). You can even clone the repo there as the `.gitignore` ignores everything but the script files.
2. Now, just run the command with the candidate name kebab-case or with spaces in quotes (e.g. `./setup-assessment.sh keith-morris` or `./setup-assessment.sh "Keith Morris"` (Note, the script will take the `"Keith Morris"` and convert it to `keith-morris`.

## What this does:

1. Clones the repo https://github.com/davemurphysf/NewRelicCandiateLabEnv.git into a new directory with the candidate name (e.g. keith-morris)
2. Generates a new SSH key ese_rsa for the candidate
3. Create a terraform variables file with the candidate-specific values and location 
4. Initializes Terraform, outputs the plan, then applies the plan
5. Saves a file to the candidate directory called `candidate-info.txt` that contains:
	* app_dns
	* username
	* site_url
	* admin_url
	* ssh_access command
	* expiration date
6. Zips the ese_rsa, ese_rsa.pub, and candidate-info.txt into a file called `access-info.zip` which can be attached to the email sent to the candidate.
7. After the environment is built, the script waits 3 minutes for the server to restart
8. The script SSH's into the new server and starts up Tomcat
9. Waits 10 seconds for Tomcat to start then opens up a web browser to the new app homepage.
