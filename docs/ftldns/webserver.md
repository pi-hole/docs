### FTL's Embedded Webserver and Lua Server Pages

FTL comes with the embedded webserver [CivetWeb](https://github.com/civetweb/civetweb) supporting Lua server pages (LSP). This means you can write dynamic web content directly using Lua scripts, similar to how PHP is used in traditional web development. Lua offers several advantages over PHP in the embedded context:

- **Lightweight and Fast:** Lua has a very small memory footprint and is designed for high performance, making it ideal for our purposes.
- **Easy Integration:** Lua is easy to embed and extend, allowing seamless integration with FTL. We can easily bundle any Lua libraries we need, and they can be used directly in the webserver. No extra tools or external dependencies are required.
- **Simplicity:** Lua's syntax is straightforward and easy to learn, reducing the complexity of writing and maintaining server-side scripts.
- **Security:** Running Lua scripts within the FTL webserver provides a controlled environment, minimizing potential security risks compared to running a full PHP interpreter.

---

You can use the webserver to serve static files, dynamic content, or even custom HTTP responses (see the following examples). The webserver is configured through `pihole.toml` and can be accessed at `https://pi.hole/admin/`. Serving files outside of the webserver's home directory (`admin/`) is disabled by default for security reasons. It can be enabled by setting `webserver.serve_all` to `true`.

### HTTP/2 and HTTP/3

On encrypted ports, FTL terminates TLS itself and speaks HTTP/1.1, HTTP/2 and HTTP/3, whichever the client asks for. CivetWeb keeps serving the actual content over HTTP/1.1 behind that front end, which is why the Lua pages and everything else described on this page work the same regardless of the protocol version a browser picked.

The protocol is chosen through ALPN during the TLS handshake, so there is nothing to configure and nothing to enable:

- **HTTP/1.1** is used by clients that ask for nothing else, and on plaintext ports.
- **HTTP/2** (`h2`) is used by every current browser on your HTTPS port.
- **HTTP/3** (`h3`) runs on QUIC, i.e., on **UDP** with the same port number as the HTTPS port. Because a browser cannot know this in advance, FTL advertises it in an `Alt-Svc` header on its HTTP/2 responses, and the browser transparently switches over for subsequent requests.

The practical consequence is the firewall: if you only allow TCP to your web server port, everything keeps working but clients never get past HTTP/2, because their QUIC attempts on UDP time out. Allow UDP on the same port to make HTTP/3 usable.

TLS 1.2 is the lowest version FTL accepts. Clients older than that cannot connect at all, which in practice concerns only rather ancient devices.

### Example 1: Custom HTTP status code

Create a file like

``` plain
HTTP/1.1 204 No Content
Connection: close
Cache-Control: max-age=0, must-revalidate

```

Two important things here: You need to save it using "MS-DOS formatting" (`\r\n` line endings) and there needs to be a single trailing line.

### Example 2: Regular page but manual headers

You could also use it for "regular" pages, e.g.,

``` plain
HTTP/1.0 200 OK
Content-Type: text/html

<html><body>
        <p><?= 1+1 ?></p>
</body></html>
```

which will print an empty page with "2" on it.
