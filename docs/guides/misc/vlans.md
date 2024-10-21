# VLANs and virtual LAN interfaces

This guide will help you configure Pi-hole to operate across defined virtual LAN interfaces on networks with VLANs configured.

## Notes & Warnings

- This guide is only applicable to distributions using `dhcpcd`, not those utilizing `NetworkManager` or `systemd-networkd`.
- This guide should only be used by users with advanced networking knowledge with networks utilizing VLAN configurations.
- Opening up ports for devices on insecure networks can be dangerous, proceed with caution.
- If you want the device to have static IP addresses or other further network routing configurations, those steps would need to be added based on your specific network setup and requirements.

## Setup VLANs

### Install `vlan` Package

```
sudo apt install vlan
```

### Configure VLAN interfaces

Create network interface configuration file for vlans

```
sudo nano /etc/network/interfaces.d/vlans
```

Add the following for each vlan interface you would like to add, replacing the `<>` brackets:

```
auto <interface>.<vlan id>
iface <interface>.<vlan id> inet manual
  vlan-raw-device <interface>
```

For example, configuring VLAN id 8 and 16 on interface eth0 should look like:

```
auto eth0.8
iface eth0.8 inet manual
  vlan-raw-device eth0

auto eth0.16
iface eth0.16 inet manual
  vlan-raw-device eth0
```

### Restart and test

Restart Device Networking

```
sudo systemctl restart networking
```

Test config for an IP in each VLAN

```
hostname -I
```

Example output:

```
192.168.1.100 192.168.8.1 192.168.16.1
```

### Configure Pi-hole to Listen on the VLAN Interfaces

1. Go to the [Pi-hole admin dashboard](http://pi.hole/admin/)
2. Navigate to **Settings** > **DNS**
3. Under **Interface listening behavior**, choose **Listen on all interfaces** or **Permit all origins** depending on your security preference. More information about these settings can be found [here](https://docs.pi-hole.net/ftldns/interfaces/).
