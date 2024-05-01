#import "common.typ": get-text-color
#import "palette.typ": palette

/* TODO: Avoid inheriting indentation w/ https://stackoverflow.com/a/78185552 */
#let admonition(
  header-color,
  body-color,
  header: none,
  symbol: none,
  gutter: 0pt,
  breakable: false,
  body
) = {
  let inset = 0.5em
  let cells = (
    if header != none {
      grid.cell(fill: header-color, colspan: 2, inset: inset)[
        /* We resort to a hacky solution to keep the header with the contents
           while still allowing the admonition box to be breakable. See comment
           in "descriptions.typ". */
        #block(breakable: false)[
          #set text(fill: get-text-color(header-color))
          #grid(
            columns: (if symbol != none { 1.5em } else { 0pt }, 1fr),
            align: bottom + left,
            if symbol != none { text(font: "Font Awesome 6 Free Solid", symbol) },
            strong(header)
          )
          #v(3em)
        ]
        #v(-3em)
      ]
    },
    grid.cell(fill: header-color)[],
    grid.cell(fill: body-color, inset: inset)[
      #set text(fill: get-text-color(body-color))
      #body
    ],
  ).filter(x => x != none)

  block(breakable: breakable)[
    #grid(
      columns: (gutter, 100% - gutter),
      ..cells
    )
  ]

  /* TODO: Wishlist: add some vertical space if a list is the last thing in the box. */
}

/* A note */
#let note(..args) = context admonition(
  palette.get().note-header,
  palette.get().note-body,
  header: "Note",
  symbol: "\u{f06a}",
  ..args
)

/* A tip */
#let tip(..args) = context admonition(
  palette.get().tip-header,
  palette.get().tip-body,
  header: "Tip",
  symbol: "\u{f06a}",
  ..args
)

/* A callout to something important */
#let important(..args) = context admonition(
  palette.get().important-header,
  palette.get().important-body,
  header: "Important",
  symbol: "\u{f06a}",
  ..args
)

/* A warning */
#let warning(..args) = context admonition(
  palette.get().warning-header,
  palette.get().warning-body,
  header: "Warning",
  symbol: "\u{f071}",
  ..args
)

/* An example */
#let example(..args) = context admonition(
  palette.get().example-header,
  palette.get().example-body,
  header: "Example",
  symbol: "\u{f02d}",
  ..args
)

/* A release */
#let release(label, ..args) = context admonition(
  palette.get().release-header,
  palette.get().release-body,
  header: "Release " + label,
  symbol: "\u{f135}",
  ..args
)

/* A display box (without header) */
#let display(..args) = context admonition(
  palette.get().display-header,
  palette.get().display-body,
  header: none,
  gutter: 2pt,
  ..args
)
