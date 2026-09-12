### Updating a regular installation

Updating is as simple as running the following command:

`pihole -up`

!!! warning "Always Read The Release Notes!"
    Ensure you read the release notes for all Pi-hole components. This will help you avoid common problems due to known issues with upgrading or newly required arguments. The release notes can be found in the respective repository for [Core](https://github.com/pi-hole/pi-hole/releases), [FTL](https://github.com/pi-hole/FTL/releases) and [Web](https://github.com/pi-hole/web/releases). This is especially recommended for major updates like `v5 -> v6`. Some updates are accompanied by a post on the [Pi-hole Blog](https://pi-hole.net/landing/blog/) mentioning notable changes.

### SELinux

If SELinux is detected in `Enforcing` mode, `pihole -up` will exit rather than continue, since Pi-hole does not provide an official SELinux policy and enforcing mode may cause issues during or after the update.

!!! info
    If you have already configured a custom SELinux policy that allows Pi-hole to function correctly, you can skip this check by setting the `PIHOLE_SELINUX` environment variable before running the update:

    ```
    export PIHOLE_SELINUX=true
    pihole -up
    ```

    Setting this variable acknowledges that there may be issues with Pi-hole during or after the update while SELinux is enforcing.

### Updating Docker

Please refer to the [Guide in the Docker Docs](../docker/upgrading/index.md)

Release Notes for Docker specific changes can be found on [GitHub](https://github.com/pi-hole/docker-pi-hole/releases)
