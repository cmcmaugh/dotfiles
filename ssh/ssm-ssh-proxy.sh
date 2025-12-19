#!/usr/bin/env bash
set -euo pipefail

host="$1"
port="$2"

name="$host"
case "$name" in
  *.aws) name="${name%.aws}" ;;
esac

region="${AWS_REGION:-eu-west-1}"

# Ensure aws can find the session-manager-plugin even in non-interactive contexts
export PATH="@aws@:@plugin@:$PATH"

id="$(aws ec2 describe-instances \
  --region "$region" \
  --filters "Name=tag:Name,Values=$name" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].InstanceId | [0]" \
  --output text)"

if [[ -z "$id" || "$id" == "None" ]]; then
  echo "No running instance with tag Name=$name in region $region" >&2
  exit 1
fi

exec aws ssm start-session \
  --region "$region" \
  --target "$id" \
  --document-name AWS-StartSSHSession \
  --parameters "portNumber=$port"
