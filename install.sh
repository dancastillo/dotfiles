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

install_gcloud_cli() {
    sudo apt-get install apt-transport-https ca-certificates gnupg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install google-cloud-sdk

    echo $GLCOUD_AUTH >> /workspaces/.codespaces/.persistedshare/dotfiles/local.json
}

create_symlinks

install_gcloud_cli