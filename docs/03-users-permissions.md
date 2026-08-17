# Phase 3 — Users, Groups, and Permissions

## Goal
Build a real multi-user server with a permission model that actually
holds under testing: three users, two groups in a realistic nested
structure, private per-user home directories, and a shared
collaborative directory where the team can work together but cannot
destroy each other's work.

## What I did
- Created three users (`matt`, `john`, `kevin`) with `adduser`, which
  automatically provisioned a home directory for each at `/home/<user>`.
- Created two groups with `groupadd`: `general_eng` (the broad
  engineering team) and `cloud_admin` (a smaller, more privileged
  subset).
- Assigned group membership with `usermod -aG` so that all three users
  belong to `general_eng`, while only `john` and `kevin` additionally
  belong to `cloud_admin`, mirroring a real org structure where a
  specialized team is nested inside a broader one, never the reverse.
- Verified private home directories were already correctly locked down
  by default (`750`, owned by each user's own private group), no
  changes needed.
- Built a shared collaborative directory at `/srv/eng`:
  - Group ownership set to `general_eng`.
  - Base permission set to `770` (owner full, group full, others
    nothing).
  - Setgid applied, so files created inside automatically inherit the
    directory's group instead of the creator's own primary group.
  - Sticky bit applied, so group members can add files freely but can
    only delete or rename their own.
- Proved the model by switching into different users' shells with
  `sudo -i -u <user>` and deliberately trying to break the rules from
  multiple angles rather than just trusting the configuration.

## Why
`cloud_admin` as a strict subset of `general_eng` reflects how real
engineering orgs are structured, a broad team plus a smaller group
with elevated scope. And a permission model is only worth documenting
once it's been tested adversarially. Configuring `chmod` bits proves
nothing on its own, only trying to violate the intended rules and
watching them hold does.

## What went wrong and what I learned
- **Applied every permission change to the wrong directory at first.**
  Built the shared folder at `/srv/eng`, but ran `chown`, `chmod g+s`,
  `chmod +t`, and a recursive `chmod` against `/srv` itself, the
  parent, standard system directory, instead of `eng`. Had to diagnose
  this by checking `ls -ld` on each path individually and noticing
  the ownership/permissions were landing one level too high.
- **Used `chmod -R 777` as a shortcut, and it broke the entire design.**
  `777` grants full access to owner, group, *and* others, the opposite
  of the intended "others get nothing" model. Because it was run
  recursively on the parent, it also silently stripped the sticky bit
  that had already been applied. Lesson: `777` is never a real fix,
  it's a way of hiding a permission problem instead of solving it, and
  it should never appear in a directory meant to be access-restricted.
- **Reverting required understanding chmod's special-bit behavior.**
  A plain numeric mode like `755` or `770` resets setgid and sticky
  back to off, since numeric mode replaces the full permission set
  including the special bits. This meant the special bits had to be
  reapplied *after* the base permission was corrected, not before.
- **`chmod g=s` is not the same as `chmod g+s`, and the difference
  nearly broke collaboration entirely.** `+` adds a permission without
  touching anything else; `=` replaces the entire permission set for
  that category with exactly what's specified. Running `g=s` wiped out
  the group's `rwx` access, leaving only a non-functional setgid marker
  (shown as capital `S` instead of lowercase `s`, since execute was no
  longer present). Without execute, `general_eng` members couldn't even
  enter the directory. Fixed by restoring the base permission first,
  then re-adding setgid with the correct additive operator.
- **Even the directory's own creator got locked out, and that was
  correct, not a bug.** After the permissions were set correctly,
  `sammy` (the account that built all of this) was denied access to
  `/srv/eng`, because `sammy` was never added to `general_eng`. The
  permission model makes no exception for whoever configured it, it
  strictly follows group membership. Realizing this was actually proof
  the design was working exactly as intended.

## Evidence: the test sequence
- **Setgid proof:** logged in as `matt` (a `general_eng` member) and
  created a file inside `/srv/eng`. The file's owner was `matt`, but
  its group was automatically `general_eng`, not `matt`'s own private
  group, confirming setgid inheritance.
- **Sticky bit proof (blocking others):** logged in as `john`, a
  different `general_eng` member, and attempted to delete matt's file.
  Even after confirming through `rm`'s own write-protection prompt, the
  operating system refused with `Operation not permitted`. Repeated the
  attempt a second time with the identical result, confirming it was
  consistent, not a fluke.
- **Sticky bit proof (not blocking your own):** as `john`, created a
  new file of his own and deleted it immediately afterward with zero
  resistance, confirming the sticky bit selectively protects other
  users' files without breaking normal collaboration.
- **Non-member lockout proof:** as `sammy`, who is not a `general_eng`
  member, attempting to even list `/srv/eng`'s contents returned
  `Permission Denied`.

(insert terminal screenshots of the test sequence: matt's file
creation and group, john's failed and successful deletions, and
sammy's denied access)


<img width="2160" height="3836" alt="image" src="https://github.com/user-attachments/assets/b986f002-1765-4d2b-86ce-08208b22aded" />

