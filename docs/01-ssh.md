# Phase 1 — SSH and Remote Access

## Goal
Reach and administer the VM remotely over SSH from my Windows host,
instead of working in the VirtualBox console window. This is the
foundation for running the machine like a real server.

## What I did
- Verified the SSH server on the VM with `systemctl status ssh`.
- Discovered the machine uses socket activation, so I checked
  `systemctl status ssh.socket` and confirmed it was active and
  listening on 0.0.0.0:22.
- The VM's network adapter is set to NAT, so the host could not reach
  it directly. I added a VirtualBox port-forwarding rule mapping
  host port 2222 to guest port 22.
- Connected from Windows PowerShell with `ssh sammy@localhost -p 2222`.
- Accepted the host key fingerprint on first connection, entered my
  password, and landed at a shell prompt on the VM over SSH.
- Generated an SSH key pair with `ssh-keygen` on the Windows host, an
  ed25519 private key kept locally and a public key to distribute.
- Copied the public key to the VM, placed it in `~/.ssh/authorized_keys`,
  and locked down permissions on both the `.ssh` directory (700) and the
  file itself (600), as required by sshd.
- Reconnected over SSH and confirmed key-based login: no password prompt,
  straight to the shell.
- Disabled password authentication in `/etc/ssh/sshd_config` and reloaded
  the ssh service.
- Discovered the change had no effect and diagnosed why using
  `sudo sshd -T`, which reports sshd's actual resolved configuration.
- Found the true cause: `/etc/ssh/sshd_config.d/50-cloud-init.conf`, a
  drop-in file created by the installer, also set PasswordAuthentication
  and was overriding my edit because it is included before the rest of
  the main config is read.
- Fixed the setting in that file, reloaded ssh, and confirmed with
  `sshd -T` that the effective setting was finally `no`.
- Verified the change two ways: a normal key-based login still worked
  with no password prompt, and a login forced to skip the key
  (`-o PubkeyAuthentication=no`) was rejected immediately with
  "Permission denied (publickey)", no password prompt offered at all.

## Why
- SSH is how Linux servers are administered in the real world. Nobody
  sits at a physical console.
- Remote access frees me from the VirtualBox window and gives me proper
  copy-paste and scrollback.
- It is the prerequisite for later hardening (key-based auth, disabling
  passwords) and for running the machine headless.
- Key-based authentication proves identity with a cryptographic key pair
  instead of a password. The private key never leaves the client and no
  password is transmitted, which is how real infrastructure is secured. 

## What went wrong and what I learned
- **Socket activation confusion.** `systemctl status ssh` reported the
  service as `inactive (dead)` and `disabled`, which looked like SSH was
  off. It was not. The `TriggeredBy: ssh.socket` line was the clue: the
  system uses socket activation, where systemd listens on port 22 via
  ssh.socket and starts sshd on demand when a connection arrives.
  Lesson: an "inactive" service is not always a problem, check what
  triggers it.
- **The NAT wall.** The VM was listening on port 22, but NAT is a
  one-way boundary, so the host could not connect in. Port forwarding
  (host 2222 to guest 22) opened the single route needed.
- **Generated the key pair on the wrong machine, twice.** The private key
  needs to live on the client (Windows), the public key on the server
  (the VM). I initially ran `ssh-keygen` inside an active SSH session, so
  both halves landed on the VM. Fixed by running it from a genuine Windows
  PowerShell prompt (not SSH'd in), confirmed by the key fingerprint
  showing my Windows hostname instead of the VM's.
- **Command/argument spacing errors.** Ran into `nano~/.ssh/authorized_keys`
  (no space) and a PowerShell path with a stray space breaking `$env:`
  variable parsing. Both were the same root cause: a shell reads a command
  and its argument as separate tokens only if they're actually separated
  by a space.
- **Learned `chmod` and file permission locks.** SSH silently refuses key
  auth if `.ssh` or `authorized_keys` are too permissive. Set `chmod 700`
  on the directory and `chmod 600` on the file. Full permission model is
  Topic 5 material, treated this as a required convention for now.
- **A config edit that silently didn't work.** Setting
  `PasswordAuthentication no` in the main sshd_config had no effect,
  because sshd_config supports an `Include` directive that pulls in
  additional files, and sshd uses the first matching directive it reads,
  not the last. A drop-in file from the installer, included near the top
  of the config, was setting the value to `yes` before my edit further
  down ever got read. Lesson: when a config change seems to do nothing,
  don't assume the file you edited is the only one in play. `sshd -T`
  shows the fully resolved, actual configuration and is the authoritative
  way to check, not reading the file by eye.

## Evidence
(insert screenshot of the successful SSH login from PowerShell)

## Still to do in this phase
- Run the VM headless.

<img width="1216" height="1100" alt="image" src="https://github.com/user-attachments/assets/b0c89ebd-a5b5-4069-8685-bba05acd0b37" />
