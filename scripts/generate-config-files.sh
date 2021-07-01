#!/usr/bin/env bash

source ../.env

## variables
DBQT='"'
SCRIPTS_DIR=$(pwd)
WORK_DIR=$(dirname ${SCRIPTS_DIR})
CICD_REPO_DIR=${WORK_DIR}/${CICD_REPO}
PORTAL_REPO_DIR=${WORK_DIR}/${PORTAL_REPO}

## gateway config

# gateway/.env

# gateway .bssw

## cicd config

# generate jenkins casc.yaml file
_generate_jenkins_casc_yaml() {
  cat > ${CICD_REPO_DIR}/jenkins/casc.yaml << EOF
jenkins:
  systemMessage: "Jenkins configured automatically by Jenkins Configuration as Code plugin\n\n"
  numExecutors: 4
  scmCheckoutRetryCount: 2
  mode: NORMAL
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: ${DBQT}admin${DBQT}
          name: ${DBQT}AERPAW Admin${DBQT}
          description: ${DBQT}AERPAW Admin${DBQT}
          password: ${DBQT}${JENKINS_ADMIN_PASSWORD}${DBQT}
        - id: ${DBQT}${JENKINS_ADMIN_ID}${DBQT}
          name: ${DBQT}${JENKINS_ADMIN_NAME}${DBQT}
          description: ${DBQT}Project Manager${DBQT}
          password: ${DBQT}${JENKINS_ADMIN_PASSWORD}${DBQT}
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Overall/Administer:${JENKINS_ADMIN_ID}"
        - "Overall/Read:authenticated"
  remotingSecurity:
    enabled: true
security:
  queueItemAuthenticator:
    authenticators:
      - global:
          strategy: triggeringUsersAuthorizationStrategy
unclassified:
  location:
    url: http://127.0.0.1:8080/
EOF
}

# cicd/.env

## portal config

# generate django .env file
_generate_django_env() {
  cat > ${PORTAL_REPO_DIR}/.env << EOF
# Environment settings for both Django and docker-compose

# General settings (django)
export DJANGO_DEBUG=${DJANGO_DEBUG}
export DJANGO_SECRET_KEY=${DBQT}${DJANGO_SECRET_KEY}${DBQT}
export TIME_ZONE='${TIME_ZONE}'

# Operator CI/CD settings (django)
export OPERATOR_CICD_URL=${FQDN_OR_IP}
export OPERATOR_CICD_PORT=${HTTPS_PORT}

# User information (django, docker-compose)
export UWSGI_UID=${LOCAL_USER_UID}
export UWSGI_GID=${LOCAL_USER_GID}

# Postgres configuration (django, docker-compose)
export POSTGRES_DB=${POSTGRES_DB}
export POSTGRES_USER=${POSTGRES_USER}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
export POSTGRES_HOST=${POSTGRES_HOST}
export POSTGRES_PORT=${POSTGRES_PORT}
export PGDATA=${PGDATA}
export POSTGRES_INITDB_WALDIR=${POSTGRES_INITDB_WALDIR}

# Nginx configuration (docker-compose)
export NGINX_HTTP_PORT=${NGINX_HTTP_PORT}
export NGINX_HTTPS_PORT=${NGINX_HTTPS_PORT}
export NGINX_DEFAULT_CONF=${NGINX_DEFAULT_CONF}
export NGINX_SSL_CERTS_DIR=${NGINX_SSL_CERTS_DIR}

# OIDC CILogon (django)
# callback url
export OIDC_RP_CALLBACK='${OIDC_RP_CALLBACK}'
# client id and client secret
export OIDC_RP_CLIENT_ID='${OIDC_RP_CLIENT_ID}'
export OIDC_RP_CLIENT_SECRET='${OIDC_RP_CLIENT_SECRET}'
# oidc scopes
export OIDC_RP_SCOPES=${DBQT}${OIDC_RP_SCOPES}${DBQT}
# signing algorithm
export OIDC_RP_SIGN_ALGO='${OIDC_RP_SIGN_ALGO}'
export OIDC_OP_JWKS_ENDPOINT='${OIDC_OP_JWKS_ENDPOINT}'
# OpenID Connect provider
export OIDC_OP_AUTHORIZATION_ENDPOINT='${OIDC_OP_AUTHORIZATION_ENDPOINT}'
export OIDC_OP_TOKEN_ENDPOINT='${OIDC_OP_TOKEN_ENDPOINT}'
export OIDC_OP_USER_ENDPOINT='${OIDC_OP_USER_ENDPOINT}'
# session renewal period (in seconds)
export OIDC_RENEW_ID_TOKEN_EXPIRY_SECONDS='${OIDC_RENEW_ID_TOKEN_EXPIRY_SECONDS}'

# Aerpaw Gateway(GW) and Emulab configuration
export AERPAWGW_HOST=${AERPAWGW_HOST}
export AERPAWGW_PORT=${AERPAWGW_PORT}
export AERPAWGW_VERSION=${AERPAWGW_VERSION}
export URN_RENCIEMULAB='${URN_RENCIEMULAB}'

#AERPAW Emails
export EMAIL_HOST=${EMAIL_HOST}
export EMAIL_PORT=${EMAIL_PORT}
export EMAIL_USE_TLS=${EMAIL_USE_TLS}
export EMAIL_HOST_USER='${EMAIL_HOST_USER}'
export EMAIL_HOST_PASSWORD='${EMAIL_HOST_PASSWORD}'
export EMAIL_ADMIN_USER='${EMAIL_ADMIN_USER}'

# Operator Jenkins API
export JENKINS_API_URL='${JENKINS_API_URL}'
export JENKINS_API_USER='${JENKINS_API_USER}'
export JENKINS_API_PASS='${JENKINS_API_PASS}'
EOF
}

### generate django uwsgi.ini
_generate_django_uwsgi_ini() {
  cat > ${PORTAL_REPO_DIR}/uwsgi.ini << EOF
[uwsgi]
chdir = ./
module = base.wsgi:application
master = True
pidfile = /tmp/project-master.pid
vacuum = True
max-requests = 5000

# use for development
;socket = :8000

# use for production
uwsgi-socket = ./base.sock
chmod-socket = 666
EOF
}


## nginx config

# nginx/default.conf

### main

_generate_jenkins_casc_yaml
_generate_django_env
_generate_django_uwsgi_ini

exit 0;