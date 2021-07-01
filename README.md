# Deploy Portal Services

**THIS DOCUMENT IS A WORK IN PROGRESS**

## About

AERPAW Ops consists of 3 separate repositories for UI components deployed under a unified docker compose definition at a single URL endpoint

- Portal: [https://github.com/AERPAW-Platform-Control/portal](https://github.com/AERPAW-Platform-Control/portal)
- Gateway: [https://github.com/AERPAW-Platform-Control/gateway](https://github.com/AERPAW-Platform-Control/gateway)
- CI/CD: [https://github.com/AERPAW-Platform-Control/experimenter-cicd](https://github.com/AERPAW-Platform-Control/experimenter-cicd) (modified to be used for the Operator)

## Configuration

Directories for storing application data (preferably outside of repo, say in `/var`)

```
/var/aerpaw/data
  |_ django_data    # Django data (contents created at runtime)
      |_ static     # Static files - served by Nginx directly
      |_ media      # Media files - served by Nginx directly
  |_ gateway_data   # Gateway data (contents added by user)
      |_ .bssw      # See gateway repo for details
  |_ gitea_data     # Gitea data (contents created at runtime)
  |_ jenkins_home   # Jenkins data (contents created at runtime)
  |_ logs           # Log output from all apps
  |_ pg_data        # Postgres data (contents created at runtime)
```

## Deploy

Start all containers

```console
docker-compose pull
docker-compose build
docker-compose up -d
```

Create initial account in Django

```console
### from within the aerpaw-portal container ###
python manage.py createsuperuser
```

Example Output

```console
$ docker exec -ti aerpaw-portal /bin/bash
root@0a0246a2d761:/code# source .venv/bin/activate
(.venv) root@0a0246a2d761:/code# python manage.py createsuperuser
Username: admin
Email address: aerpaw@gmail.com
Password:
Password (again):
Superuser created successfully.
(.venv) root@0a0246a2d761:/code# exit
exit
```

Create initial account in Gitea

```console
cd scripts/
./gitea-create-user.sh
```

Example Output

```console
$ ./gitea-create-user.sh
GITEA_ADMIN_EMAIL=aerpaw@gmail.com
GITEA_ADMIN_ID=aerpaw
GITEA_ADMIN_PASSWORD=password123!
GITEA_APP_NAME=AERPAW Experimeter Gitea
GITEA_DISABLE_REGISTRATION=true
GITEA_INSTALL_LOCK=true
GITEA_ROOT_URL=https://127.0.0.1:8443/gitea/
GITEA_SSH_AGENT_PORT=3022
GITEA_USER_GID=1000
GITEA_USER_UID=1000
LOCAL_GITEA_DATA=./data/gitea_data
2021/07/01 08:27:08 ...dules/setting/git.go:101:newGit() [I] Git Version: 2.30.2, Wire Protocol Version 2 Enabled
New user 'aerpaw' has been successfully created!
2021/07/01 08:27:09 ...dules/setting/git.go:101:newGit() [I] Git Version: 2.30.2, Wire Protocol Version 2 Enabled
ID   Username Email            IsActive IsAdmin
1    aerpaw   aerpaw@gmail.com true     true
```

Jenkins configuration

Create API Token

Example API Token

```
token name: aerpaw-api
token value: 1189521f4d3a05c7df2b6244b630ac75a9
```
