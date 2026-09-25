#!/bin/sh
# Tests for bin/bs-update.
#
# The tests replace pacman, paru, flatpak, and the other commands with
# stubs, so they run on any machine and install nothing. Each stub appends
# its command line to $STUB_LOG, which lets a test check what bs-update
# would have run.
#
# Usage: tests/run-tests.sh

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BS_UPDATE="$REPO_DIR/bin/bs-update"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

STUB_BIN="$WORK/bin"
mkdir -p "$STUB_BIN"

# The stubs. Counts come from the environment so a test can decide how
# many updates each source has.
cat > "$STUB_BIN/lines" <<'EOF'
#!/bin/sh
# Print $1 numbered lines.
i=1
while [ "$i" -le "${1:-0}" ]; do echo "package-$i 1.0 -> 2.0"; i=$((i + 1)); done
EOF

cat > "$STUB_BIN/checkupdates" <<'EOF'
#!/bin/sh
echo "checkupdates $*" >> "$STUB_LOG"
lines "${STUB_REPO_COUNT:-0}"
EOF

cat > "$STUB_BIN/paru" <<'EOF'
#!/bin/sh
echo "paru $*" >> "$STUB_LOG"
case "$1" in -Qua) lines "${STUB_AUR_COUNT:-0}" ;; esac
exit "${STUB_PARU_RC:-0}"
EOF

cat > "$STUB_BIN/pacman" <<'EOF'
#!/bin/sh
echo "pacman $*" >> "$STUB_LOG"
EOF

# dnf reports one package per line as "name.arch version repository".
# STUB_DNF_TRICKY makes it print the awkward parts of a real report as
# well: the metadata line, a blank line, a package name long enough to
# wrap onto a second indented line, and the trailing "Obsoleting Packages"
# section that repeats packages already listed above.
cat > "$STUB_BIN/dnf" <<'EOF'
#!/bin/sh
echo "dnf $*" >> "$STUB_LOG"
case "$*" in
*check-update*)
    if [ "${STUB_DNF_TRICKY:-0}" -eq 1 ]; then
        cat <<'REPORT'
Last metadata expiration check: 0:12:34 ago on Mon 08 Sep 2026 10:00:00 AM EDT.

bash.x86_64                          5.2.26-1.fc40            updates
kernel.x86_64                        6.9.4-200.fc40           updates
really-long-package-name-goes-here.noarch
                                     1.0-1.fc40               updates

Obsoleting Packages
foo.noarch                           2.0-1.fc40               updates
    bar.noarch                       1.0-1.fc40               @System
REPORT
        exit 100
    fi
    i=1
    while [ "$i" -le "${STUB_RPM_COUNT:-0}" ]; do
        echo "package-$i.x86_64  1.0-$i.fc40  updates"
        i=$((i + 1))
    done
    ;;
esac
exit "${STUB_DNF_RC:-0}"
EOF

cat > "$STUB_BIN/nobara-sync" <<'EOF'
#!/bin/sh
echo "nobara-sync $*" >> "$STUB_LOG"
EOF

# "apt-get -s upgrade" simulates the upgrade and prints one "Inst" line per
# package it would install. STUB_APT_TRICKY makes it print the awkward
# parts of a real simulation as well: the note about the simulation, the
# progress lines, the indented list of package names, the "kept back"
# section for packages this upgrade leaves alone, the summary line, and a
# "Conf" line after every "Inst" line.
cat > "$STUB_BIN/apt-get" <<'EOF'
#!/bin/sh
echo "apt-get $*" >> "$STUB_LOG"
case "$*" in
*-s*upgrade*)
    if [ "${STUB_APT_TRICKY:-0}" -eq 1 ]; then
        cat <<'REPORT'
NOTE: This is only a simulation!
      apt-get needs root privileges for real execution.
Reading package lists...
Building dependency tree...
Reading state information...
Calculating upgrade...
The following packages have been kept back:
  linux-image-generic
The following packages will be upgraded:
  bash libc6
