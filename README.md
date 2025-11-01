# Network Reset Utility

![Platform](https://img.shields.io/badge/platform-Windows-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-1.0.0-orange)
![Batch](https://img.shields.io/badge/language-Batch-yellow)
![Admin Required](https://img.shields.io/badge/admin-required-red)
![Status](https://img.shields.io/badge/status-stable-brightgreen)

A comprehensive Windows network reset utility that automatically elevates to administrator privileges and performs complete network stack reset operations.

## ✨ Features

- **Auto-elevation** to Administrator privileges
- **Comprehensive network reset** including:
  - Winsock catalog reset
  - DNS cache flush
  - TCP/IP stack reset
  - Network adapter reset (IPv4/IPv6)
  - Windows Firewall reset
  - IP configuration renewal
- **Error handling** with retry mechanisms
- **Recovery steps** for failed operations
- **User confirmation** prompts for safety
- **Detailed progress** reporting

## 🚀 Usage

1. Double-click `network-reset.bat`
2. Click "Yes" when prompted for Administrator privileges
3. Confirm the operation when asked
4. Wait for the reset process to complete
5. Restart when prompted (recommended)

## ⚠️ Requirements

- Windows operating system
- Administrator privileges (auto-requested)
- Active internet connection (will be temporarily reset)

## 🛡️ Safety Features

- Input sanitization
- Administrator privilege verification
- User confirmation prompts
- Graceful error handling
- Safe fallback operations

## 📋 What It Does

The script performs the following operations in sequence:

1. **Winsock Reset** - Resets the Windows Socket API
2. **DNS Flush** - Clears DNS resolver cache
3. **TCP/IP Reset** - Resets the TCP/IP stack
4. **Adapter Reset** - Resets IPv4 and IPv6 interfaces
5. **Firewall Reset** - Restores Windows Firewall defaults
6. **IP Renewal** - Releases and renews IP configuration

## 🔧 Troubleshooting

If you encounter issues:

- Ensure you have Administrator privileges
- Temporarily disable antivirus software
- Run Windows Network Troubleshooter first
- Check Windows Event Logs for additional details

## ⚡ Quick Fix

This utility is perfect for resolving:
- DNS resolution issues
- Network connectivity problems
- Corrupted network configurations
- Internet connection instability

## 📄 License

MIT License - Feel free to use and modify as needed.

## ⚠️ Disclaimer

Use at your own risk. Always ensure you have alternative internet access available in case manual network reconfiguration is needed.
