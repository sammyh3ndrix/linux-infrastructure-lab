# Phase 2 — Filesystem Fluency

## Goal
Prove confident navigation and manipulation of the Linux filesystem:
absolute and relative paths, creating, moving, copying, and deleting
files and directories, without hesitating or needing to look anything
up mid-task.

## Command Reference

| Command | Purpose |
|---|---|
| `pwd` | print the current absolute path |
| `cd <path>` | change directory (relative or absolute) |
| `cd` / `cd ~` | jump to home directory |
| `cd ..` / `cd ../..` | move up one or more parent levels |
| `cd -` | jump to the previous directory |
| `ls` | list current directory contents |
| `ls -a` | include hidden (dot) files |
| `ls -l` | long listing: permissions, owner, size, timestamp |
| `ls -lh` | long listing with human-readable sizes |
| `ls -R` | recursive listing, includes subdirectory contents |
| `ls -lt` / `ls -lrt` | sort by modification time, newest/oldest first |
| `ls -lS` | sort by size, largest first |
| `ls -d */` | list only subdirectories |
| `mkdir -p <path>` | create a directory, including missing parents |
| `touch <name>` | create an empty file or update its timestamp |
| `mv <source> <dest>` | move or rename a file/directory |
| `cp <source> <dest>` | copy a file, leaving the original in place |
| `rm <file>` | delete a file |
| `rm -r <dir>` | delete a directory and everything inside it recursively |
| `find <path> -name <pattern>` | search the live filesystem |
| `locate <string>` | search a prebuilt filename database (fast, can be stale) |
| `man <command>` | read a command's manual |

**Path concepts:** absolute paths start with `/` and work from anywhere;
relative paths are interpreted from the current location. `~` always
means the current user's home directory. `.` is the current directory,
`..` is the parent. Hidden files start with a leading dot and only
appear with `ls -a`.

**Wildcards:** `?` matches exactly one character, `*` matches any
number of characters, `[set]` matches one character from a set (e.g.
`[13579]`). **Brace expansion** generates text before a command runs:
`{1..5}` is a range, `{a,b,c}` is a list, and stacked braces multiply
(`{1..3}{a,b}` produces 6 results, not 5).

## The Navigation Challenge

Built a three-level directory tree by hand, entirely from memory, with
one directory name containing a space to force real quoting practice:



Files were spread across all three levels rather than piled in one
place. Then performed, in order:

1. Navigated to the deepest file using a relative path.
2. Returned to the top of the tree in a single command.
3. Moved a file from one branch of the tree into another.
4. Copied a file to a different branch, leaving the original in place.
5. Deleted an entire branch recursively in one command.

## What went wrong and what I learned

- **Case sensitivity, again.** Created `Projectl1` (capital P) and then
  tried `cd projectl1` (lowercase), which failed. Directory names are
  case-sensitive with no exceptions, this is now the third or fourth
  time this exact mistake has cost me a command.
- **`l` vs `1` are nearly identical in a terminal font.** Misread my own
  folder `quoted l2` (lowercase L) as `quoted 12` (the number twelve)
  repeatedly. Fixed by using **tab completion** instead of typing the
  name from memory, it fills in the exact real characters and handles
  the space's quoting automatically. This is the actual reason tab
  completion is a core habit, not just a convenience.
- **Command and argument need a space between them, always.** Hit this
  twice more: `cd../` (no space before the argument) and `nano` glued
  directly to a path earlier in the project. A missing space makes bash
  read the whole thing as one nonexistent command name.
- **`mv`'s destination behavior is not what I assumed.** If the
  destination path is an existing directory, `mv` moves the file into
  it. If the destination does not exist, `mv` renames the file to that
  new name instead. I pointed `mv` at a path that didn't exist and
  accidentally created a stray, oddly-named file instead of moving into
  the folder I intended. Fixed by pointing the destination at the real,
  existing directory.
- **`rm -rf` with a wrong path fails silently.** Used an absolute path
  missing the `/home/sammy` prefix to delete a directory, and the `-f`
  flag suppressed the resulting "no such file" error entirely. The
  command appeared to run cleanly but deleted nothing, and I didn't
  notice until checking the listing. Lesson: `-f` hides mistakes in
  both directions, it can silently do nothing on a wrong path, or
  silently destroy something on a wrong-but-existing path with no
  confirmation. Best practice: `cd` close to the target first and use a
  short relative path instead of a long absolute one typed from memory.
- **Brace expansion has strict rules.** `{file1..3}` did not expand at
  all, a range requires both ends to be a single matching letter or
  number, not a word mixed with a number, so bash treated the whole
  thing as literal text. Separately, `{file1,,4}` (an accidental double
  comma) created an unintended empty-suffix file, because a comma list
  keeps blank entries. Always safe to preview with `echo` before
  running the real command.

## Evidence

Final structure after all operations, confirmed with `ls -R`:

<img width="2160" height="3823" alt="image" src="https://github.com/user-attachments/assets/b34e204f-2719-4bb3-a6b3-56f2dc999e1a" />


