#!/usr/bin/env bash

regions=()
while IFS='' read -r line; do
    regions+=("$line")
done < <(aws ec2 describe-regions \
              --all-regions \
              --query "Regions[].{Name:RegionName}" \
              --output text)

for region in "${regions[@]}"; do
    aws --region "$region" ec2 delete-key-pair --key-name "$(whoami)-dsikey"
    aws --region "$region" ec2 delete-key-pair --key-name "ryan.timmons-dsikey"
    # aws --region "$region" ec2 delete-key-pair --key-name "ubuntu-dsikey"
done

rm -f ~/.ssh/*dsikey*

ssh-add -D
