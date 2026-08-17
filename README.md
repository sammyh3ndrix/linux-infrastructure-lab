# Linux Infrastructure Lab

A hands-on lab where I build and administer a Linux server from scratch,
adding complexity in phases: remote access, users and permissions,
networking, services, logging, and automation. Built as I work through
the LPI Linux Essentials track and beyond.

## The Machine
- **OS:** Ubuntu Server 26.04 LTS
- **Hostname:** h3ndrixmachine
- **Resources:** 4 GB RAM, 2 CPUs, 25 GB disk
- **Host:** VirtualBox on Windows 10 Pro
- **Network:** NAT

## Skills Demonstrated
- Provisioned an Ubuntu Server VM from an ISO
- Made install-time decisions (LTS vs interim release, partitioning, OpenSSH)
- Verified system state directly from the OS
- Command-line administration: navigation, files, variables, permissions

## Roadmap
- [x] Phase 0 — Build and base install
- [x] Phase 1 — SSH and remote access
- [ ] Phase 2 — Filesystem and navigation
- [ ] Phase 3 — Users, groups, and permissions
- [ ] Phase 4 — System and network profile
- [ ] Phase 5 — Services
- [ ] Phase 6 — Logging and monitoring
- [ ] Phase 7 — Automation and CI
- [ ] Phase 8 — Hardening and capstone

## Documentation
Detailed write-ups for each phase live in [`docs/`](docs/).
