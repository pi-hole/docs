#### Forking and Cloning from GitHub to GitHub

1. Fork <https://github.com/pi-hole/pi-hole/> to a repo under a namespace you control, or have permission to use, for example: `https://github.com/<your_namespace>/<your_repo_name>/`. You can do this from the github.com website.
2. Clone `https://github.com/<your_namespace>/<your_repo_name>/` with the tool of you choice.
3. To keep your fork in sync with our repo, add an upstream remote for pi-hole/pi-hole to your repo.

    ```
    git remote add upstream https://github.com/pi-hole/pi-hole.git
    ```

4. Checkout the `development` branch from your fork `https://github.com/<your_namespace>/<your_repo_name>/`.
5. Create a topic/branch, based on the `development` branch code. *Bonus fun to keep to the theme of Star Trek/black holes/gravity.*
6. Make your changes and commit to your topic branch in your repo.
7. Rebase your commits and squash any insignificant commits. See the notes below for an example.
8. Merge `development` your branch and fix any conflicts.
9. Open a Pull Request to merge your topic branch into our repo's `development` branch.

- Keep in mind the technical requirements from above.

#### Forking and Cloning from GitHub to other code hosting sites

Forking is a GitHub concept and cannot be done from GitHub to other git-based code hosting sites. However, those sites may be able to mirror a GitHub repo.

1. To contribute from another code hosting site, you must first complete the steps above to fork our repo to a GitHub namespace you have permission to use, for example: `https://github.com/<your_namespace>/<your_repo_name>/`.
2. Create a repo in your code hosting site, for example: `https://gitlab.com/<your_namespace>/<your_repo_name>/`
3. Follow the instructions from your code hosting site to create a mirror between `https://github.com/<your_namespace>/<your_repo_name>/` and `https://gitlab.com/<your_namespace>/<your_repo_name>/`.
4. When you are ready to create a Pull Request (PR), follow the steps `(starting at step #6)` from [Forking and Cloning from GitHub to GitHub](#forking-and-cloning-from-github-to-github) and create the PR from `https://github.com/<your_namespace>/<your_repo_name>/`.

#### Notes for squashing commits with rebase

To rebase your commits and squash previous commits, you can use:

```
  git rebase -i your_topic_branch~(number of commits to combine)
```

For more details visit [gitready.com](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html)

1. The following would combine the last four commits in the branch `mytopic`.

    ```
    git rebase -i mytopic~4
    ```

2. An editor window opens with the most recent commits indicated: (edit the commands to the left of the commit ID)

    ```
    pick 9dff55b2 existing commit comments
    squash ebb1a730 existing commit comments
    squash 07cc5b50 existing commit comments
    reword 9dff55b2 existing commit comments
    ```

3. Save and close the editor. The next editor window opens: (edit the new commit message). *If you select reword for a commit, an additional editor window will open for you to edit the comment.*

    ```
    new commit comments
    Signed-off-by: yourname <your email address>
   ```

4. Save and close the editor for the rebase process to execute. The terminal output should say something like the following:

    ```
    Successfully rebased and updated refs/heads/mytopic.
    ```

5. Once you have a successful rebase, and before you sync your local clone, you have to force push origin to update your repo:

    ```
    git push -f origin
   ```

6. Continue on from step #7 from [Forking and Cloning from GitHub to GitHub](#forking-and-cloning-from-github-to-github)
