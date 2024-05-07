#import "keep-with-next.typ": *

#let describe(label, note: none, indent: 30pt, body) = {
  grid(
    columns: (indent, 1fr, auto),
    align: (left, left, right),
    row-gutter: 0pt,
    inset: (x: 0pt, y: 5pt),
    /* Label row */
    grid.cell(colspan: 2)[
      /* Somewhat hacky solution to keep the label row together with the first
         line of text, see function comment. */
      #keep-with-next[
        #if type(label) == str { strong(label) } else { label }
      ]
    ],
    if type(note) == str { emph(note) } else { note },
    /* Content row */
    [], grid.cell(colspan: 2, body),
  )
}
