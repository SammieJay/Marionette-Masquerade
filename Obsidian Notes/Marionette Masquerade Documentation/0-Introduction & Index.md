# Plugins Required
*Can be installed via the settings menu by enabling community plugins*
[Tree Diagrams](https://obsidian.md/plugins?id=tree-diagram)

# Obsidian Documentation
[Obsidian Documentation](https://obsidian.md/help/)
## Basic Formatting
*Obsidian just uses Markdown formatting for the most part, but uses unique formatting for its links and other local features, here are some examples*

**Headers**
\# Heading 1
\## Heading 2
\### Heading 3

**Bold Text**
\*\*bolded text\*\*
(CTL+B shortcut also works)

**Italics**
\*Italicized text\*
(CTL+I shortcut also works)


**Inter-Note Links**
*basic link*
\[\[note filename]]

*link with display text*
\[\[note filename | display text]]

*link to specific header within note*
\[\[note filename \#header text]]

*link to specific header within note with display text*
\[\[note filename \#header text | display text]]

**Weblink**
\[display text](website link)

**Indentation**
uses \-

Example:
- thing 1
	- thing 1.1
	- thing 1.2
- thing 2
	- thing 2.1
		- thing 2.1.1

**Checkbox**
\-\[ ]
- [ ] Like this (can only be first element of line)

# Special Formatting Features

**Code Snippets**
a double \` lets you put code inline with text ``var isSmelly:bool
\`\` inline code

triple \` at top line and bottom line makes a code block
```
#block of code
func some_function()->void:
```


**Separator Line**
uses: \****

Example:
****


**Tree Diagram (From Plugin)**
Example:
```tree
root
	home
	boot
	var
		log
	usr
		local
			bin
			sbin
			lib
		bin
			cat
		sbin
	etc
```

