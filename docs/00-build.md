# Phase 0 — Build and Base Install

## Goal
Stand up a clean Ubuntu Server virtual machine to serve as the foundation
for this lab, installed and configured entirely by hand.

## What I did
- Created a virtual machine in Oracle VirtualBox on a Windows 10 Pro host
  (AMD Ryzen 7 3700X).
- Allocated 4 GB RAM, 2 CPUs, and a 25 GB dynamically allocated disk.
- Attached the Ubuntu Server 26.04 LTS ISO and ran the installer manually
  (no unattended install).
- Chose the full Server edition with no desktop environment.
- Used the guided full-disk layout, no LVM and no encryption.
- Installed the OpenSSH server during setup.
- Set the hostname to h3ndrixmachine and created my user account.
- Completed the install, removed the ISO, and logged in at the console.

## Key decisions and why
- **Ubuntu 26.04 LTS over the 25.04 interim release.** LTS releases get five
  years of support versus nine months for interim releases. My first attempt
  actually installed 25.04, which was already past end of life, meaning its
  package repositories were retired and package management would have been
  broken from day one. I scrapped it and reinstalled on the LTS, which is
  also what production environments run.
- **No LVM.** I wanted a transparent disk layout that maps directly to the
  partitions and filesystems I am learning, rather than the abstraction layer
  LVM adds. I plan to build a separate VM with LVM later to compare.
- **No disk encryption (LUKS).** Full-disk encryption would force a passphrase
  at every boot for no security benefit on a local, throwaway learning VM.
- **Server edition, no GUI.** A terminal-only machine forces me to learn the
  command line instead of clicking through a desktop, which is the entire
  point of the exercise.
- **4 GB RAM / 2 CPUs / 25 GB disk.** The host has 32 GB, so 4 GB is a
  comfortable slice that leaves the host untouched. A headless server needs
  very little, and two CPUs are plenty with no desktop to run.

## What went wrong and what I learned
- **The VM would not boot at first.** VirtualBox threw VERR_SVM_DISABLED.
  I diagnosed that hardware virtualization (AMD-V, shown as SVM Mode) was
  turned off in the motherboard firmware. Enabling SVM in the BIOS fixed it.
  Takeaway: virtualization has to be enabled at the firmware level before any
  hypervisor can run a 64-bit guest.
- **The hypervisor label did not match reality.** VirtualBox still displayed
  the OS as Ubuntu 25.04 from my first attempt. Rather than trust the label,
  I verified the real version from inside the OS with `cat /etc/os-release`,
  which confirmed Ubuntu 26.04 LTS (Resolute Raccoon). Takeaway: verify system
  facts from the authoritative source, not from a description that can be stale.

## Evidence
(insert a screenshot of the /etc/os-release output and/or the login prompt)

<img width="2197" height="1956" alt="image" src="https://github.com/user-attachments/assets/28c2b530-714f-483b-9ccd-4fd6df03df43" />

