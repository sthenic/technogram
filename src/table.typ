#import "palette.typ": table-fill-no-header

/* Helper function to add a class name to allow CSS targeting. */
#let _html-marker(class, body) = context if target() == "html" {
  html.span(class: class)[#body]
} else {
  body
}

#let table-section(title, columns: 1, ..body) = {
  /* We have to pad to the end of the row so that new content (regular cells or
     another section row) start on a new row as expected. */
  let cells = body.pos()
  let padding = calc.rem(columns - calc.rem(cells.len(), columns), columns)
  let cells = cells + range(padding).map(_ => [])

  let heading = table.cell(
    colspan: columns,
    align: left,
    fill: white,
    stroke: (
      top: .7pt,
      bottom: .7pt,
    ),
  )[#_html-marker("tg-table-section-heading", title)]

  let content = cells.enumerate().map(((index, cell)) => {
    let x = calc.rem(index, columns)
    let y = int(index / columns)
    let content = if x == 0 {
      /* If this is the first element, insert a HTML marker. This is a no-op for PDFs. */
      let class = "tg-table-section-row-" + if calc.even(y) { "light" } else { "shaded" }
      _html-marker(class, cell)
    } else {
      cell
    }
    table.cell(fill: table-fill-no-header(x, y))[#content]
  })

  /* Construct an array of the objects that the caller has to spread into the
     enclosing table. */
  (heading, ..content)
}
