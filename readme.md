
# Elm Street Guest Portal

A custom captive portal for the GL.iNet GL-SFT1200 (Opal), powered by NoDogSplash.

The portal can automatically update from GitHub.

## Features

- Custom HTML captive portal
- GitHub-based updates
- Automatic updates every 15 minutes
- Previous-version backup
- Basic HTML validation
- NoDogSplash authentication support
- Compatible with OpenWrt 18.06

## Repository Structure

elm-street-portal/
├── README.md
├── splash.html
└── router/
    └── update-portal.sh

## Requirements

- GL.iNet GL-SFT1200
- NoDogSplash installed and configured
- SSH access
- Internet access
- Public GitHub repository

## Installation

### 1. Configure GitHub

Create a public GitHub repository.

Upload all project files.

Edit `router/update-portal.sh` and update:

    REPO_OWNER="carteraccs"
    REPO_NAME="router-splash"

### 2. Install the updater

Connect to your router through SSH.

Save the updater script to:

    /root/update-portal.sh

Make it executable:

    chmod 700 /root/update-portal.sh

Run the updater:

    /root/update-portal.sh

The script downloads splash.html from GitHub and installs it at:

    /etc/nodogsplash/htdocs/splash.html

### 3. Enable Automatic Updates

Run:

    grep -Fq '/root/update-portal.sh' /etc/crontabs/root || echo '*/15 * * * * /root/update-portal.sh >> /tmp/portal-update.log 2>&1' >> /etc/crontabs/root

    /etc/init.d/cron enable
    /etc/init.d/cron restart

The router will check GitHub every 15 minutes.

### 4. View Update Logs

Run:

    cat /tmp/portal-update.log

Or:

    logread | grep portal-update

## Updating the Portal

1. Open the GitHub repository.
2. Edit splash.html.
3. Commit your changes.
4. The router checks for changes automatically.
5. New guests see the updated page.

No router restart is normally required.

## Manual Update

Run:

    /root/update-portal.sh

## Restore Previous Version

Run:

    cp /etc/nodogsplash/htdocs/splash.html.previous /etc/nodogsplash/htdocs/splash.html

Disable automatic updating temporarily if you want the restored version to remain active.

## Important Notes

The splash page must contain NoDogSplash authentication variables, such as:

    $authtarget

Or:

    $authaction
    $tok

Removing these may prevent guests from connecting.

Keep your GitHub repository public so your router can download the HTML without authentication.

Never store admin credentials in the repository.

HTTPS downloads must work with certificate verification enabled.

## License

MIT
