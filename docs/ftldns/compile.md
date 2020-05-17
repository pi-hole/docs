We pre-compile *FTL*DNS for you to save you the trouble of compiling anything yourself. However, sometimes you may want to make your own modifications. To test them, you have to compile *FTL*DNS from source. Luckily, you don't have to be a programmer to build *FTL*DNS from source and install it on your system; you only have to know the basics we provide in here. With just a few commands, you can build *FTL*DNS from source like a pro.

#### Installing the Required Software

First, we'll install the basic software you'll need to compile from source, like the GCC compiler and other utilities.
Install them by running the following command in a terminal:

##### Debian / Ubuntu / Raspbian

```bash
sudo apt install build-essential libgmp-dev m4
```

##### Fedora

```bash
sudo dnf install gcc gmp-devel gmp-static m4
```

---

You'll also need to compile `nettle` as *FTL*DNS uses `libnettle` for handling DNSSEC. Compile and install a recent version of `nettle` (we tested and recommend 3.6):

```bash
wget https://ftp.gnu.org/gnu/nettle/nettle-3.6.tar.gz
tar -xvzf nettle-3.6.tar.gz
cd nettle-3.6
./configure
make
sudo make install
```

#### Get the *FTL*DNS source

Now, clone the *FTL*DNS repo (or your own fork) to get the source code of *FTL*DNS:

```bash
git clone https://github.com/pi-hole/FTL.git
cd FTL
```

If you want to build another branch and not `master`, use checkout to get to this branch (e.g. `git checkout development`).

*FTL*DNS can now be compiled and installed:

```bash
make -j $(nproc)
sudo make install
```

Finally, restart *FTL*DNS to use the new binary:

```bash
sudo service pihole-FTL restart
```

{!abbreviations.md!}
