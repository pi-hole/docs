<p align="center">
    <a href="https://pi-hole.net/">
        <img src="https://pi-hole.github.io/graphics/Vortex/Vortex_with_Wordmark.svg" width="150" height="260" alt="Pi-hole">
    </a>
    <br>
    <strong>Network-wide ad blocking via your own Linux hardware</strong>
</p>

The Pi-hole[®](https://pi-hole.net/trademark-rules-and-brand-guidelines/) is a [DNS sinkhole](https://en.wikipedia.org/wiki/DNS_Sinkhole) that protects your devices from unwanted content, without installing any client-side software.

## Documentation & User Guides

This repository is the source for the official [Pi-hole documentation](https://docs.pi-hole.net/).

### How to Contribute

**Adding a New Link to the Navigation Panel:**
- Edit the `mkdocs.yml` file at the root of the repository.
- Follow the guide for building the navbar on the [MkDocs Wiki](https://www.mkdocs.org/user-guide/configuration/#nav).

**Adding a New Document or Guide:**
1. Navigate to the appropriate directory (e.g., guides are in `docs/guides`).
2. Create a new file with a URL-friendly filename (e.g., `url-friendly.md`).
3. Use Markdown to edit your document. There are many resources available online for Markdown syntax.

### Testing Your Changes Locally

It's advised to review your changes locally before committing. Use the `mkdocs serve` command to live preview your changes on your local machine.

**General Steps:**
1. Fork the repository into your own Github account.
2. Clone your fork and navigate into it. You need only do this once:

    ```bash
    git clone https://github.com/YOUR-USERNAME/docs
    cd docs
    ```

3. Install dependencies:

    - **Linux Mint / Ubuntu:** (18.04/20.04/22.04 LTS/19.10 and up)

        ```bash
        sudo apt install python3-pip
        pip3 install -r requirements.txt
        ```

    - **Fedora Linux:** (tested on Fedora Linux 28)

        ```bash
        pip install --user -r requirements.txt
        ```

4. Run the local docs server:

    ```bash
    mkdocs serve --dev-addr 0.0.0.0:8000
    ```

**Docker Instructions:**
For a one-shot run with Docker, use the following command:

```bash
docker run -v $(pwd):/opt/app/ -w /opt/app/ -p 8000:8000 \
  -it nikolaik/python-nodejs:python3.7-nodejs16 \
  sh -c "pip install --user -r requirements.txt && \
  /root/.local/bin/mkdocs build && \
  npm ci && \
  npm test && \
  /root/.local/bin/mkdocs serve --dev-addr 0.0.0.0:8000"
```

After running the above, your changes will be accessible through your favorite browser at http://localhost:8000.