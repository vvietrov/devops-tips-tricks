## How to SQUASH a number of commits in a branch in order to simplify commits history.

Check out to the target branch. Let's assume it is **main** branch

`git checkout main`

Check the commits list with

`git log --oneline`

Example output:


```git log --oneline
69eff61 (HBAD -> main, origin/main, origin/HEAD) start
fe946bd add links to the pics
b9653c5 add subfolder for pics
7ddff98 Add files via upload
9fffad5 Create oracle_connector. md
0ed07df add Free Megabytes counter
9a2e405 typo
1c2f0e2 add vm-monitoring module
...
```

Let's assume we want to squash 5 last commits into one.

`git rebase -i HEAD~5`

VIM editor will appear and suggest actions for each of the last 5 commits. Please note, the last commit is the latest.

```
pick 9fffad5 Create oracle_connector. md
pick 7ddff98 Add files via upload
pick b9653c5 add subfolder for pics
pick fe946bd add links to the pics
pick 69eff61 start
```
Now edit the file to select the squashed commits. Replace **pick** with **squash**
```
pick 9fffad5 Create oracle_connector. md
squash 7ddff98 Add files via upload
squash b9653c5 add subfolder for pics
squash fe946bd add links to the pics
squash 69eff61 start
```
Save and exit with **:wq** twice

Check the new commits list:

`git log --oneline`
```
5b03899 (HEAD -> main) Create oracle_connector.md squashed
0ed07df add Free Megabytes counter
9a2e405 typo
1c2f0e2 add vm-monitoring module
```
We can confirm that 5 commits were squashed into one - **5b03899**

If necessary, push the changes to remote

`git push --force`

**DO NOT USE ON SHARED BRANCHES!**
**It may cause commits history chaos**