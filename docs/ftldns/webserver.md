### FTL's Embedded Webserver and Lua Server Pages

FTL comes with the embedded webserver [CivetWeb](https://github.com/civetweb/civetweb) supporting Lua server pages (LSP). This means you can write dynamic web content directly using Lua scripts, similar to how PHP is used in traditional web development. Lua offers several advantages over PHP in the embedded context:

- **Lightweight and Fast:** Lua has a very small memory footprint and is designed for high performance, making it ideal for our purposes.
- **Easy Integration:** Lua is easy to embed and extend, allowing seamless integration with FTL. We can easily bundle any Lua libraries we need, and they can be used directly in the webserver. No extra tools or external dependencies are required.
- **Simplicity:** Lua's syntax is straightforward and easy to learn, reducing the complexity of writing and maintaining server-side scripts.
- **Security:** Running Lua scripts within the FTL webserver provides a controlled environment, minimizing potential security risks compared to running a full PHP interpreter.

---

You can use the webserver to serve static files, dynamic content, or even custom HTTP responses (see the following examples). The webserver is configured through `pihole.toml` and can be accessed at `https://pi.hole/admin/`. Serving files outside of the webserver's home directory (`admin/`) is disabled by default for security reasons. It can be enabled by setting `webserver.serve_all` to `true`.

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
