---
layout: post
title: Ultimate Windows Automation
image:
  path: "/assets/img/2024/thumbs/ultimate-powershell.webp"
categories:
- Automation
- Project
tags:
- Powershell
- Windows
- Autohotkey
- Git
- Linux
- Bash
date: 2024-01-31 11:02 +0200
---
## Introduction

[PowerShell](https://aka.ms/powershell){:target="_blank"}, a powerful scripting language developed by Microsoft, has become a go-to tool for Windows automation. In this blog post, we'll explore the Ultimate PowerShell Windows Automation Project, consists of a set of scripts and configurations designed to enhance Windows experience. Let's dive into some of the key scripts and the project architecture.

## Project Architecture

```vim
ultimate-powershell/
├── files/
│   ├── autohotkey/
│   │   ├── identify_fix.ahk
│   │   └── ultimate_keys.ahk
│   ├── sharex/
│   │   └── ShareX_backup.sxb
│   └── terminal/
│       ├── pwsh_scripts/
│       │   ├── rebootRemotely.ps1
│       │   ├── SFTA.ps1
│       │   ├── sshCopyID.ps1
│       │   └── wakeOnLan.ps1
│       ├── walls/
│       ├── PowerShell5_profile.ps1
│       └── PowerShell7_profile.ps1
├── tasks/
│   ├── software/
│   │   ├── autohotkey.ps1
│   │   ├── oh_my_posh.ps1
│   │   ├── scoop_packages.ps1
│   │   └── sharex.ps1
│   ├── system_setup/
│   │   ├── tweaks/
│   │   │   ├── oosu10.ps1
│   │   │   └── remove_onedrive.ps1
│   │   ├── openssh.ps1
│   │   ├── tweaks.ps1
│   │   └── wsl.ps1
│   └── main.ps1
├── local.ps1
├── pre-commit.ps1
└── README.md
```

This Project draws inspiration from Ansible, emphasizing:

1. **Efficiency**

    - Optimizes Windows setup for time savings and consistent environments.

2. **Idempotency**

    - Allows scripts to be rerun without unintended side effects.

3. **Consistency**

    - Ensures stable configurations across machines, reducing drift.

4. **Time and Error Reduction**

    - Automates tasks to save time and minimize human errors.

5. **Ease of Use**

    - Simple yet powerful scripts for straightforward adoption and customization.

In essence, it provides an efficient, consistent, and user-friendly solution for Windows automation.

## Key Scripts

### Running Tweaks

```powershell
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/tweaks.ps1" | iex
```

This script is dedicated to applying various tweaks to optimize and customize your Windows environment. Let's list them below:

1. **Uninstalling Unwanted Microsoft Packages:**

   - Identifies and removes unnecessary Microsoft packages, decluttering the system.

2. **Modifying Taskbar and Lockscreen Explorer Settings:**

   - Adjusts Taskbar and Lockscreen Explorer settings for an improved user experience.

3. **Disabling Telemetry:**

   - Disables telemetry services to enhance privacy and minimize data collection.

4. **O&O ShutUp10++ Integration:**

   - Utilizes O&O ShutUp10++, a powerful privacy tool, to further control and customize Windows settings.

5. **Consistency and Idempotency:**

   - Ensures consistency by only making necessary changes and remains idempotent for safe re-execution.

This script plays a pivotal role in tailoring the Windows environment according to user preferences, optimizing performance, and enhancing privacy. It reflects the project's commitment to efficiency, consistency, and user-friendly customization.

### Setting Up OpenSSH

```powershell
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/openssh.ps1" | iex
```

This script automates the configuration of OpenSSH on your Windows environment. Below are the key features:

1. **Installation and Startup:**

   - Installs OpenSSH packages if not present.

   - Ensures automatic startup of the OpenSSH service.

2. **Firewall Rule:**

   - Adds a firewall rule to allow SSH traffic on port 22.

3. **Default Shell Configuration:**

   - Sets PowerShell as the default shell for OpenSSH.

4. **SSH Agent:**

   - Ensures the SSH agent service is running.

5. **SSH Key Generation:**

   - Generates an Ed25519 SSH key pair.

   - Adds the key to the SSH agent for secure authentication.

This script enhances your Windows environment by enabling secure and convenient SSH connectivity. It ensures that OpenSSH is properly configured with default settings for a hassle-free experience.

### Installing Scoop Packages

```powershell
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/scoop_packages.ps1" | iex
```

[Scoop](https://scoop.sh/){:target="_blank"} is a command-line package manager for Windows that simplifies the process of installing, updating, and managing software applications. Unlike traditional installers, Scoop organizes packages into buckets, making it easy to discover and install a variety of tools and utilities directly from the command line. Its simplicity and scriptable nature make Scoop a powerful tool for automating software management on Windows systems. It follows a structured approach, ensuring that each package is installed only if it's not already present.

Let's break down the key components of this script:

**Developer Tools:**

  - [GitHub CLI](https://cli.github.com/){:target="_blank"}: Command-line interface for GitHub.

  - [Oh-My-Posh](https://ohmyposh.dev/){:target="_blank"}: A prompt theme engine for any shell.

  - [Python](https://www.python.org/){:target="_blank"}: High-level programming language.

  - [VsCode](https://code.visualstudio.com/){:target="_blank"}: Visual Studio Code, a lightweight and powerful code editor.

  - [Grep](https://en.wikipedia.org/wiki/Grep){:target="_blank"}: Command-line text search utility.

  - [Nano](https://www.nano-editor.org/){:target="_blank"}: Command-line text editor.

  - [Vim](https://www.vim.org/){:target="_blank"}: Highly configurable text editor.

**Productivity and Communication:**

  - [Discord](https://discord.com/){:target="_blank"}: Communication platform for communities.

  - [Telegram](https://telegram.org/){:target="_blank"}: Instant messaging app.

  - [Tailscale](https://tailscale.com/){:target="_blank"}: Secure network for teams.

**Internet Browsing:**

  - [Google Chrome](https://www.google.com/chrome/){:target="_blank"}: Web browser.

  - [Firefox](https://www.mozilla.org/en-US/firefox/){:target="_blank"}: Web browser.

**Document Viewing:**

  - [Adobe Acrobat Reader](https://acrobat.adobe.com/us/en/acrobat/pdf-reader.html){:target="_blank"}: PDF reader.

**System Monitoring and Utilities:**

  - [Autohotkey](https://www.autohotkey.com/){:target="_blank"}: Scripting language for Windows automation.

  - [Coretemp](https://www.alcpu.com/CoreTemp/){:target="_blank"}: CPU temperature monitoring tool.

  - [Speedtest](https://www.speedtest.net/apps/cli){:target="_blank"}: Command-line interface for speed testing.

  - [NTop](https://www.ntop.org/){:target="_blank"}: Network traffic monitoring tool.

  - [ShareX](https://getsharex.com/){:target="_blank"}: Screen capture and file sharing tool.

**Fonts:**

  - [Nerd Fonts](https://www.nerdfonts.com/){:target="_blank"}: A collection of over 50 patched fonts for developers.

**Gaming:**

  - [Steam](https://store.steampowered.com/){:target="_blank"}: Digital distribution platform for video games.

  - [Parsec](https://parsecgaming.com/){:target="_blank"}: Cloud gaming and remote desktop tool.

  - [qBittorrent](https://www.qbittorrent.org/){:target="_blank"}: Open-source BitTorrent client.

These applications provide a comprehensive set of tools for developers, communication, browsing, document handling, system monitoring, fonts for developers, and entertainment.

### Setting Up Oh-My-Posh

```powershell
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/oh_my_posh.ps1" | iex
```

This script aims to provide an enriched PowerShell experience by combining the power of Oh-My-Posh, essential modules, and customizations. The inclusion of aliases and functions enhances productivity, simplifying command execution in a visually appealing terminal environment.

### Setting Up AutoHotkey

```powershell
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/autohotkey.ps1" | iex
```

This AutoHotKey script brings a new level of efficiency to Windows with the following features:

1. **Custom Hotkeys:**

   - Restores personalized hotkeys for quick access to specific applications and actions.

2. **Window Management:**

   - Enables window movement for a seamless desktop experience.

3. **Desktop Navigation:**

   - Facilitates desktop switching with designated hotkeys.

4. **Hotstrings:**

   - Implements custom hotstrings for speedy text input and automation.

By leveraging AutoHotKey, this script customizes your Windows environment to align with your workflow. The restoration of hotkeys, window management, desktop navigation, and hotstrings contributes to a more intuitive and streamlined computing experience.

### Setting Up ShareX

```powershell
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/software/sharex.ps1" | iex
```

ShareX, a feature-rich screenshot and screen recording tool, is configured using this script for efficient usage.

### Setting Up WSL2

```powershell
irm "https://raw.githubusercontent.com/jokerwrld999/ultimate-powershell/main/tasks/system_setup/wsl.ps1" | iex
```

By combining the power of WSL with automated provisioning through Ansible, this script simplifies the process of setting up and customizing Linux distributions on a Windows machine. Whether you prefer Arch or Ubuntu, the script provides a seamless experience for integrating Linux capabilities into your Windows workflow.

## Installation

### Prerequisites

Ensure you have the latest version of [PowerShell](https://aka.ms/powershell){:target="_blank"} installed. If you prefer, you can use [Windows PowerShell 5.1](https://aka.ms/wmf5download){:target="_blank"}.

**PowerShell Execution Policy:**
Set it to `Unrestricted`, `RemoteSigned`, or `ByPass` for the installer to run smoothly. Use the following command as an example:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### One Line Install (Run as Administrator Recommended)

```powershell
irm "https://github.com/jokerwrld999/ultimate-powershell/raw/main/local.ps1" | iex
```

Feel free to elevate your PowerShell environment effortlessly. Explore the possibilities on [GitHub](https://github.com/jokerwrld999/ultimate-powershell){:target="_blank"}.

## Lessons Learned

1. **Idempotency and Hashing:** Embracing the concept of idempotency using hashing mechanisms, ensuring that operations are repeatable and consistent.

2. **Creating Functions and Code Cleanliness:** The importance of creating modular functions, enabling separate testing, and maintaining clean and readable code for better maintainability.

3. **Write-Host for Clean Output:** Utilizing Write-Host to produce clean and informative output, enhancing the overall user experience.

4. **Rebooting Strategies:** Understanding the need for reboots in certain operations and effectively handling them, including the use of task scheduler to continue tasks after a reboot.

5. **PsRemoting, WinRM, and SSH:** Exploring the capabilities of PsRemoting, WinRM, and SSH for remote management and automation.

6. **Local Testing Before Automation:** Emphasizing the importance of local testing before automating tasks to ensure the reliability and correctness of scripts.

7. **Background Jobs:** Leveraging PowerShell background jobs to execute tasks asynchronously, allowing for non-blocking operations and reducing the need for user prompts.

8. **Scoop Package Manager:** Becoming proficient in Scoop, a command-line installer for Windows, empowers users to efficiently manage software installations and updates. Some key Scoop commands include:

   - `scoop status`: Provides a comprehensive overview of installed packages, their versions, and their status.

   - `scoop update *`: Updates all installed packages to their latest versions, ensuring that the software ecosystem stays current and secure.

   - `scoop cleanup`: Cleans up residual files and directories, optimizing disk space by removing unnecessary artifacts left behind by installations and updates.

   - `scoop uninstall [app]`: Uninstalls a specified application, removing it from the system and freeing up resources.

   - `scoop install [app]@[version]`: Installs a specific version of an application, allowing for precise control over the software environment.

These commands, executed in the PowerShell terminal, make Scoop a powerful tool for maintaining a well-organized and up-to-date collection of applications on a Windows system.