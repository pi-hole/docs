We pre-compile *FTL*DNS for you to save you the trouble of compiling anything yourself. However, sometimes you may want to make your own modifications. To test them, you have to compile *FTL*DNS from source. Luckily, you don't have to be a programmer to build *FTL*DNS from source and install it on your system; you only have to know the basics we provide in here. With just a few commands, you can build *FTL*DNS from source like a pro.

# Install native build environment

This will install all necessary tools to build FTL directly in your host operating system. It is usually the easiest solution and works with all editors available.

## Installing the Required Software

First, we'll install the basic software you'll need to compile from source, like the GCC compiler and other utilities.
Install them by running the following command in a terminal:

### Debian / Ubuntu / Raspbian

```bash
sudo apt install git wget ca-certificates build-essential libgmp-dev m4 cmake libidn11-dev libreadline-dev xxd
```

### Fedora

```bash
sudo dnf install git wget ca-certificates gcc gmp-devel gmp-static m4 cmake libidn-devel readline-devel xxd
```

## Compile `libnettle` from source

*FTL*DNS uses a cryptographic library (`libnettle`) for handling DNSSEC signatures.
Compile and install a recent version using:

```bash
wget https://ftp.gnu.org/gnu/nettle/nettle-3.8.1.tar.gz
tar -xzf nettle-3.8.1.tar.gz
cd nettle-3.8.1
./configure --libdir=/usr/local/lib
make -j $(nproc)
sudo make install
```

Since Ubuntu 20.04, you need to specify the library directory explicitly. Otherwise, the library will be installed in custom locations where it would not be found by `cmake`.

## Get the source

Now, clone the *FTL*DNS repo (or your own fork) to get the source code of *FTL*DNS:

```bash
git clone https://github.com/pi-hole/FTL.git && cd FTL
```

If you want to build another branch and not `master`, use checkout to get to this branch, like

```bash
git checkout development
```

## Compile the source

*FTL*DNS can now be compiled using either the build script

```bash
./build.sh
```

or manually

```bash
mkdir -p cmake && cd cmake
cmake ..
cmake --build . -- -j $(nproc)
```

Note that both ways are exactly equivalent and that you do not need `root` privileges here.

## Install the new binary system-wide

Install the new binary using either

```bash
./build.sh install
```

or

```bash
cd cmake && sudo make install
```

Finally, restart *FTL*DNS to use the new binary:

```bash
sudo service pihole-FTL restart
```

# Use containerized build environment

While most people think of [Docker](https://www.docker.com/) as a deployment environment, it's also a wonderful tool to create and maintain build environments. Pi-hole provides `ftl-build` containers composed of everything needed to build FTL for various architectures on your `x86_64` hosts. Check out [Docker Hub `pi-hole/ftl-build`](https://hub.docker.com/r/pihole/ftl-build/tags) for the available build containers as well as the [Releases overview](https://github.com/pi-hole/docker-base-images/releases/) for a detailed changelog.

The `ftl-build` containers can, for instance, easily be used as [`devcontainers`](https://code.visualstudio.com/docs/devcontainers/containers) with Visual Studio Code's [`remote-containers`](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension. The necessary `devcontainer.json` is provided in the FTL repository. See the description of the extension for further details. Note that `./build.sh install` would only install FTL in the container in this case. Instead, you have to copy the FTL binary generated inside the container yourself to the final destination on your installation target.
