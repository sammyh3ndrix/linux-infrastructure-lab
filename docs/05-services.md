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

### Git and GitHub authentication on the VM
- Installed `git` on the VM (first time git was needed there).
- Cloned `python-rbac-auth-lab` (public repo, no auth needed for read).
- Generated a **second, dedicated SSH key** specifically for GitHub
  (`~/.ssh/github_key`), deliberately separate from the key used to
  log into the VM itself.
- Registered the public key with my GitHub account (not the repo,
  the account, a real mix-up caught along the way: SSH keys are
  account-level, not per-repository).
- Since the key used a non-default filename, created `~/.ssh/config`
  with a `Host github.com` block pointing to it, the SSH equivalent
  of `/etc/fstab`, a permanent instruction instead of specifying the
  key manually every time.
- Switched the repo's remote from HTTPS to SSH and confirmed full
  push/pull capability with `ssh -T git@github.com` and a real
  `git pull`.

### Python environment on Linux
- Confirmed a Windows-built venv cannot be reused on Linux at all,
  virtual environments bundle OS-specific scripts and compiled binary
  code (bcrypt specifically compiles real C code per platform).
  `requirements.txt` is the portable artifact; the built environment
  never is.
- Built a fresh venv directly on the VM (`python3 -m venv venv`), hit
  a missing `python3.14-venv` package (Debian/Ubuntu splits full venv
  functionality into a separate package), installed it, retried
  successfully.
- Activated the venv, installed the pinned dependency
  (`bcrypt==5.0.0`) from `requirements.txt`.
- Ran `main.py` manually and confirmed identical behavior to running
  it on Windows.

### The deliberate systemd experiment
- Wrote a unit file (`/etc/systemd/system/python-rbac.service`)
  pointing `ExecStart` at the venv's own Python binary running
  `main.py`, with `WorkingDirectory` set to the repo path.
- Ran `daemon-reload`, then `start`, then `status`.
- **The service failed in 502ms** with `EOFError: EOF when reading a
  line` at the app's `input()` call. Confirmed and reproduced this
  exact traceback again afterward through `journalctl -u python-rbac
  --since today`.

### journalctl fundamentals
- Practiced filtering the journal to one unit (`-u`) and by time
  range (`--since today`), using real data from both nginx's full
  start/stop history and the python-rbac crash.
- Discovered, unprompted, that nginx also keeps its own dedicated
  request log (`/var/log/nginx/access.log`), separate from the
  systemd journal entirely, a different logging mechanism the
  application manages itself, not something systemd does for it.
## Why
The goal was never "learn nginx," it was learning systemd mechanics
using a real, working daemon as the vehicle, and proving each concept
rather than just reading about it: a service that's merely started
doesn't survive reboot, `enable`/`disable` are literal symlinks, and a
unit file is a plain, readable set of real commands.

The failed systemd attempt was intentional, not a mistake to avoid,
proving the interactive-CLI-vs-daemon incompatibility hands-on is far
more convincing than being told about it. It directly led to a real
architectural decision: evolve the app with a thin FastAPI layer that
reuses the existing authentication/RBAC logic and gives it a
non-interactive interface, rather than either forcing the CLI into a
role it can't fill, or reaching for a larger framework than the
current need actually requires.

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
- **Registered the SSH key on the wrong settings page at first**,
  the repository's own settings instead of the personal account
  settings. SSH keys are account-wide, not tied to any one repo.
- **`python3 -m venv` failed on first attempt** due to the missing
  `python3.14-venv` package, a known Debian/Ubuntu minimalism pattern
  already seen elsewhere in this project (same spirit as the earlier
  `locate` and `tree` install gaps).
- **The EOFError crash is the clearest proof yet in this whole
  project of a concept holding up under direct testing**: an
  interactive program assumes a human typing in real time; a systemd
  service assumes nobody is there at all. Confirmed by an actual,
  reproducible crash, not a hypothetical.

## Evidence
<img width="2160" height="3801" alt="image" src="https://github.com/user-attachments/assets/afd4cfce-2a87-43e1-8313-4a9e2a150e6d" />
<img width="2157" height="1899" alt="image" src="https://github.com/user-attachments/assets/5b9e0f1a-29aa-41f3-943b-54cfd0a5a0cb" />
<img width="2160" height="3129" alt="image" src="https://github.com/user-attachments/assets/8e9f8066-4af5-487a-b998-c9d40492e4a7" />






## Still to do in this phase
- Wait for the FastAPI layer (Python side, in progress separately).
- Deploy the finished FastAPI process as the real systemd service.
- Apply `Restart=`, `User=`, and `Environment=` to that real service.
- Continue into Phase 6 (logging) using the real service once it exists.
