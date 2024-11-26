#import "to-string.typ": *

/* Hook to replace references of kind 'requirement' with custom text. */
#let format-reference(it) = {
  if it.element != none and it.element.has("kind") and it.element.kind == "requirement" {
    link(it.target, it.element.caption.body)
  } else {
    it
  }
}

/* Add a set of requirements with the same prefix, e.g. '3.4'. */
#let requirements(
  prefix: none,
  release: none,
  ..reqs,
) = {
  let cells = ()
  let prefix = [REQ #prefix] + if prefix != none [.]

  for req in reqs.pos() {
    let title = prefix + [#req.number]
    cells.push(grid.cell(breakable: false)[
      /* Hidden figure with special 'kind' to create an achor point for future references. */
      #hide(place[#figure(
        none,
        kind: "requirement",
        supplement: none,
        caption: title,
        outlined: true,
      )#if req.label != none { label(req.label) }])
      #text(size: 0.8em, style: "italic")[#title]
    ])
    cells.push(grid.cell(breakable: true, req.body))
  }

  block(above: 2em, below: 2em, grid(
    columns: (50pt, auto),
    column-gutter: 0.5em,
    row-gutter: 1.5em,
    ..cells,
  ))
}

/* Add a requirement. */
#let req(
  number,
  label: none,
  body,
) = {
  (
    number: number,
    label: label,
    body: body,
  )
}

/* Add a requirement comment as a separate block with emphasized text. */
#let reqcomment(body) = {
  block(above: 1.5em, below: 1.5em, emph(body))
}

/* Hook to check for duplicate requirements (ideally once at the end). */
#let check-for-duplicates() = context {
  let seen = ()
  for it in query(figure.where(kind: "requirement")) {
    let body = to-string(it.caption.body)
    if body in seen {
      panic(body + " is already defined.")
    } else {
      seen.push(body)
    }
  }
}
