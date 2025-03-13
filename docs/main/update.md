### Updating a regular Installation

Updating is as simple as running the following command:

`pihole -up`

!!! warning "Always Read The Release Notes!"
    Ensure you read the release notes for all Pi-hole components. This will help you avoid common problems due to known issues with upgrading or newly required arguments. The Release notes can be found in the respective Repository for [Core](https://github.com/pi-hole/pi-hole/releases), [FTL](https://github.com/pi-hole/FTL/releases) and [Web](https://github.com/pi-hole/web/releases). This is especially recommended for major updates like `v5 -> v6`. Some updates are accompanied by a post on the [Pi-hole Blog](https://pi-hole.net/landing/blog/) metioning notable changes.

### Updating Docker

Please refer to the [Guide in the Docker Docs](../docker/upgrading/index.md)

Release Notes for Docker specic changes can be found on [GitHub](https://github.com/pi-hole/docker-pi-hole/releases)
