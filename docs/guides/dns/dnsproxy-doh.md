## Configuring DNS-Over-HTTPS using `dnsproxy`

This guide shows how to install the [dnsproxy](https://github.com/AdguardTeam/dnsproxy) tool (created by AdguardTeam).

These steps where tested on a Ubuntu Server 22.

But should work on any Linux distributionm, maybe with some minor changes.

---

### Installing `dnsproxy`

You just need to download it from the [releases page](https://github.com/AdguardTeam/dnsproxy/releases). Choose your architecture and download the binary.

For this guide we will use the `dnsproxy-linux-amd64-v0.61.1.tar.gz` binary available at https://github.com/AdguardTeam/dnsproxy/releases/download/v0.61.1/dnsproxy-linux-amd64-v0.61.1.tar.gz


```bash
wget https://github.com/AdguardTeam/dnsproxy/releases/download/v0.61.1/dnsproxy-linux-amd64-v0.61.1.tar.gz
tar -zxvf dnsproxy-linux-amd64-v0.61.1.tar.gz
mv linux-amd64/dnsproxy ./
```

---

### Configuring `dnsproxy` to run on startup

1. Copy the `dnsproxy` binary to `/usr/bin`:
    ```bash
    sudo cp ./dnsproxy /usr/bin/
    ```
2. Create a `dnsproxy` user to run the daemon:
    ```bash
    sudo useradd -s /usr/sbin/nologin -r -M dnsproxy
    ```
3. Allow the `dnsproxy` user to run the `dnsproxy` binary:
    ```bash
    sudo chown dnsproxy:dnsproxy /usr/bin/dnsproxy
    ```
4. Create a service file for `dnsproxy`:
    ```bash
    sudo nano /etc/systemd/system/dnsproxy.service
    ```
    And copy the following into `/etc/systemd/system/dnsproxy.service`.
    This will control the running of the service and allow it to run on startup:
    ```ini
    [Unit]
    Description=DNS Proxy over HTTPS
    After=syslog.target network-online.target

    [Service]
    Type=simple
    User=dnsproxy
    ExecStart=/usr/bin/dnsproxy -l 127.0.0.1 -p 5353 -u https://cloudflare-dns.com/dns-query -u https://dns.google/dns-query
    Restart=on-failure
    RestartSec=10
    KillMode=process

    [Install]
    WantedBy=multi-user.target
    ```
5. Enable the `systemd` service to run on startup, then start the service and check its status:
    ```bash
    sudo systemctl enable dnsproxy
    sudo systemctl start dnsproxy
    sudo systemctl status dnsproxy
    ```
6. Now test that it is working! Run the following `dig` command, a response should be returned similar to the one below:
    ```bash
    $ dig @127.0.0.1 -p 5353 example.com

    ; <<>> DiG 9.18.12-0ubuntu0.22.04.3-Ubuntu <<>> @127.0.0.1 -p 5353 example.com
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 45290
    ;; flags: qr rd ra ad; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 1232
    ;; QUESTION SECTION:
    ;example.com.			IN	A

    ;; ANSWER SECTION:
    example.com.		79150	IN	A	93.184.216.34

    ;; Query time: 20 msec
    ;; SERVER: 127.0.0.1#5353(127.0.0.1) (UDP)
    ;; WHEN: Thu Jan 11 18:28:05 UTC 2024
    ;; MSG SIZE  rcvd: 56
    ```

---

### Configuring Pi-hole

On the Pi-hole web interface, go to `Settings > DNS` and set the following:

![Screenshot of Pi-hole configuration](/images/screenshot-dnsproxy-adguard.png)

### Uninstalling `dnsproxy`

```bash
sudo systemctl stop dnsproxy
sudo systemctl disable dnsproxy
sudo systemctl daemon-reload
sudo deluser dnsproxy
sudo rm /usr/bin/dnsproxy
```

---

Guide based on the `cloudflared` guide from the [Pi-hole documentation](/guides/dns/cloudflared/).
