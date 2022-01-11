### example solo5 openfaas container image

### for x86

```
docker build -t registry.nubificus.co.uk/ananos/solo5-faas:x86_64 --build-arg ARCH=x86_64 .
```

### for aarch64


```
docker build -t registry.nubificus.co.uk/ananos/solo5-faas:aarch64 --build-arg ARCH=aarch64 .
```

### Manifest create

```
docker manifest create registry.nubificus.co.uk/ananos/solo5-faas:generic -a registry.nubificus.co.uk/ananos/solo5-faas:x86_64 -a registry.nubificus.co.uk/ananos/solo5-faas:aarch64
docker manifest push registry.nubificus.co.uk/ananos/solo5-faas:generic
```

### faas deploy

```
faas-cli deploy -f stack-solo5.yml
