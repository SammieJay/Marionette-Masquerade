# Variable Naming
*Generally variables use camelCase, with some exceptions as listed below*

| *Type*                      | *Convention*     | *Example*         |
| --------------------------- | ---------------- | ----------------- |
| Local Variable (basic case) | lowerCamelCase   | enemyCount        |
| Script Wide Variable        | lowerCamelCase   | currentHealth     |
| Function Parameter          | \_lowerCamelCase | \_targetEnemy     |
| Constant                    | UPPER_SNAKE_CASE | MAX_HEALTH        |
| Enum Values                 | UPPER_SNAKE_CASE | State.PATROL_AREA |
| Class/node names            | UpperCamelCase   | InputHandler      |

***
# Function Naming
#function
- Generally functions should be snake case
- \_ready() and \_process() functions should go FIRST
	- except for getter & setter functions

### Quick Function Naming Guide

| *Type*                      | *Convention*          | *Example*                      | *Notes*                                                 |
| --------------------------- | --------------------- | ------------------------------ | ------------------------------------------------------- |
| Core Function               | snake_case            | player_movement(delta):        |                                                         |
| Helper Function             | \_lower_snake_case    | \_count_enemies_nearby()->int: | Only called <br>from within the<br>script it's declared |
| Getters                     | get\_ + snake_case    | get_player_health()->float:    | Ideally Inline                                          |
| Setters                     | set\_ + snake_case    | set_player_health(float):      | Ideally Inline                                          |
| Boolean Return (state)      | is\_ + snake_case<br> | is_alive()->bool:<br>          | Ideally Inline                                          |
| Boolean Return (capability) | can\_ + snake_case    | can_see_player()->bool:        |                                                         |

### Mainline Function
*Core functionality, called from within function or elsewhere*
- Follows general function naming (snake case)

Example:
``func player_movement(delta:float)->void:

### Helper Function
*Functions only used within the script they are written, mainly for readability*
- has a leading underscore

Example:
``func _helper_function()->void:
### Getter & Setter Functions
#get #set
- Uses default snake case but simply includes "get_" or "set_" at the start
- Getters and setters should be located at the top of the script, below all the script variables but before the \_ready() and \_process() functions
- These functions should only be one line where possible

Examples:
``func get_health()->float: return health
``func set_health( _hp : float )->void: health = _hp

### Boolean Return Functions
#boolean
*Called from other scripts (or within script) to check the status of the class

- uses normal snake case but starts with prefix "is_" or "can_" followed by the state you are checking for
- These functions should be used over script wide Booleans wherever possible 
	- @export booleans are the exception, which are used for setting states from the editor
	- export booleans may also have an accompanying boolean return function that just returns the boolean (for consistency)

Examples:
``func is_alive()->bool: return health > 0.0
``func is_moving()->bool: return velocity.length() > 0.0



