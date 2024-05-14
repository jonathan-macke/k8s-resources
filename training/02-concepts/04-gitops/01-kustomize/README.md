# Kustomize

Kustomize is a template-free configuration manager

It is a command line tool you can use as 
* standalone (using the `kustomize` command)  
* integrated in `kubectl`(use `kubetcl apply -k` option)


# Prerequisites

Make sure you have setup your cluster with `<project-root>/infra/setup.sh``

If you have any issue with your cluster, you can clean it using `<project-root>/infra/clean.sh` and relaunch the setup script to start with a brand new cluster


Fork the GitHub repo: https://github.com/jonathan-macke/k8s-sample-apps
You will work on your forked repo, **not the original one**.


# Setup local Docker registry


Open another terminal as the terminal will be blocked
**Activate `registry` addon**
```shell
minikube addons enable registry -p prod
```

This will add the following pods
```shell
kube-system        registry-j7jmf                                     1/1     Running   0               18s
kube-system        registry-proxy-dcgzd                               1/1     Running   0               18s
kube-system        registry-proxy-tqwjs                               1/1     Running   0               18s
kube-system        registry-proxy-wxzll                               1/1     Running   0               18s
```

**Make the registry accessible in local**
```shell
docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip -p prod):5000"

fetch https://dl-cdn.alpinelinux.org/alpine/v3.19/main/aarch64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.19/community/aarch64/APKINDEX.tar.gz
(1/4) Installing ncurses-terminfo-base (6.4_p20231125-r0)
(2/4) Installing libncursesw (6.4_p20231125-r0)
(3/4) Installing readline (8.2.1-r2)
(4/4) Installing socat (1.8.0.0-r0)
Executing busybox-1.36.1-r15.trigger
OK: 9 MiB in 19 packages
```

# Deploy Docker image on the local registry

In `k8s-sample-apps/app`
```shell
docker build -t localhost:5000/myapp .
docker push localhost:5000/myapp
```


