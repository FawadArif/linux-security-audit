# Linux Security Audit Tool

A Bash script that audits a Linux server against common hardening checks and produces a timestamped pass/fail report.

## Checks

- SSH root login disabled
- SSH password authentication disabled
- Firewall (ufw) active
- No accounts with empty passwords
- Only root has UID 0
- No world-writable files in `/etc`
- Lists open listening ports

## Requirements

- Linux (tested on Kali Linux / Ubuntu)
- Bash 4+
- Root privileges (needed to read `/etc/shadow`)

## Usage

```bash
git clone https://github.com/yourusername/linux-security-audit.git
cd linux-security-audit
chmod +x audit.sh
sudo ./audit.sh
```

## Sample output

```
Security audit - kali - Fri Nov 06 2026
[PASS] SSH root login disabled
[FAIL] SSH password auth disabled
[FAIL] Firewall (ufw) active
[PASS] No accounts with empty passwords
[PASS] Only root has UID 0
[PASS] No world-writable files in /etc
Summary: 4 passed, 2 failed
```

Reports are saved as `audit_YYYY-MM-DD_HHMM.txt` in the current directory.

## CI usage

The script exits with a non-zero code if any check fails, so it can be used as a gate in Jenkins or GitHub Actions:

```bash
sudo ./audit.sh || echo "Hardening checks failed"
```

## Remediation tips

| Failed check | Fix |
|---|---|
| SSH root login | Set `PermitRootLogin no` in `/etc/ssh/sshd_config`, then `sudo systemctl restart ssh` |
| SSH password auth | Set `PasswordAuthentication no` (after setting up SSH keys) |
| Firewall | `sudo ufw enable` |

## Disclaimer

Use only on systems you own or are authorised to audit.

## Author

Adeebi: [LinkedIn](https://linkedin.com/in/yourprofile) | [GitHub](https://github.com/yourusername)