2 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
Inst bash [5.2.15-2] (5.2.15-3 Debian:12 [amd64])
Conf bash (5.2.15-3 Debian:12 [amd64])
Inst libc6 [2.36-9] (2.36-9+deb12u1 Debian:12 [amd64])
Conf libc6 (2.36-9+deb12u1 Debian:12 [amd64])
REPORT
        exit 0
    fi
    i=1
    while [ "$i" -le "${STUB_DEB_COUNT:-0}" ]; do
        echo "Inst package-$i [1.0-$i] (2.0-$i Debian:12 [amd64])"
        echo "Conf package-$i (2.0-$i Debian:12 [amd64])"
        i=$((i + 1))
    done
    ;;
esac
exit "${STUB_APT_RC:-0}"
EOF

cat > "$STUB_BIN/sudo" <<'EOF'
#!/bin/sh
echo "sudo $*" >> "$STUB_LOG"
"$@" >/dev/null 2>&1
EOF

cat > "$STUB_BIN/flatpak" <<'EOF'
#!/bin/sh
echo "flatpak $*" >> "$STUB_LOG"
case "$1 $2" in
"remote-ls --updates") lines "${STUB_FLATPAK_COUNT:-0}" ;;
"run it.mijorus.gearlever")
    case "$3" in
    --list-updates)
        if [ "${STUB_APPIMAGE_COUNT:-0}" -eq 0 ]; then
            echo "No updates available"
        else
            lines "${STUB_APPIMAGE_COUNT:-0}"
        fi
        ;;
    esac
    ;;
esac
EOF

# notify-send prints a notification ID for -p, as the real one does. It
# exits at once, as if the notification was closed without a click.
cat > "$STUB_BIN/notify-send" <<'EOF'
#!/bin/sh
echo "notify-send $*" >> "$STUB_LOG"
case " $* " in *" -p "*) echo "${STUB_NOTIFY_ID:-7}" ;; esac
EOF

cat > "$STUB_BIN/gdbus" <<'EOF'
#!/bin/sh
echo "gdbus $*" >> "$STUB_LOG"
EOF

# The terminal that a run with a terminal opens. The stub logs the call
# and opens no window.
cat > "$STUB_BIN/konsole" <<'EOF'
#!/bin/sh
echo "konsole $*" >> "$STUB_LOG"
EOF

