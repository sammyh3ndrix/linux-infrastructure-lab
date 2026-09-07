# Phase 5 — Services (Part 1: Fundamentals)

## Goal
Learn Linux process and service management, processes, daemons,
systemd, unit files, and the start/enable distinction, using a real,
working service as proof. This phase is also the deliberate starting
point for merging this Linux lab with a separate Python RBAC
authentication project, using that project as the eventual real
workload instead of a disposable tutorial example.

## What I did

### Chose nginx over Apache
Both are managed identically by systemd, so the choice came down to
relevance rather than technical superiority: nginx is the more common
choice in modern infrastructure work (reverse proxies, load balancers,
containers), and this project is explicitly heading toward
automation/CI and eventually cloud/Docker work, making it the more
transferable pick.

### Installed and verified
Installed nginx with `apt`. Discovered it started and enabled itself
automatically as part of installation, a common behavior for
Debian/Ubuntu server packages. Verified it was genuinely serving
content with `curl localhost`, not just trusting `systemctl status`.

### Manually ran the full lifecycle
Practiced every half of both command pairs by hand:
- `stop` → confirmed dead with a failed `curl` (connection refused).
- `start` → confirmed alive again with a successful `curl`.
- `disable` → watched systemd remove a symlink from
  `/etc/systemd/system/multi-user.target.wants/`.
- `enable` → watched it recreate that exact same symlink.

### Read the actual unit file
Examined `/usr/lib/systemd/system/nginx.service` directly:
- `ExecStart` showed the literal command systemd runs, no abstraction.
- `Type=forking` explained the master/worker process tree observed
  earlier in `systemctl status`.
- `WantedBy=multi-user.target` explained exactly why `enable` created
  the symlink in that specific `.wants/` directory, the unit file
  itself declares the target.

## Why
The goal was never "learn nginx," it was learning systemd mechanics
using a real, working daemon as the vehicle, and proving each concept
rather than just reading about it: a service that's merely started
doesn't survive reboot, `enable`/`disable` are literal symlinks, and a
unit file is a plain, readable set of real commands.

## What went wrong and what I learned
- **`systemctl status curl` doesn't work, because curl isn't a
  service.** It's a one-shot command-line tool, not a persistent
  daemon, so it was never registered as a systemd unit in the first
  place. Useful distinction: only long-running background processes
  get unit files.
- Several command typos along the way (`sytemctl`, `sduo`, `sudp`,
  `localhsot`), mostly self-corrected using the shell's own
  suggestions without needing help, a sign the muscle memory from
  earlier phases is holding up under new commands.

## Evidence
<img width="2160" height="3801" alt="image" src="https://github.com/user-attachments/assets/afd4cfce-2a87-43e1-8313-4a9e2a150e6d" />
<img width="2157" height="1899" alt="image" src="https://github.com/user-attachments/assets/5b9e0f1a-29aa-41f3-943b-54cfd0a5a0cb" />





## Still to do in this phase
- Set up git and GitHub authentication on the VM.
- Clone `python-rbac-auth-lab` onto the server.
- Build its Python environment and run it manually.
- Address the interactive-CLI vs daemon distinction as the core
  lesson of this phase's second half.
