 ##	Documentation & User Guides

This repo is the source for the official [Pi-hole documentation](https://docs.pi-hole.net/).

#### How to contribute.
To add a new link on the navigation panel you need to edit the `mkdocs.yml` file in the root of the repo. There is a guide for building the navbar [on the mkdocs wiki]( https://www.mkdocs.org/user-guide/configuration/#nav)

To add a new document or guide. 

- Navigate to the directory where it will be hosted.  
	EG. guides are in `docs/guides`
- Create the file using a URL friendly filename.  
	EG. `docs/guides/url-friendly.md`
- Edit your document using Markdown, there are loads of resources available for the correct syntax.


#### Testing your changes.
Whilst working on this repo, it is advised that you review your own changes locally before commiting them. This can be done by using the `mkdocs serve` command.  

Please make sure you fork the repo and change the clone URL in the example below for your fork:

```bash
git clone https://github.com/YOUR-USERNAME/docs
cd docs
sudo pip install mkdocs
sudo pip install mkdocs-material markdown-include
mkdocs serve --dev-addr 0.0.0.0:8000
```
