<p align="center">
<a href="https://pi-hole.net"><img src="https://pi-hole.github.io/graphics/Vortex/Vortex_with_text.png" width="150" height="255" alt="Pi-hole"></a>
<br/><br/>
<b>Network-wide ad blocking via your own Linux hardware</b><br/>
</p>

The Pi-hole[®](https://pi-hole.net/trademark-rules-and-brand-guidelines/) is a [DNS sinkhole](https://en.wikipedia.org/wiki/DNS_Sinkhole) that protects your devices from unwanted content, without installing any client-side software.

This repository provides the official Pi-hole documentation you can find here: https://docs.pi-hole.net
If you want to work on the documentation, you can live preview your changes (as you type) on your local machine. We compiled instructions tested on Linux Mint 18 and Fedora 28:

- Linux Mint / Ubuntu instructions:
   - Preparations (only required once):
   ```
   git clone git@github.com:pi-hole/docs.git
   cd docs
   sudo pip install mkdocs
   sudo pip install mkdocs-material markdown-include
   ```
   - Running the docs server:
   ```
   mkdocs serve --dev-addr 0.0.0.0:8000
   ```

- Fedora Linux instructions:
   - Preparations (only required once):
   ```
   git clone git@github.com:pi-hole/docs.git
   cd docs
   pip install mkdocs --user
   pip install mkdocs-material markdown-include --user
   ```
   - Running the docs server:
   ```
   mkdocs serve --dev-addr 0.0.0.0:8000
   ```

After these commands, the currently checked out branch is accessible through your favorite browser at http://localhost:8000
