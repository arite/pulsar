
; JSX
; ===

; The "Foo" in `<Foo />`.
(jsx_self_closing_element
  name: (identifier) @entity.name.tag.ts.tsx
  ) @meta.tag.ts.tsx

; The "Foo" in `<Foo>`.
(jsx_opening_element
  name: (identifier) @entity.name.tag.ts.tsx)

; The "Foo" in `</Foo>`.
(jsx_closing_element
  "/" @punctuation.definition.tag.end.ts.tsx
  (#set! test.final true)
  name: (identifier) @entity.name.tag.ts.tsx)

; The "bar" in `<Foo bar={true} />`.
(jsx_attribute
  (property_identifier) @entity.other.attribute-name.ts.tsx)

; All JSX expressions/interpolations within braces.
((jsx_expression) @meta.embedded.block.ts.tsx
  (#match? @meta.embedded.block.ts.tsx "\\n")
  (#set! test.final true))

(jsx_expression) @meta.embedded.line.ts.tsx

(jsx_self_closing_element
  "<" @punctuation.definition.tag.begin.ts.tsx
  (#set! test.final true))

((jsx_self_closing_element
  ; The "/>" in `<Foo />`, extended to cover both anonymous nodes at once.
  "/") @punctuation.definition.tag.end.ts.tsx
  (#set! adjust.startAt lastChild.previousSibling.startPosition)
  (#set! adjust.endAt lastChild.endPosition)
  (#set! test.final true))
