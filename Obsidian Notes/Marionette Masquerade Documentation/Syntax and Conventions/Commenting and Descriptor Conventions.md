**Remember...**
```
# this is a basic comment that the editor will ignore

## this is a comment that will be used in inline documentation by the editor
## (for the variable or function that is on the next line)
func described_function() -> void:
```

***
# Class Descriptors
*At the top of each defined class (anything with a class name) add the following formatted header and fill in as needed*
```
## [ClassName] – one-line summary of what this class does.
##
## [b]Responsibilities:[/b] [br]
##   - Core responsibility one [br]
##   - Core responsibility two [br]
```
*Godot will recognize this and use it for in-line documentation when referenced from other scripts*

**Notes**
- one-line summary should include important implementation information like
	- Whether the class is an abstract class (only meant to be inherited)


***
# Function Descriptors

## Core/mainline functions
```
## [One-line summary of purpose] [br]
## [b]Expects:[/b] [preconditions or notable param details, if non-obvious] [br]
## [b]Returns:[/b] [what the return value means, if non-void] [br]
```

## Virtual Functions (To be overridden)

```
## [b]VIRTUAL[/b][br]
## Called when: [trigger/event] [br]
## Handles: [what overrides should do] [br]
```

## Helper Functions
```
## One-line summary
```