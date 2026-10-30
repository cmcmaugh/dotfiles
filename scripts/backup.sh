#!/usr/bin/env bash

backup_files="${HOME}/aws ${HOME}/work/server_cert ${HOME}/.ssh ${HOME}/.aws-default ${HOME}/.TinyCA"

dest="${HOME}/Dropbox/backups"
day=$(date +%Y%m%d)
archive_file="$day.tgz.gpg"

tar cz  $backup_files | gpg -c -o $dest/$archive_file
echo done
