#let describe(label, note: none, indent: 30pt, body) = {

  /* We resort to a somewhat hacky solution to prevent a page break between the
     label row and the first line of text. We create an unbreakable block containing
     the label row and vertical spacing equal to the height of four lines of text.
     (It looks like a grid cell has some logic of its own when trying to break a cell
     across pages.) If this block gets pushed to the next page, we know the content
     wouldn't stay together like we wanted to. We follow up by undoing the vertical
     spacing and then typesetting the body.

     See https://github.com/typst/typst/issues/993 */

  grid(
    columns: (indent, 1fr, auto),
    align: (left, left, right),
    row-gutter: 0pt,
    inset: (x: 0pt, y: 5pt),
    /* Label row */
    grid.cell(colspan: 2)[
      #block(breakable: false)[
        #if type(label) == str { strong(label) } else { label }
        #v(4em)
      ]
      #v(-4em)
    ],
    if type(note) == str { emph(note) } else { note },
    /* Content row */
    [], grid.cell(colspan: 2, body),
  )
}
