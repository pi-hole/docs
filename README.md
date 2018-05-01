If you want to work on this repo, you can preview the site as you work.

Linux Mint / Ubuntu instructions:

```
git clone git@github.com:pi-hole/docs.git
cd docs
sudo pip install mkdocs
sudo pip install mkdocs-material
mkdocs serve
```

Deploying to GitHub pages:
```
mkdocs gh-deploy
```
MkDocs will build the docs and use the `ghp-import` tool to commit them to our `gh-pages` branch and also automatically push the `gh-pages` branch to GitHub.
Warning: Be aware that you will not be able to review the built site before it is pushed to GitHub! Therefore, you **must** verify any changes you make to the docs beforehand by using the `mkdocs serve` command and reviewing the built files locally.
