#put these three functions in your .bash_profile or equivalent:

is_dir() {
  DIR=$1
  if [ -d $DIR ]; then
     echo "YES";
     exit;
  fi
  echo "NO";
}
switch_check_current_exists() {
  #check if cache already exists, ask to overwite if so
  printf "Checking if "$current_branch_name" has a node_modules switch cache...\n"
  if [ $(is_dir ".TemporaryItems/"$create_cache_folder_name) == "YES" ];
  then
    if [ $(is_dir "node_modules/") == "YES" ];
    then
      read -p "A switch cache for "$current_branch_name" already exists, overwrite it?" -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]
      then
        rm -rf ".TemporaryItems/"$create_cache_folder_name"/"
        printf "cleared old cache for "$current_branch_name"\n"
      fi
    else
      printf $current_branch_name" already has a cache and you have no active node_modules/ to cache so moving on...\n"
    fi
  fi
  # create new cache folder and move current node_modules to it
  if [ $(is_dir ".TemporaryItems/"$create_cache_folder_name) == "NO" ];
  then
    printf $current_branch_name" does not have a switch cache, creating it...\n"
    if [ $(is_dir ".TemporaryItems/") == "NO" ];
    then
      mkdir ".TemporaryItems"
    fi
    cd .TemporaryItems/
    mkdir $create_cache_folder_name
    cd ..
    mv "node_modules/" ".TemporaryItems/"$create_cache_folder_name"/node_modules"
    printf "cache created at "$absolute_path_new_folder"\n"
  fi
}
switch_pull_from_cache() {
  # check if destination branch has an existing node_modules cache and pull from it if so
  printf "checking if "$dest_branch" has an existing node_modules switch cache\n"
  if [ $(is_dir ".TemporaryItems/"$dest_branch_cache_folder"/node_modules") == "YES" ];
  then
    #cache existed, move it back to project folder and cd back into project and checkout dest_branch
    printf $dest_branch" does have a switch cache, pulling from it...\n"
    mv ".TemporaryItems/"$dest_branch_cache_folder"/node_modules" .
    rm -rf ".TemporaryItems/"$dest_branch_cache_folder"/"
    git checkout $dest_branch
    printf $dest_branch" cache restored and checked out branch "$dest_branch"\n"
  else
    #if no cache cd back into project, checkout dest branch, ask to npm i
    printf $dest_branch" does not have an existing switch cache\n"
    #switch to destination branch
    git checkout $dest_branch
    printf "cached "$current_branch_name" node_modules and checked out "$dest_branch"\n"
    #ask if user wishes to npm i dest branch package.json
    read -p "Would you like to npm i the "$dest_branch" package.json? (Remember, you may want to pull latest remote version before npm i.)\n" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        npm i
    fi
  fi
}
switch() {
  current_branch_name=$(git symbolic-ref -q HEAD)
  current_branch_name=${current_branch_name##refs/heads/}
  current_branch_name=${current_branch_name:-HEAD}
  current_project_folder=${PWD##*/}

  create_cache_folder_name=".cache_"$current_project_folder"_"$current_branch_name
  absolute_path_new_folder=$PWD"/.TemporaryItems/"$create_cache_folder_name"/"$node_modules

  dest_branch=$1
  dest_branch_cache_folder=".cache_"$current_project_folder"_"$dest_branch

  #check if cache already exists, ask to overwite if so
  switch_check_current_exists
  # check if destination branch has an existing node_modules cache and pull from it if so
  switch_pull_from_cache

  git status
  printf "done ;)\n"
  return
}
cache() {
  current_branch_name=$(git symbolic-ref -q HEAD)
  current_branch_name=${current_branch_name##refs/heads/}
  current_branch_name=${current_branch_name:-HEAD}
  current_project_folder=${PWD##*/}

  create_cache_folder_name=".cache_"$current_project_folder"_"$current_branch_name
  absolute_path_new_folder=$PWD"/.TemporaryItems/"$create_cache_folder_name"/"$node_modules

  #check if cache already exists, ask to overwite if so
  switch_check_current_exists
  return
}
