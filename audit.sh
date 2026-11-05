#!/usr/bin/env bash
set -uo pipefail

REPORT="audit_$(date +%F_%H%M).txt"
PASS=0; FAIL=0

check() {  # usage: check "description" "command that returns 0 if OK"
  if eval "$2" >/dev/null 2>&1; then
    echo "[PASS] $1" | tee -a "$REPORT"; ((PASS++))
  else
    echo "[FAIL] $1" | tee -a "$REPORT"; ((FAIL++))
  fi
}

echo "Security audit - $(hostname) - $(date)" | tee "$REPORT"

check "SSH root login disabled" \
  "grep -Eqi '^PermitRootLogin\s+no' /etc/ssh/sshd_config"
check "SSH password auth disabled" \
  "grep -Eqi '^PasswordAuthentication\s+no' /etc/ssh/sshd_config"
check "Firewall (ufw) active" \
  "ufw status | grep -q 'Status: active'"
check "No accounts with empty passwords" \
  "[ -z \"\$(awk -F: '(\$2==\"\"){print \$1}' /etc/shadow)\" ]"
check "Only root has UID 0" \
  "[ \"\$(awk -F: '(\$3==0){print \$1}' /etc/passwd)\" = 'root' ]"
check "No world-writable files in /etc" \
  "[ -z \"\$(find /etc -xdev -type f -perm -0002 2>/dev/null)\" ]"

echo "Listening ports:" | tee -a "$REPORT"
ss -tuln | tee -a "$REPORT"

echo "Summary: $PASS passed, $FAIL failed" | tee -a "$REPORT"
exit $(( FAIL > 0 ))
