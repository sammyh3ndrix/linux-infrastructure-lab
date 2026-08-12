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

## Why
- SSH is how Linux servers are administered in the real world. Nobody
  sits at a physical console.
- Remote access frees me from the VirtualBox window and gives me proper
  copy-paste and scrollback.
- It is the prerequisite for later hardening (key-based auth, disabling
  passwords) and for running the machine headless.

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

## Evidence
(insert screenshot of the successful SSH login from PowerShell)

## Still to do in this phase
- Set up key-based authentication.
- Disable password authentication.
- Run the VM headless.

<img width="1216" height="1100" alt="image" src="https://github.com/user-attachments/assets/b0c89ebd-a5b5-4069-8685-bba05acd0b37" />
