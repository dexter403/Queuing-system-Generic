# GenericApp Services Dockerize

## Build a docker image locally

Navigate to **GenericApp-backend\src** folder and run the following command:

```bash
docker build --file ./services/{SERVICE_NAME}/Dockerfile --tag GenericApp-{SERVICE_NAME}:{TAG} --build-arg SERVICE={SERVICE_NAME} .
```

or using PowerShell:

```powershell
.\dockerize.ps1 -Action Build -Service {SERVICE_NAME} -Tag {TAG}
```

Where:
* **{SERVICE_NAME}** is service name, e.g. `status-service` and etc.
* **{TAG}** is a tag for the image, e.g. `latest`, `DEV`, `GenericApp-459` and etc.

## Run a docker container locally

Navigate to **GenericApp-backend\src** folder and run the following command:

```bash
docker run -it --publish 80:3000 --env-file ./services/{SERVICE_NAME}/.env --name GenericApp-{SERVICE_NAME} --rm GenericApp-{SERVICE_NAME}:{TAG}
```

Parameters:

* **--detach** is used when the docker should be run non-attached to the console (like a in background mode)
* **--publish** parameter is used to specify the port number used to publish the docker container on the host machine with the target port used to map to the application inside the docker container, for instance _--publish 80:3000_ will publish docker container on the port _80_ of the host and map it to the port _3000_ in the docker container.

or using PowerShell:

```powershell
.\dockerize.ps1 -Action Run -Service {SERVICE_NAME} -Tag {TAG}
```

Where:
* **{SERVICE_NAME}** is service name, e.g. `status-service` and etc.
* **{TAG}** is a tag for the image, e.g. `latest`, `DEV`, `GenericApp-459` and etc.

## Stop the docker container locally

```bash
docker stop GenericApp-{SERVICE_NAME}
```

or using PowerShell:

```powershell
.\dockerize.ps1 -Action Stop -Service {SERVICE_NAME} -Tag {TAG}
```

## Remove the docker image created locally

```bash
docker image rm GenericApp-{SERVICE_NAME}:{TAG}
```

## Log in to the Azure account

```bash
az login
```

## Log in to the Azure Container Registry (ACR)

```bash
az acr login --name {CONTAINER_REGISTRY_INSTANCE_NAME}
```

## Tag the docker image created locally

```bash
docker tag GenericApp-{SERVICE_NAME}:{TAG} {CONTAINER_REGISTRY_INSTANCE_NAME}.azurecr.io/GenericApp-{SERVICE_NAME}:{TAG}
```

or using PowerShell:

```powershell
.\dockerize.ps1 -Action Tag -Service {SERVICE_NAME} -Tag {TAG}
```

## Push the docker image created locally to the Azure Container Registry (ACR)

```bash
docker push {CONTAINER_REGISTRY_INSTANCE_NAME}.azurecr.io/GenericApp-{SERVICE_NAME}:{TAG}
```

## Remove the docker image from the Azure Container Registry (ACR)

```bash
az acr repository delete --name {CONTAINER_REGISTRY_INSTANCE_NAME} --image GenericApp-{SERVICE_NAME}:{TAG}
```
