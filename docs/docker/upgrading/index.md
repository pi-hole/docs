# Upgrading

The standard Pi-hole customization abilities apply to this docker, but with docker twists such as using docker volume mounts to map host stored file configurations over the container defaults. However, mounting these configuration files as read-only should be avoided. Volumes are also important to persist the configuration in case you have removed the Pi-hole container which is a typical docker upgrade pattern.

!!! warning "Always Read The Release Notes!"
    Ensure you read the release notes for both the Docker release and the main Pi-hole component releases. This will help you avoid common problems due to known issues with upgrading or newly required arguments or variables. The release notes can be found in the respective repository for [Core](https://github.com/pi-hole/pi-hole/releases), [FTL](https://github.com/pi-hole/FTL/releases), [Web](https://github.com/pi-hole/web/releases) and [Docker](https://github.com/pi-hole/docker-pi-hole/releases).

## Upgrading / Reconfiguring

!!! Note
    The normal Pi-hole functions to upgrade (`pihole -up`) or reconfigure (`pihole -r`) are disabled within the docker container. New images will be released, and you can upgrade by replacing your old container with a fresh upgraded image, which is more in line with the 'docker way'. Long-living docker containers are not the docker way since they aim to be portable and reproducible, why not re-create them often! Just to prove you can.

### Docker Compose

Navigate to the directory in which your `docker-compose.yml` file exists and run the following commands

```bash
docker compose down
docker compose pull
docker compose up -d
```

### Docker run

```bash
docker stop pihole
docker rm pihole
docker pull pihole/pihole:latest
docker run [ ... arguments (see Getting Started) ... ]
```
