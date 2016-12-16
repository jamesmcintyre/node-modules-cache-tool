# node-modules-cache-tool
Two bash functions you can put in your .bash_profile (or equivalent) to allow you to easily switch between multiple branches and their respective node_modules folder.

**_Use at your own risk! This is very new and I've only tested it with my own use on OSX._**

## Install
Just take the contents of bash_function.sh and paste it into your .bash_profile (or equivalent).

## Alternate Install
Create a folder called "scripts" in your home directory (should be the same directory as your .bash_profile). Then create a file called "switch.sh" in it and paste the contents of "bash_function.sh" into it. Then paste this into your ".bash_profile":

```
# this pulls in script(s) from ~/scripts
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/scripts/switch.sh"
```


## What problem are we solving?

Let's say you are on master branch and you've run "**npm i**" to install node modules to "**node_modules/**". But now you want to switch to a branch called "my-branch" which has a very different "**package.json**". Normally you'd have to switch to the branch then "**rm -rf node_modules/**" then run "**npm i**" again to install the correct modules for the branch you've just switched to. What happens when you want to quickly switch back to **master** and to, say, run the app and see how it behaves in comparison to the changes you've made on your branch "my-branch". This means you'd have to do all those steps all over again. This might not be a big deal if you're doing this switching infrequently or if you only have a couple dependancies so your install runs fast but what if you have a ton of dependancies and you're constantly needing to switch between branches/node_modules?

## How to Use

Let's say you're switching from 'master' branch to 'my-fork' (both local):
```
switch my-fork
```
This command will cache your current node_modules/ folder to .TemporaryItems/ then check if you have node_modules/ cached for the branch 'my-fork' and restore them if you do. Lastly it switches to the branch my-fork and shows status.

The result is that you should now be on branch 'my-fork' with the corresponding 'node_modules/' folder (determined by the package.json from that branch).

If you did not have a cached copy of 'my-fork''s node_modules/ it will ask if you'd like to run 'npm i' to install them.

Now you could switch back by running this command:
```
switch master
```
This will cache 'my-fork''s node_modules/ and retrieve 'master''s modules from the cache, restore it and switch to master branch.


Lastly, let's say you want to create a new branch (or pull a remote branch down) but you want to just cache the node_modules/ for the current branch you're moving off of so that you can switch back to it later. Just run:
```
cache
```
This will only move your current 'node_modules/' folder to '.TemporaryItems/.cache_project-folder-name_branch-name/node_modules/' and it will do nothing with git (such as switching branch). If the cache already exists it will ask if you'd like to overwrite it.

This would allow you to cache your current node_modules/ then create a new branch, change the package.json and re-run 'npm i' to create a new node_modules/. At this point you can now switch back to an already cached branch if you'd like:
```
switch master
```
and this would cache the new branches 'node_modules/' and restore 'master' branches so that you could switch back later.
