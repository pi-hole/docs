## One-Step Automated Install
Those who want to get started quickly and conveniently, may install Pi-hole using the following command:

```BASH
curl -sSL https://install.pi-hole.net | bash
```

## Alternative Install Methods
[Piping to `bash` is controversial](https://pi-hole.net/2016/07/25/curling-and-piping-to-bash), as it prevents you from [reading code that is about to run](https://github.com/pi-hole/pi-hole/blob/master/automated%20install/basic-install.sh) on your system. Therefore, we provide these alternative installation methods which allow code review before installation: 

### Method 1: Clone our repository and run
```BASH
git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
cd "Pi-hole/automated install/"
sudo bash basic-install.sh
```

### Method 2: Manually download the installer and run
```BASH
wget -O basic-install.sh https://install.pi-hole.net
sudo bash basic-install.sh
```