# Dubbo Admin Docker

Original code is from the dubbo github repository. (https://github.com/apache/dubbo-admin/tree/develop/kubernetes)

These files are the bare minimum config to run Dubbo Admin on an EKS / K8S cluster.

## Prerequisites

- kubectl (latest version)
- locally configured .kube environment
- create a k8s namespace named "dubbo" (can be customized but make sure to update the namespace values in the folder)
- create a secret 'dubbo' with the following data: DUBBO_ROOT_USER DUBBO_ROOT_PASSWORD NACOS_PASSWORD MYSQL_PASSWORD in the same namespace. Set values to match nacos server.
- Tweak the necessary values in configmap.yaml, secrets.yaml and deployment.yaml

## Installation

Assuming you're pushing this in Amazon ECR, build the docker image with:

```bash
docker build -t dubbo-admin.
docker tag dubbo-admin:latest <acocunt-id>.dkr.ecr.<my-region>.amazonaws.com/dubbo-admin:latest
docker push <acocunt-id>.dkr.ecr.<my-region>.amazonaws.com/dubbo-admin:latest
```

You can get by just applying kubectl with secrets.yaml, configmap.yaml, deployment.yaml, and service.yaml. You can use nginx, apache or APISIX to expose the generated service IP and port.

## Teardown

If you created PVs & PVCs, always delete the PVCs and PVs first, otherwise, the namespace deletion will hang.

Delete the dubbo namespace.