chmod 755 "$STUB_BIN"/*

# plasmoid-updater has its own directory, so a test can leave it out of
# the PATH. "check" prints what plasmoid-updater 0.2.1 prints: the count
# line, then a table with bold headers, or one line when nothing is new.
PLASMOID_BIN="$WORK/plasmoid-bin"
mkdir -p "$PLASMOID_BIN"
cat > "$PLASMOID_BIN/plasmoid-updater" <<'EOF'
#!/bin/sh
echo "plasmoid-updater $*" >> "$STUB_LOG"
n=${STUB_PLASMOID_COUNT:-0}
case "$1" in
check)
    if [ "$n" -eq 0 ]; then echo "No updates available"; exit 0; fi
    if [ "$n" -eq 1 ]; then echo "1 update available."; else echo "$n updates available."; fi
    printf ' \033[1mNAME\033[0m      \033[1mCURRENT\033[0m  \033[1mAVAILABLE\033[0m\n'
    i=1
    while [ "$i" -le "$n" ]; do echo " Widget $i    0.0.1      1.0.0"; i=$((i + 1)); done
    ;;
esac
EOF
chmod 755 "$PLASMOID_BIN/plasmoid-updater"

PATH="$STUB_BIN:$PATH"
# The PATH without plasmoid-updater, for the test of a missing tool.
PATH_WITHOUT_PLASMOID=$PATH
PATH="$PLASMOID_BIN:$PATH"
export PATH
export HOME="$WORK/home"
export XDG_CONFIG_HOME="$WORK/config"
export XDG_CACHE_HOME="$WORK/cache"
unset TERMINAL
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"

passed=0
failed=0

# Run bs-update with a clean log. Sets $out, $err, and $rc.
run() {
    rm -rf "$XDG_CACHE_HOME/bs-updater"
    STUB_LOG="$WORK/log"
    export STUB_LOG
    : > "$STUB_LOG"
    out=$("$BS_UPDATE" "$@" 2>"$WORK/err")
    rc=$?
    err=$(cat "$WORK/err")
}

# check <name> <expected> <actual>
check() {
    if [ "$2" = "$3" ]; then
        passed=$((passed + 1))
        echo "ok   - $1"
    else
        failed=$((failed + 1))
        echo "FAIL - $1"
        echo "       expected: $2"
        echo "       actual:   $3"
    fi
}

# contains <name> <needle> <haystack>
contains() {
    case "$3" in
    *"$2"*) passed=$((passed + 1)); echo "ok   - $1" ;;
    *)
        failed=$((failed + 1))
        echo "FAIL - $1"
        echo "       expected to contain: $2"
        echo "       actual:              $3"
        ;;
    esac
}

# lacks <name> <needle> <haystack>
lacks() {
    case "$3" in
    *"$2"*)
        failed=$((failed + 1))
        echo "FAIL - $1"
        echo "       expected to be absent: $2"
        echo "       actual:                $3"
        ;;
    *) passed=$((passed + 1)); echo "ok   - $1" ;;
    esac
}

set_config() {
    mkdir -p "$XDG_CONFIG_HOME/bs-updater"
    cat > "$XDG_CONFIG_HOME/bs-updater/tools.conf"
}

clear_config() {
    rm -f "$XDG_CONFIG_HOME/bs-updater/tools.conf"
}

STUB_REPO_COUNT=3
STUB_AUR_COUNT=2
STUB_RPM_COUNT=5
STUB_DEB_COUNT=6
STUB_FLATPAK_COUNT=4
STUB_APPIMAGE_COUNT=1
export STUB_REPO_COUNT STUB_AUR_COUNT STUB_RPM_COUNT STUB_DEB_COUNT
export STUB_FLATPAK_COUNT STUB_APPIMAGE_COUNT

echo "# Defaults, without a configuration file"
clear_config
run -l
check "default list output" \
    "Pacman: 3
AUR: 2
Flatpak: 4
AppImage: 1
Total: 10" "$out"
check "default list is quiet on stderr" "" "$err"

run
check "default update runs paru once, then flatpak and Gear Lever" \
    "paru -Syu
flatpak update
flatpak run it.mijorus.gearlever --update --all --yes" "$(cat "$WORK/log")"
check "a completed update writes the state file the widget watches" \
    "yes" "$([ -f "$XDG_CACHE_HOME/bs-updater/last-update" ] && echo yes || echo no)"

echo
echo "# --tools selects the sources for one run"
run --tools flatpak -l
check "only the selected source is counted" \
    "Flatpak: 4
Total: 4" "$out"

run --tools flatpak,gearlever -l
check "a comma separated list works" \
    "Flatpak: 4
AppImage: 1
Total: 5" "$out"

run --tools "paru-aur flatpak"
check "paru updates AUR packages alone when its repository entry is off" \
    "paru -Sua
flatpak update" "$(cat "$WORK/log")"

run --tools paru-repo
check "paru updates repository packages alone when its AUR entry is off" \
    "paru -Syu --repo" "$(cat "$WORK/log")"

run --tools pacman
check "pacman updates repository packages" \
    "sudo pacman -Syu
pacman -Syu" "$(cat "$WORK/log")"

echo
echo "# Sanity checks on the list of tools"
run --tools "pacman paru-repo flatpak" -l
check "a second tool for one kind of package is reported" \
    "bs-update: pacman and paru (repository packages) both update repository packages; using pacman" \
    "$err"
check "the conflicting tool is dropped, so nothing is counted twice" \
    "Pacman: 3
Flatpak: 4
Total: 7" "$out"

run --tools "pacman paru-repo"
check "only the first tool for one kind of package runs" \
    "sudo pacman -Syu
pacman -Syu" "$(cat "$WORK/log")"

run --tools "flatpak nosuchtool" -l
contains "an unknown tool is reported" "unknown tool 'nosuchtool'" "$err"
check "an unknown tool is ignored" \
    "Flatpak: 4
Total: 4" "$out"

echo
echo "# The configuration file the widget writes"
set_config <<'EOF'
# bs-updater update sources.
pacman=off
paru-repo=on
paru-aur=off
flatpak=on
gearlever=off
EOF
run -l
check "the configuration file selects the sources" \
    "Pacman: 3
Flatpak: 4
Total: 7" "$out"

run --tools gearlever -l
check "--tools overrides the configuration file" \
    "AppImage: 1
Total: 1" "$out"

set_config <<'EOF'
pacman=off
paru-repo=off
paru-aur=off
flatpak=off
gearlever=off
EOF
run -l
check "nothing enabled counts nothing" "Total: 0" "$out"
contains "nothing enabled is reported when checking" "no update tools are enabled" "$err"

run
check "nothing enabled fails instead of updating" "1" "$rc"
check "nothing enabled runs no tool" "" "$(cat "$WORK/log")"
check "nothing enabled writes no state file" \
    "no" "$([ -f "$XDG_CACHE_HOME/bs-updater/last-update" ] && echo yes || echo no)"

set_config <<'EOF'
pacman=off
paru-repo=on
paru-aur=on
dnf=off
nobara-sync=off
apt=off
flatpak=on
gearlever=on
EOF
run --list-tools
check "--list-tools shows every tool and its state" \
    "pacman       off asks       pacman: repository packages
paru-repo    on  asks       paru (repository packages): repository packages
paru-aur     on  asks       paru (AUR packages): AUR packages
dnf          off asks       DNF: RPM packages
nobara-sync  off asks       nobara-sync (RPM packages): RPM packages
nobara-sync-flatpak off asks       nobara-sync (Flatpak applications): Flatpak applications and runtimes
apt          off asks       APT: Debian packages
flatpak      on  asks       Flatpak: Flatpak applications and runtimes
gearlever    on  asks       Gear Lever: AppImages
plasmoid-updater off asks       plasmoid-updater: KDE Plasma 6 plasmoids
interaction level: confirm" "$out"

echo
echo "# KDE Plasma 6 plasmoids"
STUB_PLASMOID_COUNT=3 run --tools plasmoid-updater -l
check "plasmoid-updater counts from its summary line" \
    "Plasmoids: 3
Total: 3" "$out"

STUB_PLASMOID_COUNT=1 run --tools plasmoid-updater -l
check "one plasmoid update counts one" "Plasmoids: 1
Total: 1" "$out"

run --tools plasmoid-updater -l
check "no plasmoid update counts zero" "Plasmoids: 0
Total: 0" "$out"

run --tools plasmoid-updater
check "plasmoid-updater asks at the confirm level and leaves Plasma running" \
    "plasmoid-updater update --no-restart-plasma" "$(cat "$WORK/log")"
contains "the run says how to load the new plasmoids" \
    "restart Plasma" "$out"

run --tools plasmoid-updater --interaction auto
check "auto adds --yes" \
    "plasmoid-updater update --no-restart-plasma --yes" "$(cat "$WORK/log")"

# The real program can be installed on the test machine as well.
if ! PATH=$PATH_WITHOUT_PLASMOID command -v plasmoid-updater >/dev/null 2>&1; then
    PATH=$PATH_WITHOUT_PLASMOID run --tools plasmoid-updater -l
    check "a missing plasmoid-updater counts zero" "Plasmoids: 0
Total: 0" "$out"
    contains "a missing plasmoid-updater says how to install it" \
        "cargo install plasmoid-updater" "$err"
    PATH=$PATH_WITHOUT_PLASMOID run --tools plasmoid-updater
    check "a missing plasmoid-updater fails the run" "1" "$rc"

    mkdir -p "$HOME/.cargo/bin"
    cp "$PLASMOID_BIN/plasmoid-updater" "$HOME/.cargo/bin/"
    STUB_PLASMOID_COUNT=2 PATH=$PATH_WITHOUT_PLASMOID run --tools plasmoid-updater -l
    check "plasmoid-updater in ~/.cargo/bin is found outside the PATH" \
        "Plasmoids: 2
Total: 2" "$out"
    rm -r "$HOME/.cargo"
fi

echo
echo "# Fedora and Nobara"
run --tools dnf -l
check "dnf counts the RPM packages with an update" \
    "RPM: 5
Total: 5" "$out"
check "counting RPM updates does not need root" \
    "dnf -q check-update" "$(cat "$WORK/log")"

run --tools dnf
check "dnf installs the RPM updates" \
    "sudo dnf upgrade
dnf upgrade" "$(cat "$WORK/log")"

STUB_DNF_TRICKY=1 run --tools dnf -l
check "the count skips the metadata line, wrapped names are counted once, and the obsoleting section is not counted twice" \
    "RPM: 3
Total: 3" "$out"

STUB_RPM_COUNT=0 run --tools dnf -l
check "an up-to-date Fedora system counts zero" \
    "RPM: 0
Total: 0" "$out"

run --tools nobara-sync -l
check "nobara-sync counts its RPM updates with dnf" \
    "RPM: 5
Total: 5" "$out"

run --tools nobara-sync
check "nobara-sync runs its own cli mode and raises its own privileges" \
    "nobara-sync cli" "$(cat "$WORK/log")"

run --tools "dnf nobara-sync" -l
check "dnf and nobara-sync are reported as covering the same packages" \
    "bs-update: DNF and nobara-sync (RPM packages) both update RPM packages; using DNF" "$err"
check "only one RPM tool is counted" \
    "RPM: 5
Total: 5" "$out"

run --tools "nobara-sync flatpak gearlever" -l
check "a Nobara selection counts each source once" \
    "RPM: 5
Flatpak: 4
AppImage: 1
Total: 10" "$out"

run --tools "nobara-sync flatpak"
check "nobara-sync leaves Flatpaks to the flatpak tool" \
    "nobara-sync cli
flatpak update" "$(cat "$WORK/log")"

# Arch repository packages and RPM packages are different package sets, so
# a tool for one says nothing about the other and neither is dropped.
run --tools "pacman dnf" -l
check "pacman and dnf do not clash" "" "$err"
check "pacman and dnf are counted separately" \
    "Pacman: 3
RPM: 5
Total: 8" "$out"

STUB_DNF_RC=1 run --tools "dnf flatpak"
check "a failed dnf run fails the whole run" "1" "$rc"
check "a failed dnf run still updates the other sources" \
    "sudo dnf upgrade
dnf upgrade
flatpak update" "$(cat "$WORK/log")"

set_config <<'EOF'
# bs-updater update sources.
pacman=off
paru-repo=off
paru-aur=off
dnf=off
nobara-sync=on
flatpak=on
gearlever=off
EOF
run -l
check "the configuration file can select the Nobara sources" \
    "RPM: 5
Flatpak: 4
Total: 9" "$out"
clear_config

echo
echo "# Debian and Ubuntu"
run --tools apt -l
check "apt counts the Debian packages with an update" \
    "APT: 6
Total: 6" "$out"
check "counting Debian updates does not need root" \
    "apt-get -q -s upgrade" "$(cat "$WORK/log")"

run --tools apt
check "apt refreshes the package lists, then installs the updates" \
    "sudo apt-get update
apt-get update
sudo apt-get upgrade
apt-get upgrade" "$(cat "$WORK/log")"

STUB_APT_TRICKY=1 run --tools apt -l
check "the count takes the Inst lines only, so the notes, the package list, the kept back packages and the Conf lines are left out" \
    "APT: 2
Total: 2" "$out"

STUB_DEB_COUNT=0 run --tools apt -l
check "an up-to-date Debian system counts zero" \
    "APT: 0
Total: 0" "$out"

# Debian packages are their own kind of package, so an apt selection does
# not clash with the Arch or RPM tools.
run --tools "pacman dnf apt" -l
check "apt does not clash with the other package tools" "" "$err"
check "apt is counted next to them" \
    "Pacman: 3
RPM: 5
APT: 6
Total: 14" "$out"

run --tools "apt flatpak gearlever" -l
check "a Debian selection counts each source once" \
    "APT: 6
Flatpak: 4
AppImage: 1
Total: 11" "$out"

STUB_APT_RC=1 run --tools "apt flatpak"
check "a failed apt run fails the whole run" "1" "$rc"
check "a failed refresh leaves the packages alone, and the other sources still update" \
    "sudo apt-get update
apt-get update
flatpak update" "$(cat "$WORK/log")"

set_config <<'EOF'
# bs-updater update sources.
pacman=off
paru-repo=off
paru-aur=off
dnf=off
nobara-sync=off
apt=on
flatpak=on
gearlever=on
EOF
run -l
check "the configuration file can select the Debian sources" \
    "APT: 6
Flatpak: 4
AppImage: 1
Total: 11" "$out"
clear_config

echo
echo "# Notifications"
clear_config
run -l --notify
contains "the notification lists the enabled sources only" \
    "Pacman 3 | AUR 2 | Flatpak 4 | AppImage 1 — click to update system" \
    "$(sleep 1; cat "$WORK/log")"

run --tools flatpak -l --notify
contains "the notification body follows the selection" \
    "Flatpak 4 — click to update system" "$(sleep 1; cat "$WORK/log")"

STUB_REPO_COUNT=0 STUB_AUR_COUNT=0 STUB_FLATPAK_COUNT=0 STUB_APPIMAGE_COUNT=0 \
    run -l --notify-always
contains "an up-to-date system notifies with --notify-always" \
    "System is up to date" "$(sleep 1; cat "$WORK/log")"
check "an up-to-date system counts zero" \
    "Pacman: 0
AUR: 0
Flatpak: 0
AppImage: 0
Total: 0" "$out"

# One update notification at a time. run clears the cache directory, so
# these tests call bs-update directly after the first run, which keeps
# the notification file of the run before.
NOTE="$XDG_CACHE_HOME/bs-updater/notification"
run -l --notify
sleep 1
lacks "the first update notification replaces nothing" \
    " -r " "$(cat "$WORK/log")"

# A notification that is still on the screen. Its notify-send process is
# gone, the same as in the test stub.
echo 7 > "$NOTE"
: > "$STUB_LOG"
"$BS_UPDATE" -l --notify >/dev/null 2>&1
sleep 1
contains "a new update notification replaces the one on the screen" \
    "-r 7 " "$(cat "$WORK/log")"

echo 7 > "$NOTE"
: > "$STUB_LOG"
STUB_REPO_COUNT=0 STUB_AUR_COUNT=0 STUB_FLATPAK_COUNT=0 STUB_APPIMAGE_COUNT=0 \
    "$BS_UPDATE" -l --notify >/dev/null 2>&1
contains "a check that finds no updates closes the update notification" \
    "CloseNotification 7" "$(cat "$WORK/log")"
check "and forgets it" "no" "$([ -e "$NOTE" ] && echo yes || echo no)"

echo 7 > "$NOTE"
: > "$STUB_LOG"
"$BS_UPDATE" --interaction silent --start >/dev/null 2>&1
contains "starting an update closes the update notification" \
    "CloseNotification 7" "$(cat "$WORK/log")"

echo
echo "# A failing tool"
STUB_PARU_RC=1 run
check "a failed tool fails the run" "1" "$rc"
check "a failed tool does not stop the other tools" \
    "paru -Syu
flatpak update
flatpak run it.mijorus.gearlever --update --all --yes" "$(cat "$WORK/log")"
check "a failed run writes no state file, so the widget keeps its icon" \
    "no" "$([ -f "$XDG_CACHE_HOME/bs-updater/last-update" ] && echo yes || echo no)"

echo
echo "# nobara-sync and Flatpak applications"
clear_config

run --tools nobara-sync,nobara-sync-flatpak -l
check "both nobara-sync entries count their own kind of package" \
    "RPM: 5
Flatpak: 4
Total: 9" "$out"

run --tools nobara-sync,nobara-sync-flatpak
check "one nobara-sync run covers both, with --all" \
    "nobara-sync cli --all" "$(cat "$WORK/log")"

run --tools nobara-sync
check "nobara-sync alone leaves the Flatpak applications alone" \
    "nobara-sync cli" "$(cat "$WORK/log")"

run --tools nobara-sync-flatpak -l
contains "the Flatpak entry alone is refused" \
    "only together with the RPM packages" "$err"
check "and nothing is counted" "Total: 0" "$out"

run --tools nobara-sync-flatpak,flatpak -l
contains "nobara-sync and flatpak clash over the same packages" \
    "both update Flatpak applications" "$err"

run --tools nobara-sync,nobara-sync-flatpak,flatpak -l
check "the clash leaves one count, not two" \
    "RPM: 5
Flatpak: 4
Total: 9" "$out"

echo
echo "# The interaction level"
clear_config

run -l --list-tools
contains "the level is confirm without a configuration file" \
    "interaction level: confirm" "$out"

run
check "confirm asks before each install" \
    "paru -Syu
flatpak update
flatpak run it.mijorus.gearlever --update --all --yes" "$(cat "$WORK/log")"

run --interaction auto
check "auto adds the option that skips the question" \
    "paru -Syu --noconfirm --skipreview
flatpak update -y
flatpak run it.mijorus.gearlever --update --all --yes" "$(cat "$WORK/log")"

# A run in a terminal asks for the root password in that terminal, at
# every level. The graphical password dialog is only for a run with no
# terminal, which --start begins.
run --interaction silent
check "silent in a terminal installs without a question" \
    "paru -Syu --noconfirm --skipreview
flatpak update -y
flatpak run it.mijorus.gearlever --update --all --yes" "$(cat "$WORK/log")"

run --interaction silent --start
contains "silent --start asks for the password in a window" \
    "paru --sudoflags -A -Syu" "$(cat "$WORK/log")"
contains "silent --start reports the result" \
    "notify-send" "$(cat "$WORK/log")"

run --interaction auto --start
lacks "auto --start opens a terminal instead of running in the background" \
    "--sudoflags" "$(cat "$WORK/log")"
contains "auto --start opens the terminal" "konsole -e" "$(cat "$WORK/log")"

run --tools pacman --interaction auto
check "pacman gets --noconfirm" "sudo pacman -Syu --noconfirm
pacman -Syu --noconfirm" "$(cat "$WORK/log")"

run --tools dnf --interaction auto
check "dnf gets -y" "sudo dnf upgrade -y
dnf upgrade -y" "$(cat "$WORK/log")"

run --tools apt --interaction auto
contains "apt answers the configuration file questions" \
    "DEBIAN_FRONTEND=noninteractive" "$(cat "$WORK/log")"

run --tools nobara-sync --interaction auto
check "nobara-sync still asks, it has no option for this" \
    "nobara-sync cli" "$(cat "$WORK/log")"

run --interaction bogus --list-tools
contains "an unknown level warns" "unknown interaction level" "$err"
contains "an unknown level falls back to confirm" \
    "interaction level: confirm" "$out"

set_config <<'EOF'
paru-aur=on
interaction=auto
EOF
run --list-tools
contains "the configuration file sets the level" \
    "interaction level: auto" "$out"
run
check "the configured level reaches the install" \
    "paru -Sua --noconfirm --skipreview" "$(cat "$WORK/log")"

run --interaction confirm
check "an explicit level wins over the configured one" \
    "paru -Sua" "$(cat "$WORK/log")"
clear_config

echo
echo "# Help"
run --help
contains "the help text shows the usage" "bs-update --tools LIST" "$out"
check "the help text exits successfully" "0" "$rc"

run --nonsense
check "an unknown option fails" "1" "$rc"
contains "an unknown option shows the usage" "Usage:" "$err"

echo
echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ]
