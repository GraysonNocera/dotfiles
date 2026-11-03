; inherits: gotmpl

; Highlight the HTML surrounding the Go template actions.
;
; Mirrors how the upstream `helm` parser injects yaml into gotmpl's literal
; text: gotmpl is the root parser and the host language goes into its `(text)`
; nodes. `combined` parses all of them as a single document, so an element
; whose tags straddle a `{{ if }}` / `{{ end }}` still nests correctly.
((text) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined))
