# Fernet Solver

[fernet](https://cryptography.io/en/latest/fernet/) token으로 내용 추출

## with docker

``` sh
docker run --rm -p 8080:8080 leoh0/fernet-decryptor
```

``` sh
$ curl http://localhost:8080/<TOKEN>/<FERNETKEY1>/<FERNETKEY2>/<FERNETKEY3>/...
{
  "access_token_id": null,
  "audit_ids": [
    "rdoqrSJCRsGYMIOMb6eDUQ"
  ],
  "domain_id": null,
  "expires_at": "2020-09-15T07:57:33.000000Z",
  "federated_info": null,
  "methods": [
    "password"
  ],
  "project_id": "9eb3304ef1e64d20940503342c242b20",
  "trust_id": null,
  "user_id": "a8f421bc9abd41bcb3ce9f4c77ee38d0"
}
```

## with bazel

* requirement

install [bazel](https://docs.bazel.build/versions/3.5.0/bazel-overview.html) first

``` sh
export STABLE_DOCKER_REPO=docker.io/yourrepo
export CLUSTER=your-k8s-cluster
export CONTEXTyour-k8s-context
INGRESS_DOMAIN=my.k8s.ingress.com make apply-yaml
```

``` sh
$ curl http://my.k8s.ingress.com/<TOKEN>/<FERNETKEY1>/<FERNETKEY2>/<FERNETKEY3>/...
{
  "access_token_id": null,
  "audit_ids": [
    "rdoqrSJCRsGYMIOMb6eDUQ"
  ],
  "domain_id": null,
  "expires_at": "2020-09-15T07:57:33.000000Z",
  "federated_info": null,
  "methods": [
    "password"
  ],
  "project_id": "9eb3304ef1e64d20940503342c242b20",
  "trust_id": null,
  "user_id": "a8f421bc9abd41bcb3ce9f4c77ee38d0"
}
```

