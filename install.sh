#!/bin/sh

create_symlinks() {
    # Get the directory in which this script lives.
    script_dir=$(dirname "$(readlink -f "$0")")
    echo "script_dir"
    echo "$script_dir"


    # Get a list of all files in this directory that start with a dot.
    files=$(find -maxdepth 1 -type f -name ".*")

    # Create a symbolic link to each file in the home directory.
    for file in $files; do
        name=$(basename $file)
        echo "==========================================================="
        echo "       Creating symlink to $name in home directory.        "
        echo "-----------------------------------------------------------"
        rm -rf ~/$name
        ln -s $script_dir/$name ~/$name
    done
}

create_symlinks