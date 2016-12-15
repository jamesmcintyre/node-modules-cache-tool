#put these three functions in your .bash_profile or equivalent:

is_dir() {
  DIR=$1
  if [ -d $DIR ]; then
     echo "YES";
     exit;
  fi
  echo "NO";
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

  printf "Checking if "$current_branch_name" has a node_modules switch cache...\n"
  # cd ..
  # create new cache folder and move current node_modules to it
  if [ $(is_dir ".TemporaryItems/"$create_cache_folder_name) == "NO" ];
  then
    printf $current_branch_name" does not already have a switch cache, creating it...\n"
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
    #go back into project folder and switch to destination branch
    # cd $current_project_folder
    git checkout $dest_branch
    printf "cached "$current_branch_name" node_modules and checked out "$dest_branch"\n"
    #as if user wishes to npm i dest branch package.json
    read -p "Would you like to npm i the "$dest_branch" package.json?" -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        npm i
    fi
  fi
  git status
  printf "done ;)\n"
}

cache() {
  current_branch_name=$(git symbolic-ref -q HEAD)
  current_branch_name=${current_branch_name##refs/heads/}
  current_branch_name=${current_branch_name:-HEAD}
  current_project_folder=${PWD##*/}

  create_cache_folder_name=".cache_"$current_project_folder"_"$current_branch_name
  absolute_path_new_folder=$PWD"/.TemporaryItems/"$create_cache_folder_name"/"$node_modules

  printf "Checking if "$current_branch_name" has a node_modules switch cache...\n"
  # cd ..
  # create new cache folder and move current node_modules to it
  if [ $(is_dir ".TemporaryItems/"$create_cache_folder_name) == "NO" ];
  then
    printf $current_branch_name" does not already have a switch cache, creating it...\n"
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
