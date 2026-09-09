# 12. Fault isolation

## 12.1 How to use this chapter

Find the symptom in the table below. Then read the section for the
corrective action.

| Symptom | Section |
| --- | --- |
| The tooltip shows `Check failed. Is bs-update in ~/.local/bin?` | 12.2 |
| The command `bs-update` is not available in a terminal. | 12.3 |
| The icon is not in the system tray. | 12.4 |
| The total is always zero. | 12.5 |
| The count is too high. | 12.6 |
| No notification comes. | 12.7 |
| The update run opens no terminal window. | 12.8 |
| An update run asks for a password many times. | 12.9 |
| The count on Debian or Ubuntu is old. | 12.10 |
| A Debian package never receives its update. | 12.11 |
| A second Gear Lever window opens. | 12.12 |

## 12.2 The tooltip shows a failure

**Cause:** The widget cannot start `~/.local/bin/bs-update`, or the output
holds no line `Total:`.

**Corrective action:**

1. Open a terminal.
2. Run `~/.local/bin/bs-update -l`.
3. Read the error messages.

If the file is absent, restart Plasma. The widget installs its own copy at
each start. If the file is present but not executable, correct the mode:

```
chmod 755 ~/.local/bin/bs-update
```

## 12.3 The command is not available in a terminal

**Cause:** `~/.local/bin` is not in the `PATH` variable.

**Corrective action:** Add the directory to the `PATH` variable in the
configuration file of your shell. Then open a new terminal.

## 12.4 The icon is not in the system tray

**Cause 1:** The tray entry has the value "Shown when relevant", and the
system is up to date. This is the correct behavior.

**Corrective action:** Set the entry to "Always shown".

**Cause 2:** The tray entry of the widget has the value "Hidden".

**Corrective action:**

1. Click the arrow in the system tray.
2. Click the configuration button.
3. Set the entry "bs-updater" to "Shown".

## 12.5 The total is always zero

**Cause 1:** The selection has no enabled tool.

**Corrective action:** Run `bs-update --list-tools` and examine the states.
Then select a tool in the settings page.

**Cause 2:** The tool of a selected source is not installed.

**Corrective action:** Install the tool, or clear the checkbox of that
source. Chapter 4 gives the tool of each source.

**Cause 3:** The system is up to date.

## 12.6 The count is too high

**Cause:** Two enabled tools update the same kind of package.

**Corrective action:** Open the settings page "Update sources". Read the
warning and clear one of the two checkboxes. `bs-update` also reports the
condition on its error output.

## 12.7 No notification comes

**Cause 1:** The notification is off in the settings page "General".

**Corrective action:** Select the checkbox for the notification.

**Cause 2:** `notify-send` is absent.

**Corrective action:** Install libnotify.

**Cause 3:** You wait for the up-to-date notification after a scheduled
check. A scheduled check never sends that notification.

**Corrective action:** Start a check with a click on the icon.

## 12.8 The update run opens no terminal window

**Cause:** The system has no terminal application, or the default terminal
of KDE is not correct.

**Corrective action:** Install Konsole, or set the `TERMINAL` variable to
your terminal application.

## 12.9 An update run asks for a password many times

**Cause:** More than one tool must have root privileges. Each `sudo` command
asks again after the timeout of `sudo`.

**Corrective action:** This is normal behavior. Answer each question.

## 12.10 The count on Debian or Ubuntu is old

**Cause:** The count comes from the package lists on the disk. A refresh of
these lists must have root privileges, and a scheduled check has no
password.

**Corrective action:** No action is necessary. The timer `apt-daily`
refreshes the lists in the background. The update run also refreshes the
lists before it installs a package. Section 8.6 gives the full reason.

## 12.11 A Debian package never receives its update

**Cause:** `apt-get upgrade` never removes a package. A package whose update
must have a removal stays back.

**Corrective action:** Run this command yourself:

```
sudo apt-get dist-upgrade
```

## 12.12 A second Gear Lever window opens

**Cause:** The command line interface of Gear Lever also starts the
graphical application when a display connection is available.

**Corrective action:** `bs-update` removes the two display variables before
it starts Gear Lever. If a window opens, make sure that you use the current
version of the command:

```
head -1 ~/.local/bin/bs-update
```

The first line must be `#!/bin/sh`. Then restart Plasma to install the
current copy from the widget.

## 12.13 How to collect data for a report

Give this data with a problem report:

1. The distribution and the version of Plasma.
2. The output of `bs-update --list-tools`.
3. The output of `bs-update -l`.
4. The error messages of the run.

Remove your user name and each path in your home directory from the output
before you send it.
