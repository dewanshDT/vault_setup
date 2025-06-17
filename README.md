# Vaultwarden Self-Hosted Setup

Automated deployment of Vaultwarden with Docker Compose, secured behind Caddy reverse proxy with HTTPS support, along with Google Drive backups and restoration support.

---

## ⚙️ Features

- ✅ **Vaultwarden** password manager (unofficial Bitwarden server)
- ✅ **Docker Compose** managed
- ✅ **Caddy Reverse Proxy** for HTTPS with custom certificates
- ✅ **Automated Backups** to Google Drive using `rclone`
- ✅ **Automatic Cleanup** of old backups (keeps last 7 backups)
- ✅ **Restore Script** to bring Vaultwarden back from backup quickly
- ✅ **Fully automated** setup via `setup.sh`

---

## 🏁 Setup Instructions

### 1️⃣ Run Setup Script

```bash
git clone <repo-url>
cd vaultwarden-selfhost
chmod +x setup.sh
sudo bash setup.sh
```

- This creates everything in:
  **`/opt/vaultwarden-selfhost/`**

---

### 2️⃣ Start Vaultwarden

```bash
cd /opt/vaultwarden-selfhost
docker compose up -d
```

- Default access URL: `https://vault.lan` _(requires DNS + HTTPS setup below)_

---

## 🌐 LAN & HTTPS Setup

### 🔗 Local DNS Entry (For Pi-hole or Manual Hosts File)

```
vault.lan → <Your-LAN-IP>
```

### 📜 Root Certificate Setup

Caddy expects your certificate files at:

```
/etc/caddy/certs/root.crt
/etc/caddy/certs/root.key
```

Install root certificate on your devices:

#### ➤ Android:

Settings → Security → Encryption & credentials → Install certificate → CA certificate → Select `root.crt`

#### ➤ Windows:

- Run `certmgr.msc`
- Import into: **Trusted Root Certification Authorities → Certificates**

#### ➤ macOS:

- Open **Keychain Access**
- Import into **System → Certificates**
- Set **Trust → Always Trust**

---

## 💾 Backups

### To Create Backup:

```bash
cd /opt/vaultwarden-selfhost
./backup.sh
```

- Uploads to **Google Drive** (configured via `rclone` beforehand)
- Keeps last 7 backups on both local and cloud
- Cleans up older backups automatically

---

## ♻️ Restore From Backup

```bash
cd /opt/vaultwarden-selfhost
./restore.sh backups/vaultwarden-YYYY-MM-DD.tar.gz
```

- Stops Vaultwarden
- Deletes existing data
- Restores selected backup
- Starts Vaultwarden again

---

## 🖥️ File Structure

```
/opt/vaultwarden-selfhost/
├── docker-compose.yml
├── Caddyfile
├── backup.sh
├── restore.sh
├── .gitignore
├── README.md
└── backups/      # (auto-created)
```

---

## 📦 Google Drive Setup (with rclone)

1️⃣ Install `rclone`:

```bash
curl https://rclone.org/install.sh | sudo bash
```

2️⃣ Configure remote:

```bash
rclone config
```

3️⃣ Use remote name: **`gdrive`**
4️⃣ Ensure folder **`vaultwarden-backups/`** exists in your Google Drive.

---

## 📝 Notes

- **Admin Panel**: `https://vault.lan/admin`
- Enable **2FA** from the Admin Panel → `Two-step login`
- Protect `/admin` route separately in Caddy if needed

---

## 🛡️ Restore Plan

- Clone the repo or restore manually to `/opt/vaultwarden-selfhost`
- Restore backup with `./restore.sh`
- Reinstall certificates on fresh systems if required

---

## 🚀 Enjoy Your Private Vaultwarden!

```

Let me know when you want the `setup.sh` file again too — ready whenever you are.
```
