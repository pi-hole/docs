## One-Step Automated Install

Those who want to get started quickly and conveniently may install Pi-hole using the following command:

```bash
curl -sSL https://install.pi-hole.net | bash
```

<!-- markdownlint-disable code-block-style -->
!!! info
    [Piping to `bash` is a controversial topic](https://pi-hole.net/2016/07/25/curling-and-piping-to-bash/), as it prevents you from [reading code that is about to run](https://github.com/pi-hole/pi-hole/blob/master/automated%20install/basic-install.sh) on your system.

    If you would prefer to review the code before installation, we provide these alternative installation methods.
<!-- markdownlint-enable code-block-style -->

### Alternative 1: Clone our repository and run

```bash
git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
cd "Pi-hole/automated install/"
sudo bash basic-install.sh
```

### Alternative 2: Manually download the installer and run

```bash
wget -O basic-install.sh https://install.pi-hole.net
sudo bash basic-install.sh
```

### Alternative 3: Use Docker to deploy Pi-hole

Please refer to the [Pi-hole docker repo](https://github.com/pi-hole/docker-pi-hole) to use the Official Docker Images.
