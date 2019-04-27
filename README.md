# Vault demo for Sherwin Williams
This repository contains information for a Vault demonstration to highlight the use-cases as defined by Sherwin Williams and HashiCorp. Those use-cases are:

- Static and dynamic secrets comparison
- Jenkins retrieving secrets from Vault
- Ansible retrieving secrets from Vault
- Kubernetes workflow connecting to a database (Oracle is preferred but Redis is a backup)

## Outline

1. Walk through static secrets
1. Show a dynamic secret in action
1. Step through a Jenkins workflow
1. Step through an Ansible workflow
1. Show a Kubernetes flow with a front-end applicaiton and database

## Demo

### Setup
    vault server -dev-root-token-id=myroottoken -dev
    export VAULT_ADDR='http://127.0.0.1:8200'
    vault login myroottoken

### Static Secrets
    vault secrets list -detailed
    vault secrets enable -path sherwin kv-v2
    vault kv put sherwin/demo/creds username="sysdba" password="staticpassword"
    vault kv get sherwin/demo/creds
    vault kv put -output-curl-string sherwin/demo/app-creds username="app1" password="12345678"
    vault kv get -output-curl-string sherwin/demo/app-creds
    vault kv get -field=username sherwin/demo/app-creds
    vault kv put sherwin/demo/creds password="another-static-password"
    vault kv get sherwin/demo/creds
    vault kv patch sherwin/demo/creds username="akentosh"
    vault kv get sherwin/demo/creds
    vault kv put sherwin/company @data.json
    vault kv get sherwin/company
    vault kv delete sherwin/company
    vault kv get sherwin/company

### Dynamic Secrets
    vault secrets enable database
    vault write sys/plugins/catalog/database/oracle-database-plugin sha256="b894ad433acccaf7861cdbc084c3003bb4c3180abcba5997a3b2bb3350628ee2" command=vault-plugin-database-oracle
    vault write database/config/my-oracle-database plugin_name=oracle-database-plugin connection_url="username/password@connection_string:1521/ORCL" allowed_roles="my-role"
    vault write database/roles/my-role db_name=my-oracle-database creation_statements="CREATE USER {{name}} IDENTIFIED BY {{password}}; GRANT CONNECT TO {{name}}; GRANT CREATE SESSION TO {{name}};" default_ttl="1h" max_ttl="24h"
    vault read database/creds/my-role 
    vault read -output-curl-string database/creds/my-role
    vault lease revoke -prefix database/creds/my-role
    ./sqlconnect
    select username from dba_users;

### AWS
    vault secrets enable aws
    vault write aws/config/root access_key=$AWS_ACCESS_KEY_ID secret_key=$AWS_SECRET_ACCESS_KEY region=us-east-1

    vault write aws/roles/my-role \
        credential_type=iam_user \
        default_ttl=1h \
        max_ttl=2h \
        policy_document=-<<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "ec2:*",
          "Resource": "*"
        }
      ]
    }
    EOF

    vault read aws/creds/my-role

### Transit

    vault secrets enable transit
    vault write -f transit/keys/cards
    vault write transit/encrypt/cards plaintext=$(base64 <<< "1234-5678-1234-5678")
    vault write -output-curl-string transit/decrypt/cards ciphertext=""
    | base64 --decode <<< $(jq -r '.data.plaintext' ) 

### Jenkins Integration
    vault secrets enable -path=sw kv
    vault write sw/jenkins/pki @jenkins/secrets.json
    run the job
    exec into the container and cat /var/jenkins_home/creds.txt

### Ansible Integration
    ansible-playbook playbook.yml
    step through playbook

### Application Review with K8s
    step through cats-and-dogs example in k8s
