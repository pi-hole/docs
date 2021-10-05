---
title: Docker DHCP and Network Modes
description: Setting up DHCP for Docker Pi-hole
last_updated: Sat Feb 09 00:00:00 2019 UTC
---

# Docker DHCP and Network Modes

Docker runs in a separate network by default called a docker bridge network, which makes DHCP want to serve addresses to that network and not your LAN network where you probably want it. This document details why Docker Pi-hole DHCP is different from normal Pi-hole and how to fix the problem.

## Technical details

Docker's bridge network mode is default and recommended as a more secure setting for containers because docker is all about isolation, they isolate processes by default and the bridge network isolates the networking by default too. You gain access to the isolated container's service ports by using port forwards in your container's runtime config; for example `-p 67:67` is DHCP. However, DHCP protocol operates through a network 'broadcast' which cannot span multiple networks (docker's bridge, and your LAN network). In order to get DHCP on to your network there are a few approaches:

## Working network modes

Here are details on setting up DHCP for Docker Pi-hole for various network modes available in docker.

### Docker Pi-hole with host networking mode

**Advantages**: Simple, easy, and fast setup

Possibly the simplest way to get DHCP working with Docker Pi-hole is to use [host networking](https://docs.docker.com/network/host/) which makes the container be on your LAN Network like a regular Raspberry Pi-hole would be, allowing it to broadcast DHCP. It will have the same IP as your Docker host server in this mode so you may still have to deal with port conflicts.

- Inside your docker-compose.yml remove all ports and replace them with: `network_mode: host`
- `docker run --net=host` if you don't use docker-compose

### Docker Pi-hole with a Macvlan network

**Advantages**: Works well with NAS devices or hard port conflicts

A [Macvlan network](https://docs.docker.com/network/macvlan/) is the most advanced option since it requires more network knowledge and setup. This mode is similar to host network mode but instead of borrowing the IP of your docker host computer it grabs a new IP address off your LAN network.

Having the container get its own IP not only solves the broadcast problem but avoids port conflicts you might have on devices such as NAS devices with web interfaces. Tony Lawrence detailed macvlan setup for Pi-hole first in the second part of his great blog series about [Running Pi-hole on Synology Docker](https://tonylawrence.com/posts/unix/synology/running-pihole-inside-docker/), check it out here: [Free your Synology ports with Macvlan](https://tonylawrence.com/posts/unix/synology/free-your-synology-ports/)

### Docker Pi-hole with a bridge networking

**Advantages**: Works well with container web reverse proxies like Nginx or Traefik

If you want to use docker's bridged network mode then you need to run a DHCP relay. A relay points to your containers forwarded port 67 and spreads the broadcast signal from an isolated docker bridge onto your LAN network. Relays are very simple software, you just have to configure it to point to your Docker host's IP port 67.

Although uncommon, if your router is an advanced enough router it may support a DHCP relay. Try googling for your router manufacturer + DHCP relay or looking in your router's configuration around the DHCP settings or advanced areas.

If your router doesn't support it, you can run a software/container based DHCP relay on your LAN instead. The author of dnsmasq made a very tiny simple one called [DHCP-helper](https://thekelleys.org.uk/dhcp-helper/READ-ME). [DerFetzer](https://discourse.pi-hole.net/t/dhcp-with-docker-compose-and-bridge-networking/17038) kindly shared his great setup of a DHCP-helper container on the Pi-hole Discourse forums.

### Warning about the Default bridge network

The out of the box [default bridge network has some limitations](https://docs.docker.com/network/bridge/#differences-between-user-defined-bridges-and-the-default-bridge) that a user created bridge network won't have. These limitations make it painful to use especially when connecting multiple containers together.

Avoid using the built-in default docker bridge network, the simplest way to do this is just use a docker-compose setup since it creates its own network automatically. If compose isn't an option the [bridge network](https://docs.docker.com/network/bridge/) docs should help you create your own.
