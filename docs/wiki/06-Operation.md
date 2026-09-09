# 6. Operation

## 6.1 The three states of the widget

| State | Condition | Icon | Color of the icon |
| --- | --- | --- | --- |
| Busy | A check is in operation. | A refresh symbol. | The normal text color. |
| Updates available | The total is more than zero. | An update symbol. | The neutral color, usually orange. |
| Up to date | The total is zero, or no check has run. | A circle with a check mark. | The normal text color. |

The widget uses a symbolic icon. Plasma applies the color of the color
scheme to it, so the icon agrees with a light theme and with a dark theme.

## 6.2 The tray visibility

The widget reports its status to the system tray:

- **Active**, when the total is more than zero;
- **Passive**, when the total is zero.

With the tray entry set to "Shown when relevant", Plasma hides a passive
icon. The icon disappears when the system is up to date. It comes back when
updates are available. Set the entry to "Always shown" to see the
icon in both states.

## 6.3 The tooltip

The tooltip has two parts.

| Condition | First line |
| --- | --- |
| A check is in operation | `Checking for updates…` |
| No check has run | `Update Checker` |
| The total is more than zero | `<n> updates available` |
| The total is zero | `System is up to date` |

The second part shows the count of each source, and then one instruction:
`Click to update system`, or `Click to check for updates`.

## 6.4 The schedule of the checks

| Event | Time |
| --- | --- |
| The first check | 15 seconds after the start of the widget. |
| Each subsequent check | After the configured interval, 6 hours by default. |

The first check is early on purpose. A user who starts the workstation sees
the update state in the first minute, and does not wait a full interval.

The widget refuses a second check while a check is in operation.

## 6.5 The reaction to a completed update run

The widget watches the file `~/.cache/bs-updater/last-update`. `bs-update`
writes a new time into that file after a successful update run.

When the time changes, the widget does these three steps:

1. It sets the total to zero and shows the up-to-date state at once.
2. It starts a new check in the background to confirm the total.
3. It starts to watch the file again.

The widget reacts to an update run from any origin: the widget itself,
the notification, or a manual run in a terminal.

A failed update run does not write the file. The icon then does not change.

## 6.6 The notifications

| Notification | Condition | Duration |
| --- | --- | --- |
| `<n> updates available` | The total is more than zero. | Until the user closes it. |
| `System is up to date` | A manual check gives a total of zero. | 5 seconds. |

The first notification has the button "Update now". A click on the button
starts `bs-update` in a new terminal window. The body of the notification
shows the count of each source.

The two settings of the page "General" control the two notifications. A
scheduled check never sends the up-to-date notification.

## 6.7 Procedure: how to check for updates

1. Click the arrow in the system tray.
2. Click the bs-updater icon with the left button of the mouse.

The widget starts a check if the total is zero. The icon changes to the busy
state and then to the new state.

## 6.8 Procedure: how to install the updates

Do one of these three procedures.

**From the icon:**

1. Click the bs-updater icon with the left button of the mouse. The total
   must be more than zero.

**From the notification:**

1. Click the button "Update now" in the notification.

**From a terminal:**

1. Open a terminal.
2. Type `bs-update` and press the Enter key.

The first two procedures open a new terminal window. The window shows the
output of each tool. Some tools ask for the root password, and some tools
ask for a confirmation. Answer these questions in the window.

**WARNING: An update run can replace the kernel and the graphics drivers.
Save your work before you start an update run.**

At the end of the run, the window shows this text:

```
Finished. Press Enter to close.
```

Press the Enter key to close the window.

## 6.9 The full representation

Click the widget in the widget browser, or in a panel, to see the full
representation. It shows:

- the icon of the current state;
- the state as text;
- the count of each source;
- the button "Check now";
- the button "Update system".

The button "Check now" is not available while a check is in operation.

## 6.10 The choice of the terminal

`bs-update` finds the terminal application in this sequence:

1. The default terminal of KDE, from the key `TerminalApplication` in the
   group `General` of the file `kdeglobals`.
2. The variable `TERMINAL`.
3. Konsole.
