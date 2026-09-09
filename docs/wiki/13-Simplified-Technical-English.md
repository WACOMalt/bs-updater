# 13. Simplified Technical English

## 13.1 The specification

ASD-STE100 is Simplified Technical English. It is a controlled language for
technical documentation. The aerospace industry and the defence industry
made it, and other industries now use it. The current edition is Issue 9,
from 15 January 2025.

The specification has two parts:

- **Part 1, the writing rules.** The rules control the grammar and the
  style of the text.
- **Part 2, the dictionary.** The dictionary gives the approved words and
  the words that are not approved. It also gives an approved alternative
  for each word that is not approved.

The specification lets a project add its own **technical names** and
**technical verbs** to the approved words. Section 13.4 and section 13.5
declare these words for bs-updater.

## 13.2 The compliance statement

This paper applies the writing rules of Part 1 to each page. Section 13.3
lists the rules that this paper applies.

This paper applies the vocabulary of Part 2 as far as a public project can.
The dictionary is not a public document, so this paper cannot quote it and
cannot include a machine check against it. The text uses a small
vocabulary, and it prefers the approved alternative for each common word
that Part 2 rejects. Section 13.6 gives the substitutions.

Section 13.7 declares the deviations. A reader with a copy of the
specification can examine the paper against Part 2 and can correct a word.

## 13.3 The rules that this paper applies

**Words**

- Use one word for one meaning, and one meaning for one word.
- Use a word in one part of speech only, or declare the second part of
  speech in section 13.4.
- Do not use a synonym of a word that the text uses already.
- Do not use a word that Part 2 rejects, if an approved alternative exists.

**Noun clusters**

- Use a maximum of three nouns in a cluster.
- Make a longer cluster into a phrase with a preposition. For example,
  write "the settings page of the widget" and not "the widget settings
  page".

**Verbs**

- Use the active voice.
- Use the simple present, the simple past, the future, the infinitive and
  the imperative.
- Do not use the `-ing` form, except in a technical name.
- Do not use a complex verb form.

**Sentences**

- Use a maximum of 20 words in a procedural sentence.
- Use a maximum of 25 words in a descriptive sentence.
- Start a sentence with its topic.
- Use the articles "a" and "the".
- Do not remove a word to make a sentence shorter.

**Procedures**

- Write one instruction in one sentence.
- Use the imperative for an instruction.
- Use a numbered list for a sequence of instructions.
- Use a maximum of six sentences in a paragraph.

**Descriptive writing**

- Use a table or a list in place of a long paragraph.
- Give the reason for a design decision in a separate sentence.

**Safety instructions**

- Put a warning or a caution before the instruction that it applies to.
- Start a warning or a caution with a command.

**Punctuation**

- Do not use a bracket in the middle of a sentence.
- Do not use the oblique stroke, except in a path or in a unit.
- Do not use an ampersand in place of the word "and".
- Do not use a contraction.

## 13.4 The declared technical names

A technical name is a noun that names a part, a tool, a state or a concept
of this product. The specification permits a technical name that no
approved word can replace.

| Technical name | Definition in this paper |
| --- | --- |
| AppImage | One file that holds a complete application. |
| AUR | The Arch User Repository. |
| bs-update | The command of this product. |
| bs-updater | This product. |
| check | One operation that counts the available updates. |
| checkbox | One control in the settings page. |
| command | One program that a user starts in a terminal. |
| configuration file | The file `tools.conf`. |
| directory | One node of the file system that holds files. |
| heading | The first column of a line of the list output. |
| distribution | One Linux system, for example Fedora. |
| Flatpak | The application system with the same name. |
| Gear Lever | The application that integrates AppImages. |
| icon | The image of the widget in the system tray. |
| interval | The time between two scheduled checks. |
| KDE Plasma | The desktop environment. |
| notification | One message of the desktop environment. |
| option | One argument of the command line. |
| package | One unit of software of a package manager. |
| package domain | One kind of package. Chapter 3 gives the six domains. |
| package manager | One program that installs packages. |
| repository | One server that holds packages. |
| root | The account with all privileges. |
| script | One program in a shell language or in QML. |
| settings | The two configuration pages of the widget. |
| shell | The command interpreter. |
| source | Short form of "update source". |
| state file | The file `last-update`. |
| stub | One small script that replaces a tool in a test. |
| system tray | The area of the panel that holds status icons. |
| terminal | One window with a shell in it. |
| tool | One program that bs-updater starts, for example DNF. |
| tooltip | The text that Plasma shows near the icon. |
| update | One newer version of a package. |
| update source | One system that supplies updates. |
| widget | The applet of this product for KDE Plasma. |

The names of the tools are also technical names: pacman, paru, DNF,
nobara-sync, APT, Flatpak and Gear Lever. The same applies to the names of
the distributions and to each identifier in a code example.

## 13.5 The declared technical verbs

| Technical verb | Definition in this paper |
| --- | --- |
| check | To count the available updates of a source. |
| clear | To remove the mark from a checkbox. |
| click | To press a button of the mouse. |
| count | To find how many updates are available. |
| install | To put software on the system. |
| parse | To read data from the output of a tool. |
| poll | To read a value again after a constant interval. |
| refresh | To download the package lists again. |
| select | To put a mark in a checkbox. |
| update | To replace software with a newer version. |

## 13.6 The substitutions

The left column holds a word that this paper does not use. The right column
holds the word that this paper uses in its place.

| Word not used | Word used |
| --- | --- |
| allow | let |
| approximately | about |
| ensure, verify | make sure |
| however | but |
| in order to | to |
| including | for example |
| multiple | more than one |
| prior to | before |
| provide | give, supply |
| require | must have |
| need (verb) | must have |
| subsequently | then |
| utilize | use |
| various | different |
| via | with, through |
| display (verb) | show |
| perform | do |
| occur | happen |
| determine | find |
| indicate | show |
| attempt | try |

## 13.7 The declared deviations

| Deviation | Reason |
| --- | --- |
| The paper cannot examine each word against Part 2. | The dictionary is not a public document. |
| "check" and "update" are each a noun and a verb. | The two parts of speech are in the user interface of the product. Sections 13.4 and 13.5 declare both. |
| The paper quotes no rule number. | The specification is not a redistributable document. |
| Code examples and output examples hold their original text. | A change to a command or to an output would make the example incorrect. |
| Names in the user interface hold their original text. | The text must agree with the screen. |
| Terms of the specification hold their original text. | Examples: "writing rules", "descriptive writing", "one word, one meaning". A different term would not agree with the specification. |
| Section 13.6 holds words that this paper does not use. | The table is data. It is not text of the paper. |

## 13.8 How to write a new page

1. Read this chapter and chapter 14 first.
2. Write one instruction in one sentence.
3. Count the words of each sentence. Correct a sentence with more than 20
   words in a procedure, or 25 words in a description.
4. Find each `-ing` form and remove it.
5. Find each passive verb and make it active.
6. Find each noun cluster with more than three nouns and make it a phrase.
7. Add a new technical name to section 13.4 if the page must have it.
8. Use a table or a list in place of a long paragraph.
