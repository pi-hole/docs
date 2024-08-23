In case you wish to customise the image, or perhaps check out a branch after being asked by a developer to do so, you can use the convienient `build.sh` script located in the root of the [docker-pi-hole repository](https://github.com/pi-hole/docker-pi-hole)

#### Usage:

```
./build.sh [-l] [-f <ftl_branch>] [-c <core_branch>] [-w <web_branch>] [-t <tag>] [use_cache]
```

#### Options:

```
 `-f <branch>` /  `--ftlbranch <branch>`: Specify FTL branch (cannot be used in conjunction with `-l`)
 `-c <branch>` / `--corebranch <branch>`: Specify Core branch
 `-w <branch>` / `--webbranch <branch>`: Specify Web branch
 `-t <tag>` / `--tag <tag>`: Specify Docker image tag (default: `pihole`)
 `-l` / `--local`: Use locally built FTL binary (requires `src/pihole-FTL` file)
 `use_cache`: Enable caching (by default `--no-cache` is used)
```

If no options are specified, the following command will be executed, and an image will be created based on the current branch of the repository, and all `master` component branches.

```
docker buildx build src/. --tag pihole --no-cache
```

Once the command has run, a local image will have been created named `pihole`, you can reference this as a drop-in replacement for `pihole/pihole:latest` in your compose file or your run command:

```yml
services:
  pihole:
    container_name: pihole
    image: pihole
...
```

```
docker run [options] pihole
```

Then start your container as normal.

### `pihole checkout` alternative

Occasionally you may need to try an alternative branch of one of the components (`core`,`web`,`ftl`). On bare metal you would run, for example, `pihole checkout core branchName`, however in the Docker image we have disabled this command as it can cause unpredictable results.

The preferred method is to use the script documented above

#### Examples

- You have been asked by a developer to checkout the FTL branch `new/Sensors`. To do so

```
git clone https://github.com/pi-hole/docker-pi-hole
cd docker-pi-hole
git checkout development-v6 # NOTE: This step is only needed until V6 is released
./build.sh -f new/Sensors
```

- There is new docker-specific work being carried out on the branch `fix/logRotate` that you wish to test

```
git clone https://github.com/pi-hole/docker-pi-hole
cd docker-pi-hole
git checkout fix/logRotate
./build.sh
```
