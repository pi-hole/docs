# Setting up a PXE Boot Server with Docker-Compose and boot Kali Linux

In this guide I try to explain how to set up a PXE Boot Server with Pi-Hole and Docker-Compose.

**Host** means the machine where docker is running.

I am working in the subdirectory: `/home/user/container/pihole`

I used [https://www.kali.org/docs/installation/network-pxe/](https://www.kali.org/docs/installation/network-pxe/)  as an example.

## 1. Mount a TFTP Folder in the Pi-Hole Container.

Go in in the folder where your Pi-Hole configuration is. In my case it is:

```bash
cd /home/user/container/pihole
```

Create a new folder called tftpboot with

```bash
mkdir tftpboot
```

Edit the docker-compose.yml and mount the tftpboot to pihole.
Add `- './tftpboot:/tftpboot/'` in the Volume section.

Example docker-compose.yml file:

```
version: "3"

# More info at https://github.com/pi-hole/docker-pi-hole/ and https://docs.pi-hole.net/
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp"
      - "80:80/tcp"
    environment:
      TZ: 'America/Chicago'
      WEBPASSWORD: 'yourpw'
      ServerIP: '192.168.10.1'
      IPv6: 'false'
      DNSMASQ_LISTENING: 'local'
      INTERFACE: 'enp5s0'
      DHCP_ACTIVE: 'true'
      DHCP_START: '192.168.10.3'
      DHCP_END: '192.168.10.251'
      DHCP_ROUTER: '192.168.10.1'
    # Volumes store your data between container upgrades
    volumes:
      - './etc-pihole/:/etc/pihole/'
      - './etc-dnsmasq.d/:/etc/dnsmasq.d/'
      - './tftpboot:/tftpboot/'
    # Recommended but not required (DHCP needs NET_ADMIN)
    #   https://github.com/pi-hole/docker-pi-hole#note-on-capabilities
    network_mode: host
    restart: always
    cap_add:
      - NET_ADMIN
```

## 2. Now we need to tell Pi-Hole to start the integrated TFTP Server.

Change in the etc-dnsmasq.d folder.

```bash
cd etc-dnsmasq.d
```

Create a file 99-pxeboot.conf and add the follwing content:

```bash
touch 99-pxeboot.conf && nano 99-pxeboot.conf
```

Add the following content to the file and save it once finished.

```
dhcp-boot=pxelinux.0
enable-tftp
tftp-root=/tftpboot/
pxe-prompt="Press F8 for menu.", 60
pxe-service=x86PC,"Boot from local disk",0
pxe-service=x86PC,"Boot Kali Linux",kali/pxelinux
```

From here on you are done with Pi-Hole. The TFTP server should run, but it needs something to deliver to the clients.

## 3. Download the Netboot Image

Create a subdirectory for kali Linux in the tftp folder to provide the client with the data.

```bash
cd /home/user/container/pihole/tftpboot/
mkdir kali
cd kali
```

Download Kali Linux.

```bash
# 64-bit:
wget http://http.kali.org/kali/dists/kali-rolling/main/installer-amd64/current/images/netboot/netboot.tar.gz
# 32-bit:
wget http://http.kali.org/kali/dists/kali-rolling/main/installer-i386/current/images/netboot/netboot.tar.gz
```

Unzip  and remove the Image:

```bash
tar -zxpf netboot.tar.gz
rm netboot.tar.gz
```

## 4. Start Pi-Hole

You are all done. Start the Pi-Hole Container.

```bash
sudo docker-compose up -d
```
