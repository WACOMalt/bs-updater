# bs-updater technical paper

bs-updater updates all software on a Linux system with one command. It also
supplies a tray widget for KDE Plasma. The widget shows how many updates are
available.

This wiki is the technical paper for the project. Each page is one chapter.
The chapters describe the purpose, the design, the installation, the
configuration, the operation and the maintenance of bs-updater.

## Language of this paper

The text obeys ASD-STE100, Simplified Technical English, Issue 9. The
specification supplies a set of writing rules and a dictionary of approved
words. It also lets a project declare its own technical names and technical
verbs. Chapter 13 gives the compliance statement and the declared words.

## Contents

| Chapter | Page | Content |
| --- | --- | --- |
| 1 | [Introduction and scope](01-Introduction-and-Scope) | What the product does, and what it does not do. |
| 2 | [System description](02-System-Description) | The two parts of the product and their tasks. |
| 3 | [Update sources](03-Update-Sources) | The supported tools, the package domains and the conflict rule. |
| 4 | [Installation](04-Installation) | How to install, and what the installation script does. |
| 5 | [Configuration](05-Configuration) | The settings pages and the configuration file. |
| 6 | [Operation](06-Operation) | The states of the widget, the icons and the notifications. |
| 7 | [Command reference](07-Command-Reference) | Every option of `bs-update`, with the output format. |
| 8 | [Architecture](08-Architecture) | The files, the data flow and the design decisions. |
| 9 | [Distribution notes](09-Distribution-Notes) | Arch Linux, Fedora, Nobara, Debian and Ubuntu. |
| 10 | [Verification](10-Verification) | The test suite and what each group of tests proves. |
| 11 | [The release procedure](11-Release-Procedure) | How to build and publish a new version. |
| 12 | [Fault isolation](12-Fault-Isolation) | Symptoms, causes and corrective actions. |
| 13 | [Simplified Technical English](13-Simplified-Technical-English) | The compliance statement and the declared words. |
| 14 | [Glossary](14-Glossary) | The terms that this paper uses. |

## How to read this paper

- If you are a user, read chapters 1, 4, 5, 6 and 9.
- If you are a maintainer, read chapters 2, 3, 8, 10 and 11.
- If you write text for this project, read chapters 13 and 14 first.

## Document data

| Item | Value |
| --- | --- |
| Title | bs-updater technical paper |
| Product | bs-updater |
| Applicable product version | 1.10.0 |
| Language | Simplified Technical English, ASD-STE100 Issue 9 |
| License of the product | The Unlicense, public domain |
| Knowledge space | BUPI |
