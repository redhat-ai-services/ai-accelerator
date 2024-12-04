# Rebasing from Upstream

When forking and using the repo it can often be valuable to rebase your copy from upstream to get some of the latest changes.

## Pulling upstream

From your local fork of the ai-accelerator repo

Be sure you have the upstream repo set as a remote named `upstream`

```
git remote add upstream git@github.com:redhat-ai-services/ai-accelerator.git
```

If you don't already have an upstream branch, checkout a local copy of the upstream/main branch as a branch called upstream:

```
git checkout -b upstream upstream/main
```

If you already have an upstream branch, pull the latest version of the branch

```
git checkout upstream
git pull upstream main
```

Use `git log` to validate that he latest commits from the upstream branch have been pulled successfully.

## Rebasing

Next you will need to rebase your `upstream` branch from your local main.

To begin, make sure your local main branch is up to date with your fork.

```
git checkout main
git pull origin main
```

You can now start the rebase from main

```
git checkout upstream
git rebase main
```

You may have merge conflicts that need to be resolved depending on what changes you have made to your fork.  Work through the standard merge conflict process.

Once you are done, it is recommended to push your upstream repo to GitHub and create a PR from your updated upstream branch into main.  Be sure to validate any changes that the upstream rebase introduced.
