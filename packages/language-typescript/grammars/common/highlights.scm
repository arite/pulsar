; IMPORTS/EXPORTS
; ===============

; The "Foo" in `import Foo from './bar'`
(import_clause
  (identifier) @variable.other.assignment.import._LANG_)

; The "Foo" in `import { Foo } from './bar'`
(import_specifier
  (identifier) @variable.other.assignment.import._LANG_)

; The "Foo" in `export { Foo }`
(export_specifier
  name: (identifier) @variable.other.assignment.export._LANG_)

; The "default" in `export { Foo as default }`
(export_specifier
  alias: (identifier) @keyword.control.default._LANG_
  (#eq? @keyword.control.default._LANG_ "default"))

; The "default" in `export default Foo`
(export_statement
  "default" @keyword.control.default._LANG_)

; The "Foo" in `export Foo`
(export_statement
  (identifier) @variable.other.assignment.export._LANG_)


; COMMENTS
; ========

((comment) @comment.line.double-slash._LANG_
  (#match? @comment.line.double-slash._LANG_ "^//"))

((comment) @punctuation.definition.comment._LANG_
  (#match? @punctuation.definition.comment._LANG_ "^//")
  (#set! adjust.startAndEndAroundFirstMatchOf "^//"))

((comment) @comment.block._LANG_
  (#match? @comment.block._LANG_ "^/\\*"))

((comment) @punctuation.definition.comment.begin._LANG_
  (#match? @punctuation.definition.comment.begin._LANG_ "^/\\*")
  (#set! adjust.startAndEndAroundFirstMatchOf "^/\\*"))

((comment) @punctuation.definition.comment.end._LANG_
  (#match? @punctuation.definition.comment.end._LANG_ "\\*/$")
  (#set! adjust.startAndEndAroundFirstMatchOf "\\*/$"))


; PROPERTIES
; ==========

((property_identifier) @constant.other.property._LANG_
  (#match? @constant.other.property._LANG_ "^[\$A-Z_]+$")
  (#set! test.final true))

; (property_identifier) @variable.other.object.property._LANG_

((shorthand_property_identifier) @constant.other._LANG_
  (#match? @constant.other._LANG_ "^[\$A-Z_]{2,}$"))

; CLASSES
; =======

(class_declaration
  name: (type_identifier) @entity.name.type.class._LANG_)

(extends_clause
  value: (_) @entity.other.inherited-class._LANG_)

(public_field_definition
  name: (property_identifier) @variable.declaration.field._LANG_)

(new_expression
  constructor: (identifier) @support.type.class._LANG_)

; A class getter:
; the "get" in `get foo () {...`
(method_definition
  "get" @storage.getter._LANG_)

; A class setter:
; the "set" in `set foo (value) {...`
(method_definition
  "set" @storage.setter._LANG_)


; INTERFACES
; ==========

(interface_declaration
  name: (_) @entity.name.type.interface._LANG_)

; TYPES
; =====

["var" "let" "const"] @storage.modifier._TYPE_._LANG_
["extends" "static" "async"] @storage.modifier._TYPE_._LANG_

["class" "function"] @storage.type._TYPE_._LANG_

"=>" @storage.type.arrow._LANG_

; TODO: If I allow scopes like `storage.type.string._LANG_`, I will make a lot of
; text look like strings by accident. This really needs to be fixed in syntax
; themes.
(predefined_type _ @storage.type._LANG_ @support.type._LANG_)

(type_alias_declaration
  name: (type_identifier) @variable.declaration.type._LANG_)

((literal_type [(null) (undefined)]) @storage.type._TEXT_._LANG_)
((literal_type [(null) (undefined)]) @support.type._TEXT_._LANG_
  (#set! test.final true))

; TODO: Decide whether other literal types — strings, booleans, and whatnot —
; should be highlighted as they are in JS, or should be highlighted like other
; types in annotations.

[
  "implements"
  "namespace"
  "enum"
  "interface"
  "module"
  "declare"
  "public"
  "private"
  "protected"
  "readonly"
  "satisfies"
  "type"
] @storage.modifier._TYPE_._LANG_

(index_signature
  name: (identifier) @entity.other.attribute-name.type._LANG_)

((type_identifier) @storage.type._LANG_
  ; (#set! test.onlyIfDescendantOfType "type_annotation type_arguments satisfies_expression type_parameter")
  )

; A capture can satisfy more than one of these criteria, so we need to guard
; against multiple matches. That's why we use `test.final` here, and why the
; two capture names are applied in separate captures — otherwise `test.final`
; would be applied after the first capture.
((type_identifier) @support.type._LANG_
  ; (#set! test.onlyIfDescendantOfType "type_annotation type_arguments satisfies_expression type_parameter")
  (#set! test.final true))

; OBJECTS
; =======

; The "foo" in `{ foo: true }`.
(pair
  key: (property_identifier) @entity.other.attribute-name._LANG_)

; TODO: This is both a key and a value, so opinions may vary on how to treat it.
(object
  (shorthand_property_identifier) @entity.other.attribute-name.shorthand._LANG_)

; The "foo" in `foo.bar`.
(member_expression
  object: (identifier) @support.other.object._LANG_)

; The "bar" in `foo.bar.baz`.
(member_expression
  object: (member_expression
    property: (property_identifier) @support.other.object._LANG_))


(property_signature
  (property_identifier) @entity.other.attribute-name._LANG_)

; FUNCTIONS
; =========

(method_definition
  name: (property_identifier) @entity.name.function.method._LANG_)

(call_expression
  function: (member_expression
    property: (property_identifier) @support.other.function.method._LANG_))

; Named function expressions:
; the "foo" in `let bar = function foo () {`
(function
  name: (identifier) @entity.name.function.definition._LANG_)

; Function definitions:
; the "foo" in `function foo () {`
(function_declaration
  name: (identifier) @entity.name.function.definition._LANG_)

; Named generator function expressions:
; the "foo" in `let bar = function* foo () {`
(generator_function
  name: (identifier) @entity.name.function.generator.definition._LANG_)

; Generator function definitions:
; the "foo" in `function* foo () {`
(generator_function_declaration
  name: (identifier) @entity.name.function.generator.definition._LANG_)

; Method definitions:
; the "foo" in `foo () {` (inside a class body)
(method_definition
  name: (property_identifier) @entity.name.function.method.definition._LANG_)

; Function property assignment:
; The "foo" in `thing.foo = (arg) => {}`
(assignment_expression
  left: (member_expression
    property: (property_identifier) @entity.name.function.definition._LANG_
    (#set! test.final true))
  right: [(arrow_function) (function)])

; Function variable assignment:
; The "foo" in `let foo = function () {`
(variable_declarator
  name: (identifier) @entity.name.function.definition._LANG_
  value: [(function) (arrow_function)])

; Function variable reassignment:
; The "foo" in `foo = function () {`
(assignment_expression
  left: (identifier) @function
  right: [(function) (arrow_function)])

; Object key-value pair function:
; The "foo" in `{ foo: function () {} }`
(pair
  key: (property_identifier) @entity.name.function.method.definition._LANG_
  value: [(function) (arrow_function)])

(function "function" @storage.type.function._LANG_)
(function_declaration "function" @storage.type.function._LANG_)

(generator_function "function" @storage.type.function._LANG_)
(generator_function_declaration "function" @storage.type.function._LANG_)

(generator_function "*" @storage.modifier.generator._LANG_)
(generator_function_declaration "*" @storage.modifier.generator._LANG_)
(method_definition "*" @storage.modifier.generator._LANG_)


; VARIABLES
; =========

(this) @variable.language.this._LANG_
(super) @variable.language.super._LANG_._LANG_x

(required_parameter
  pattern: (identifier) @variable.parameter._LANG_)

(required_parameter
  pattern: (object_pattern
    (shorthand_property_identifier_pattern) @variable.parameter.destructuring._LANG_)
    (#set! test.final true))

["var" "const" "let"] @storage.type._TYPE_._LANG_

; A simple variable declaration:
; The "foo" in `let foo = true`
(variable_declarator
  name: (identifier) @variable.other.assignment._LANG_)

; A reassignment of a variable declared earlier:
; The "foo" in `foo = true`
(assignment_expression
  left: (identifier) @variable.other.assignment._LANG_)

; The "foo" in `foo += 1`.
(augmented_assignment_expression
  left: (identifier) @variable.other.assignment._LANG_)

; The "foo" in `foo++`.
(update_expression
  argument: (identifier) @variable.other.assignment._LANG_)

; `object_pattern` appears to only be encountered in assignment expressions, so
; this won't match other uses of object/prop shorthand.
((object_pattern
  (shorthand_property_identifier_pattern) @variable.other.assignment.destructuring._LANG_))

; A variable object destructuring with default value:
; The "foo" in `let { foo = true } = something`
(object_assignment_pattern
  (shorthand_property_identifier_pattern) @variable.other.assignment.destructuring._LANG_)

; A variable object alias destructuring:
; The "bar" and "foo" in `let { bar: foo } = something`
(object_pattern
  (pair_pattern
    ; TODO: This arguably isn't an object key.
    key: (_) @entity.other.attribute-name._LANG_
    value: (identifier) @variable.other.assignment.destructuring._LANG_))

; A variable object alias destructuring with default value:
; The "bar" and "foo" in `let { bar: foo = true } = something`
(object_pattern
  (pair_pattern
    ; TODO: This arguably isn't an object key.
    key: (_) @entity.other.attribute-name._LANG_
    value: (assignment_pattern
      left: (identifier) @variable.other.assignment.destructuring._LANG_)))

; A variable array destructuring:
; The "foo" and "bar" in `let [foo, bar] = something`
(variable_declarator
  (array_pattern
    (identifier) @variable.other.assignment.destructuring._LANG_))

; A variable declaration in a for…(in|of) loop:
; The "foo" in `for (let foo of bar) {`
(for_in_statement
  left: (identifier) @variable.other.assignment.loop._LANG_)

; A variable array destructuring in a for…(in|of) loop:
; The "foo" and "bar" in `for (let [foo, bar] of baz)`
(for_in_statement
  left: (array_pattern
    (identifier) @variable.other.assignment.loop._LANG_))

; A variable object destructuring in a for…(in|of) loop:
; The "foo" and "bar" in `for (let { foo, bar } of baz)`
(for_in_statement
  left: (object_pattern
    (shorthand_property_identifier_pattern) @variable.other.assignment.loop._LANG_))

; A variable object destructuring in a for…(in|of) loop:
; The "foo" in `for (let { bar: foo } of baz)`
(for_in_statement
  left: (object_pattern
    (pair_pattern
      key: (_) @entity.other.attribute-name._LANG_
      value: (identifier) @variable.other.assignment.loop._LANG_)
      (#set! test.final true)))

; The "error" in `} catch (error) {`
(catch_clause
  parameter: (identifier) @variable.other.assignment.catch._LANG_)

; Single parameter of an arrow function:
; The "foo" in `(foo => …)`
(arrow_function parameter: (identifier) @variable.parameter._LANG_)

; BUILTINS
; ========

((identifier) @support.object.builtin._TEXT_._LANG_
  (#match? @support.object.builtin._TEXT_._LANG_ "^(arguments|module|window|document)$")
  (#is-not? local)
  (#set! test.final true))

((identifier) @support.object.builtin.filename._LANG_
  (#eq? @support.object.builtin.filename._LANG_ "__filename")
  (#is-not? local)
  (#set! test.final true))

((identifier) @support.object.builtin.dirname._LANG_
  (#eq? @support.object.builtin.dirname._LANG_ "__dirname")
  (#is-not? local)
  (#set! test.final true))

((identifier) @support.function.builtin.require._LANG_
  (#eq? @support.function.builtin.require._LANG_ "require")
  (#is-not? local)
  (#set! test.final true))

((identifier) @constant.language.infinity._LANG_
  (#eq? @constant.language.infinity._LANG_ "Infinity")
  (#set! test.final true))

; Things that `LOOK_LIKE_CONSTANTS`.
([(property_identifier) (identifier)] @constant.other._LANG_
  (#match? @constant.other._LANG_ "^[A-Z_][A-Z0-9_]*$")
  (#set! test.shy true))


; NUMBERS
; =======

(number) @constant.numeric._LANG_

; STRINGS
; =======

((string "\"") @string.quoted.double._LANG_)
((string
  "\"" @punctuation.definition.string.begin._LANG_)
  (#set! test.onlyIfFirst true))

((string
  "\"" @punctuation.definition.string.end._LANG_)
  (#set! test.onlyIfLast true))

((string "'") @string.quoted.single._LANG_)
((string
  "'" @punctuation.definition.string.begin._LANG_)
  (#set! test.onlyIfFirst true))

((string
  "'" @punctuation.definition.string.end._LANG_)
  (#set! test.onlyIfLast true))

(template_string) @string.quoted.template._LANG_

((template_string "`" @punctuation.definition.string.begin._LANG_)
  (#set! test.onlyIfFirst true))
((template_string "`" @punctuation.definition.string.end._LANG_)
  (#set! test.onlyIfLast true))

; Interpolations inside of template strings.
(template_substitution
  "${" @punctuation.definition.template-expression.begin._LANG_
  "}" @punctuation.definition.template-expression.end._LANG_
) @meta.embedded.line.interpolation._LANG_

; CONSTANTS
; =========

[
  (true)
  (false)
] @constant.language.boolean._TYPE_._LANG_

[
  (null)
  (undefined)
] @constant.language._TYPE_._LANG_

; KEYWORDS
; ========

[
  "as"
  "if"
  "do"
  "else"
  "while"
  "for"
  "in"
  "of"
  "return"
  "break"
  "continue"
  "throw"
  "try"
  "catch"
  "finally"
  "switch"
  "case"
  "default"
  "export"
  "import"
  "from"
  "yield"
  "await"
  "debugger"
] @keyword.control._TYPE_._LANG_

; OPERATORS
; =========

["delete" "instanceof" "typeof" "keyof"] @keyword.operator._TYPE_._LANG_
"new" @keyword.operator.new._LANG_

"=" @keyword.operator.assignment._LANG_
(non_null_expression "!" @keyword.operator.non-null._LANG_)
(unary_expression"!" @keyword.operator.unary._LANG_)

[
  "+="
  "-="
  "*="
  "/="
  "%="
  "<<="
  ">>="
  ">>>="
  "&="
  "^="
  "|="
] @keyword.operator.assignment.compound._LANG_

[
  "+"
  "-"
  "*"
  "/"
  "%"
] @keyword.operator.arithmetic._LANG_

[
  "=="
  "==="
  "!="
  "!=="
  ">="
  "<="
  ">"
  "<"
] @keyword.operator.comparison._LANG_

["++" "--"] @keyword.operator.increment._LANG_

[
  "&&"
  "||"
  "??"
] @keyword.operator.logical._LANG_


; The "|" in a `Foo | Bar` type annotation.
(union_type "|" @keyword.operator.type.union._LANG_)

; The "&" in a `Foo & Bar` type annotation.
(intersection_type "&" @keyword.operator.type.intersection._LANG_)

; The "?" in a `isFoo?: boolean` property type annotation.
(property_signature "?" @keyword.operator.type.optional._LANG_)
(public_field_definition "?" @keyword.operator.type.optional._LANG_)

"..." @keyword.operator.spread._LANG_
"." @keyword.operator.accessor._LANG_
"?." @keyword.operator.accessor.optional-chaining._LANG_


(ternary_expression
  ["?" ":"] @keyword.operator.ternary._LANG_)

; PUNCTUATION
; ===========

"{" @punctuation.definition.begin.bracket.curly._LANG_
"}" @punctuation.definition.end.bracket.curly._LANG_
"(" @punctuation.definition.begin.bracket.round._LANG_
")" @punctuation.definition.end.bracket.round._LANG_
"[" @punctuation.definition.begin.bracket.square._LANG_
"]" @punctuation.definition.end.bracket.square._LANG_

";" @punctuation.terminator.statement._LANG_
"," @punctuation.separator.comma._LANG_
":" @punctuation.separator.colon._LANG_


; META
; ====

; The interiors of functions (useful for snippets and commands).
(method_definition
  body: (statement_block) @meta.block.function._LANG_
  (#set! test.final true))

(function_declaration
  body: (statement_block) @meta.block.function._LANG_
  (#set! test.final true))

(generator_function_declaration
  body: (statement_block) @meta.block.function._LANG_
  (#set! test.final true))

(function
  body: (statement_block) @meta.block.function._LANG_
  (#set! test.final true))

(generator_function
  body: (statement_block) @meta.block.function._LANG_
  (#set! test.final true))

; The interior of a class body (useful for snippets and commands).
(class_body) @meta.block.class._LANG_

; All other sorts of blocks.
(statement_block) @meta.block._LANG_

; The inside of a parameter definition list.
((formal_parameters) @meta.parameters._LANG_
  (#set! adjust.startAt firstChild.endPosition)
  (#set! adjust.endAt lastChild.startPosition))

; The inside of an object literal.
((object) @meta.object._LANG_
  (#set! adjust.startAt firstChild.endPosition)
  (#set! adjust.endAt lastChild.startPosition))

; MISC
; ====

; A label. Rare, but it can be used to prefix any statement and to control
; which loop is affected in `continue` or `break` statements. Svelte uses them
; for another purpose.
(statement_identifier) @entity.name.label._LANG_
