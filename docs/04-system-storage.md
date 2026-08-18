# Phase 4 — System Profile and Storage (Part 1)

## Goal
Produce a complete, evidence-backed profile of the machine's hardware
and storage, then go further than passive inspection: change real
resources, provision new storage from scratch, and add swap manually,
proving each change rather than just describing what already existed.

## What I did

### Baseline profile
Captured CPU (`lscpu`, `nproc`), memory (`free -h`), disk/partition
layout (`lsblk`, `fdisk -l`, `blkid`), and current mounts (`df -h`,
`findmnt`, `/etc/fstab`) as a starting snapshot before changing
anything.

### Resource scaling comparison
Shut the VM down, increased its allocated RAM (4GB → ~7.3GB usable)
and CPU count (2 → 4) in VirtualBox, booted back up, and confirmed
both changes from inside the guest with `lscpu` and `free -h`.

### New disk: full provisioning lifecycle
- Attached a new 5GB virtual disk to the VM in VirtualBox.
- Identified it from the guest as `/dev/sdb`, completely raw.
- Partitioned it with `fdisk`, one partition spanning the full disk.
- Formatted the partition with `mkfs.ext4`.
- Created a mount point and mounted it manually with `mount`.
- Added a persistent entry to `/etc/fstab` using the partition's UUID.
- Tested persistence by unmounting and running `mount -a`, confirming
  the filesystem came back purely from the config file.

### Swap file: full lifecycle
- Created a 1GB file (`fallocate -l 1G /extraswap`) at the filesystem
  root, alongside the existing install-time `/swap.img`.
- Locked its permissions to root-only (`chmod 600`), matching the
  existing swap file's security posture exactly.
- Formatted it as swap with `mkswap`.
- Activated it with `swapon`, confirmed total swap capacity increased
  by exactly 1GB (3.8Gi → 4.8Gi).
- Added a persistent entry to `/etc/fstab`, matching the format of the
  existing swap entry already in the file.
- Tested persistence by deactivating with `swapoff` and reactivating
  everything from fstab with `swapon -a`, confirming the same 4.8Gi
  total came back from the config alone.

## Why
Describing existing hardware and storage proves nothing on its own,
provisioning new storage and swap from scratch, and proving each
step persists across a simulated reboot, is the actual skill real
infrastructure work requires. This also mirrors genuine real-world
tasks: cloud images frequently ship with no swap configured at all,
and adding storage or swap after initial provisioning is routine
sysadmin work.

## What went wrong and what I learned

- **The VM reports a KVM hypervisor despite running on VirtualBox.**
  `lscpu` showed `Hypervisor vendor: KVM`. This traces back to a
  setting seen on day one of this VM's life but never understood at
  the time: VirtualBox's "KVM Paravirtualization" acceleration option,
  which presents a KVM-compatible interface to the guest for
  performance, even though VirtualBox itself is the real hypervisor.
- **The disk's BIOS boot partition connects directly to an early
  install decision.** The 1MB "BIOS boot" partition exists specifically
  because EFI was left unchecked during the original VM build, GPT
  disks booting in legacy BIOS mode require this dedicated partition
  for GRUB. If EFI had been enabled instead, this would be an EFI
  System Partition.
- **Got genuinely stuck inside `top`.** It's a full-screen, live-
  updating program that treats every keystroke as its own command
  rather than normal input, which felt like the terminal had frozen.
  Fixed with `q`, the same quit convention already known from `man`
  and `less`.
- **New disk didn't appear in the guest at first.** Creating the
  `.vdi` file in VirtualBox isn't the same as attaching it to the
  controller; had to go back into Storage settings and properly attach
  it before `lsblk` would show `/dev/sdb`.
- **`mount --bind` is not the same as a normal mount.** Attempted to
  use it to attach the new partition, but bind mounts only work on
  existing directories, not block devices. Corrected to a plain
  `mount /dev/sdb1 /mnt/attach`.
- **`l` (lowercase L) and `1` (the number) are nearly identical in
  terminal fonts, and it bit twice more this session.** Once creating
  `-1` instead of `-l` for `fallocate`'s size flag, and once earlier in
  the session with a directory name. Reinforces relying on tab
  completion or reading flags from `--help`/`man` rather than typing
  from memory.
- **`/etc/fstab` field order is easy to scramble when writing a new
  line from memory.** Produced a line with the options and dump fields
  swapped and an extra field tacked on. Fixed by copying the exact
  shape of an existing, correct entry already in the file rather than
  reconstructing the format from memory.
- **Mixed up `mount -a` and `swapon -a`, treating them as one combined
  command.** They're separate tools that each have their own `-a`
  flag for reloading their respective entries from fstab.

## Evidence

**Resource scaling, before → after:**
| | Baseline | After |
|---|---|---|
| CPUs | 2 | 4 |
| RAM | ~3.3Gi | ~7.3Gi |

**Swap capacity, before → after:**
| | Before | After |
|---|---|---|
| Total swap | 3.8Gi | 4.8Gi |

(insert terminal screenshots: lsblk/fdisk output for the new disk,
the mount -a persistence test, the swapon -a persistence test)

## Still to do in this phase
- Networking profile (interfaces, routing, DNS).
- NAT vs Bridged visibility comparison with `nmap`.
- Deliberate break-networking-then-diagnose exercise.
