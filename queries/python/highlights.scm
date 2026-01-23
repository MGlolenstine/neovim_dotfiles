; Custom Python highlights query to override Neovim's buggy built-in query
; This fixes the "except*" query syntax error in Neovim 0.11.5
; Based on the standard Python highlights but with the problematic "except*" line removed

; Comments
(comment) @comment

; Functions
(function_definition
  name: (identifier) @function)

; Classes
(class_definition
  name: (identifier) @type)

; Decorators
(decorator) @function

; Parameters
(parameters
  (identifier) @parameter)

; Variables
(identifier) @variable

; Keywords
[
  "and"
  "as"
  "assert"
  "async"
  "await"
  "break"
  "class"
  "continue"
  "def"
  "del"
  "elif"
  "else"
  "except"
  "finally"
  "for"
  "from"
  "global"
  "if"
  "import"
  "in"
  "is"
  "lambda"
  "nonlocal"
  "not"
  "or"
  "pass"
  "raise"
  "return"
  "try"
  "while"
  "with"
  "yield"
] @keyword

; Operators
[
  "="
  "+"
  "-"
  "*"
  "/"
  "//"
  "%"
  "**"
  "=="
  "!="
  "<"
  "<="
  ">"
  ">="
  "and"
  "or"
  "not"
  "in"
  "is"
] @operator

; Strings
(string) @string
(escape_sequence) @string.escape

; Numbers
(integer) @number
(float) @number

; Builtins
((identifier) @variable.builtin
  (#match? @variable.builtin "^(self|cls)$"))

; Constants
((identifier) @constant
  (#match? @constant "^[A-Z_][A-Z0-9_]*$"))

; Type hints
(type) @type

; F-strings
(f_string) @string
