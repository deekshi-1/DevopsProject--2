#!/usr/bin/env bash
set -euo pipefail

echo "== EC2 reachability =="
IPS=$(cd terraform/environments/dev && terraform output -json web_public_ips | jq -r '.[]')
for ip in $IPS; do
  echo "Pinging $ip..."
  timeout 5 nc -zv "$ip" 22 && echo "  SSH port reachable" || { echo "  SSH unreachable"; exit 1; }
done

echo "== Security group validation =="
SG_ID=$(cd terraform/environments/dev && terraform output -raw web_sg_id 2>/dev/null || true)
if [ -n "$SG_ID" ]; then
  aws ec2 describe-security-groups --group-ids "$SG_ID" \
    --query 'SecurityGroups[0].IpPermissions' --output table
fi

echo "== Application health check =="
for ip in $IPS; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$ip/")
  if [ "$STATUS" == "200" ]; then
    echo "  $ip -> HTTP 200 OK"
  else
    echo "  $ip -> HTTP $STATUS (FAILED)"
    exit 1
  fi
done

echo "== Service availability (systemd) =="
for ip in $IPS; do
  ssh -o StrictHostKeyChecking=no ubuntu@"$ip" \
    "systemctl is-active nginx && sudo docker inspect -f '{{.State.Running}}' hello-app"
done

echo "All validation checks passed."