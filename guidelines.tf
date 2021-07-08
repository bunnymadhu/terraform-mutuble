## first we need to create dev.azure.com account and in that got to project settings,agent pools,create agent and in that new agent....copy linux download link
## and in putty we need to connect to workstation and in that mkdir agent,cd agent,and need to download that link curl -L -O https://vstsagentpackage.azureedge.net/agent/2.188.3/vsts-agent-linux-x64-2.188.3.tar.gz...
## in that link enter 'ls' and vsts-agent-linux-x64-2.188.3.tar.gz and need to extract that file,,,,,tar -x -f vsts-agent-linux-x64-2.188.3.tar.gz
## and enter 'ls' and need to install one package sudo yum install libicu -y
## What is Libicu Dev?
## Development files for International Components for Unicode
## ICU is a C++ and C library that provides robust and full-featured Unicode and locale support. This package contains the development files for ICU.

## in putty cd agent,,     ./config.sh,,,https://dev.azure.com/madhusudhan002mr,,in and go to dev.azure.com go to settings and in that personal access tokens and in that create new token in the name B56-AGENT,here deployment access yes,and we got some access key copy and in putty paste after the http path,and Next agent pool is AWS-B56,,agent name is workstation....

## and setup the service enter 'ls' in that sudo ./svc.sh,,,sudo ./svc.sh install,,,sudo ./svc.sh status,,,sudo ./svc.sh start..
## so start our work in azure.azure.com in that go to pipelines and create one folder name called immutable infra and go to imm-infra click on create new pipeline namr called DEV and add source to github and give path to that...and go to DEV and run one agent AWS-B56 in side that run shell commands so add bash in that....and in that make dev-apply..
## so create make file in intellij in terraform-mutuble...

## in dev.azure.com destroy pipeline will not work properly untill u can to dynamodb in aws delete terraform.tf state file....

## by using VPC Route Tables we can connec by peering connection to one vpc to another vpc..(copy that IPv4 ID and paste the route tables in that add tags in their paste the IPv4 ID..)