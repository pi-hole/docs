In case you wish to customise the image, or perhaps check out a branch after being asked by a developer to do so, you can use the convenient `build.sh` script located in the root of the [docker-pi-hole repository](https://github.com/pi-hole/docker-pi-hole)

## Checking out the repository

In order to build the image locally, you will first need a copy of the repository on your computer. The following commands will clone the repository from Github and then put you into the directory

```
git clone https://github.com/pi-hole/docker-pi-hole
cd docker-pi-hole
git checkout development-v6 #NOTE: This step is only needed until V6 is released
```

All other commands following assume you have at least run the above steps.

## Build.sh

```
Usage: ./build.sh [-l] [-f <ftl_branch>] [-c <core_branch>] [-w <web_branch>] [-t <tag>] [use_cache]
Options:
  -f, --ftlbranch <branch>     Specify FTL branch (cannot be used in conjunction with -l)
  -c, --corebranch <branch>    Specify Core branch
  -w, --webbranch <branch>     Specify Web branch
  -p, --paddbranch <branch>    Specify PADD branch
  -t, --tag <tag>              Specify Docker image tag (default: pihole)
  -l, --local                  Use locally built FTL binary (requires src/pihole-FTL file)
  use_cache                    Enable caching (by default --no-cache is used)

If no options are specified, the following command will be executed:
  docker buildx build src/. --tag pihole --load --no-cache
```

## Example uses of the script

### Contributing to the development of `docker-pi-hole`

When contributing, it's always a good idea to test your changes before submitting a pull request. Simply running `./build.sh` will allow you to do so.

There is also `./build-and-test.sh`, which can be used to verify the tests that are run on Github pass with your changes.

```
git checkout -b myNewFeatureBranch
#make some changes
./build.sh
```

### As an alternative to `pihole checkout`

Occasionally you may need to try an alternative branch of one of the components (`core`,`web`,`ftl`). On bare metal you would run, for example, `pihole checkout core branchName`, however in the Docker image we have disabled this command as it can cause unpredictable results.

#### Examples

- You have been asked by a developer to checkout the FTL branch `new/Sensors`. To do so

```
./build.sh -f new/Sensors
```

- There is new docker-specific work being carried out on the branch `fix/logRotate` that you wish to test

```
git checkout fix/logRotate
./build.sh
```

## Using the built image

Unless otherwise named via the `-t` command, the script will build an image locally and tag it as `pihole`. You can reference this as a drop-in replacement for `pihole/pihole:latest` in your compose file or your run command:

```yaml
services:
  pihole:
    container_name: pihole
    image: pihole
...
```

```
docker run [options] pihole
```
