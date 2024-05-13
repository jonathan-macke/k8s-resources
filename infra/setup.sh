
#!/bin/sh

source ./startCluster.sh

current_dir=$(pwd)

folders=("vault" "external-secrets" "postgresql")

for folder in "${folders[@]}"; do
    script="${folder}/setup.sh"
    chmod +x $script
    cd $folder
    source "./setup.sh"
    cd $current_dir
done

