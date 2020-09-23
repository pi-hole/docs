# Route the entire Internet traffic through the WireGuard tunnel

Routing your entire Internet traffic is **optional**, however, it can be advantageous in cases where you are expecting eavesdropping on the network. This may not only happen in unsecure open Wi-Fi networks (airports, hotels, trains, etc.) but also in encrypted Wi-Fi networks where the creator of the network can monitor client activity.

Rerouting the Internet traffic through your Pi-hole will furthermore cause all of your Internet traffic to reach the Internet from the place where your WireGuard server is located. This can be used to obfuscate your real location as well as to be allowed to access geo-blocked content, e.g., when your Pi-hole is located in Germany but you are traveling in the United States. If you want to access a page only accessible from within Germany (like the live-broadcast of Tagesschau, etc.), this will typically not work. However, if you route your entire Internet through your Pi-hole, your network traffic will originate from Germany, allowing you to watch the content.

!!! info "Ensure you're already forwarding traffic"
    The following assumes you have already prepared your Pi-hole for [IP forwarding](internal.md). If this is not the case, follow the steps over there before continuing here.

To route all traffic through the tunnel to a specific peer, add the default route (`0.0.0.0/0` for IPv4 and `::/0`for IPv6) to `AllowedIPs` in your clients's WireGuard config files:

```toml
AllowedIPs = 0.0.0.0/0, ::/0
```

<!-- markdownlint-disable code-block-style -->
!!! warning "Change this setting only on your clients"
    Do **not** set this on the server in the `[Interface]` section. WireGuard will automatically take care of setting up [correct routing](https://www.wireguard.com/netns/#routing-all-your-traffic) so that networking still functions on all your clients.
<!-- markdownlint-enable code-block-style -->

That's all you need to do. You should use an online check (e.g. www.wieistmeineip.de) to check if your IP changed to the public IP address of your WireGuard server after this change up. It is possible to add this change only for a few clients, leaving the others without a full tunnel for all traffic (e.g., where this is not necessary or not desired).

{!abbreviations.md!}
