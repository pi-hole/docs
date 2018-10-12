##	Documentation & User Guides

This repo is the source for the official [Pi-hole documentation](https://docs.pi-hole.net/).

#### How to contribute.
To add a new link on the navigation panel you need to edit the `mkdocs.yml` file in the root of the repo. There is a guide for building the navbar [on the mkdocs wiki]( https://www.mkdocs.org/user-guide/configuration/#nav)

To add a new document or guide. 

- Navigate to the directory where it will be hosted.  
	EG. guides are in `REPO/docs/guides`
- Create the file using a URL friendly filename.  
	EG. `docs/guides/url-friendly.md`
- Edit your document using Markdown, there are loads of resources available for the correct syntax.


#### Testing your changes.
Whilst working on this repo, it is advised that you review your own changes locally before commiting them. This can be done by using the `mkdocs serve` command. 

Linux Mint / Ubuntu instructions:
```
git clone git@github.com:pi-hole/docs.git
cd docs
sudo pip install mkdocs
sudo pip install mkdocs-material markdown-include
mkdocs serve --dev-addr 0.0.0.0:8000
```

#### Deploying to GitHub pages:
```
mkdocs gh-deploy
```
MkDocs will build the docs and use the `ghp-import` tool to commit them to our `gh-pages` branch and also automatically push the `gh-pages` branch to GitHub.

