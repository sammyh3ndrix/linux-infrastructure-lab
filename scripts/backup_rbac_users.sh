#!/bin/bash
timestamp=$(date +%Y%m%d_%H%M%S)
echo "$timestamp"
users_path=/home/sammy/python-rbac-auth-lab/users.json
backup_path=/var/backups/rbac_users
sudo mkdir -p "$backup_path"
sudo cp "$users_path" "$backup_path/users_backup_$timestamp.json"
pattern="users_backup_*.json"
sudo find "$backup_path" -type f -name "$pattern" -mtime +7 -delete
