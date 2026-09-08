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

cat > "$STUB_BIN/notify-send" <<'EOF'
#!/bin/sh
echo "notify-send $*" >> "$STUB_LOG"
EOF

chmod 755 "$STUB_BIN"/*

PATH="$STUB_BIN:$PATH"
export PATH
export HOME="$WORK/home"
export XDG_CONFIG_HOME="$WORK/config"
export XDG_CACHE_HOME="$WORK/cache"
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
STUB_FLATPAK_COUNT=4
STUB_APPIMAGE_COUNT=1
export STUB_REPO_COUNT STUB_AUR_COUNT STUB_RPM_COUNT
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
flatpak=on
gearlever=on
EOF
run --list-tools
check "--list-tools shows every tool and its state" \
    "pacman       off pacman: repository packages
paru-repo    on  paru (repository packages): repository packages
paru-aur     on  paru (AUR packages): AUR packages
dnf          off DNF: RPM packages
nobara-sync  off nobara-sync: RPM packages
flatpak      on  Flatpak: Flatpak applications and runtimes
gearlever    on  Gear Lever: AppImages" "$out"

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
    "bs-update: DNF and nobara-sync both update RPM packages; using DNF" "$err"
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
