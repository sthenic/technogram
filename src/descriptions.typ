#let describe(label, note: none, indent: 30pt, body) = {
  /* We typeset this element as two grids with one row each: one for the label
     (and note) and one for the body. This way, we can wrap the first grid in
     a sticky block to always keep it together with the body. We need the outer
     block to scope the set rule to set the spacing to zero. */
  block[
    #set block(spacing: 0pt)
    #block(sticky: true)[
      #grid(
        columns: (1fr, auto),
        align: (left, right),
        inset: (x: 0pt, y: 5pt),
        if type(label) == str { strong(label) } else { label },
        if type(note) == str { emph(note) } else { note },
      )
    ]
    #grid(
      columns: (indent, 1fr),
      inset: (x: 0pt, y: 5pt),
      [], body
    )
  ]
}
