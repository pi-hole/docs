## One-Step Automated Install
Those who want to get started quickly and conveniently, may install Pi-hole using the following command:

```BASH
curl -sSL https://install.pi-hole.net | bash
```

!!! info
    [Piping to `bash` is a controversial topic](https://pi-hole.net/2016/07/25/curling-and-piping-to-bash), as it prevents you from [reading code that is about to run](https://github.com/pi-hole/pi-hole/blob/master/automated%20install/basic-install.sh) on your system.

    If you would prefer to review the code before installation, we provide these alternative installation methods.

#### Alternative 1: Clone our repository and run
```BASH
git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
cd "Pi-hole/automated install/"
sudo bash basic-install.sh
```

#### Alternative 2: Manually download the installer and run
```BASH
wget -O basic-install.sh https://install.pi-hole.net
sudo bash basic-install.sh
```

{!abbreviations.md!}
