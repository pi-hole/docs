Before installing Pi-hole, you need to make sure your system meets the [prerequisites](prerequisites.md) (hardware and operating system) and decide whether you want a [normal installation](basic-install.md) (bare metal) or a [docker installation](../docker/index.md).

After the installation is complete, check the [Post-Install steps](post-install.md) to make sure your network is using Pi-hole.

With the `pihole` command, you can manually run [Pi-hole commands](pihole-command.md). Examples:

- `pihole status` to check Pi-hole status;
- `pihole update` to [update](update.md) Pi-hole software;
- `pihole version` to show currently installed versions of Pi-hole, Web Interface and FTL;
- and many other commands.

Alternatively, you can also use the [web interface](https://github.com/pi-hole/web/) to run and configure your Pi-hole.

The web interface also allows you to use [Group Management](../group_management/index.md) functions to manage the relationship between clients, blocking rules, and allowing rules.

If you need help, please visit our [Discourse Forum](https://discourse.pi-hole.net/c/bugs-problems-issues/11).
