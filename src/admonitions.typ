/* A function to get text color (white/black) that's appropriate for the background. */
/* See https://stackoverflow.com/a/3943023 */
#let _get-text-color(color) = {
  let (red, green, blue) = rgb(color).components(alpha: false)
  if red * 29.9% + green * 58.7% + blue * 11.4% > 73% {
    black
  } else {
    white
  }
}

/* TODO: Avoid inheriting indentation w/ https://stackoverflow.com/a/78185552 */
#let admonition(colors, header: none, symbol: none, gutter: 0pt, breakable: false, body) = {
  block(breakable: breakable)[
    #set block(spacing: 0pt)
    #if header != none {
      /* We resort to a hacky solution to keep the header with the contents while still allowing
         the admonition box to be breakable. See comment in "descriptions.typ". */
      block(breakable: false)[
        /* A grid within a rect is better than colored grid boxes (renders edges between the cells). */
        #rect(fill: colors.header, inset: 0.5em, width: 100%)[
          #grid(
            columns: (if symbol != none { 1.5em } else { 0pt }, 1fr),
            align: bottom + left,
            if symbol != none {
              text(fill: _get-text-color(colors.header), font: "Font Awesome 6 Free Solid", symbol)
            },
            text(fill: _get-text-color(colors.header), weight: "bold", header),
          )
        ]
        #v(3em)
      ]
      v(-3em)
    }
    #grid(
      columns: (gutter, 100% - gutter),
      grid.cell(fill: colors.header)[],
      grid.cell(fill: colors.content, inset: 0.5em)[#text(fill: _get-text-color(colors.content), body)]
    )
  ]
}

/* A note */
#let note-color = state("note-color", (header: rgb("#005050"), content: rgb("#D2E6E6")))
#let note(..args, body) = context admonition(
  note-color.get(), header: "Note", symbol: "\u{f06a}", ..args, body
)

/* A tip */
#let tip-color = state("tip-color", (header: rgb("#005050"), content: rgb("#D2E6E6")))
#let tip(..args, body) = context admonition(
  tip-color.get(), header: "Tip", symbol: "\u{f06a}", ..args, body
)

/* A callout to something important */
#let important-color = state("important-color", (header: rgb("#BF2629"), content: rgb("#FDF3F2")))
#let important(..args, body) = context admonition(
  important-color.get(), header: "Important", symbol: "\u{f06a}", ..args, body
)

/* A warning */
#let warning-color = state("warning-color", (header: rgb("#E97211"), content: rgb("#FFEFE1")))
#let warning(..args, body) = context admonition(
  warning-color.get(), header: "Warning", symbol: "\u{f071}", ..args, body
)

/* An example */
#let example-color = state("example-color", (header: rgb("#005050"), content: rgb("#D2E6E6")))
#let example(..args, body) = context admonition(
  example-color.get(), header: "Example", symbol: "\u{f02d}", ..args, body
)

/* A release */
#let release-color = state("release-color", (header: rgb("#005050"), content: rgb("#D2E6E6")))
#let release(label, ..args, body) = context admonition(
  release-color.get(), header: "Release " + label, symbol: "\u{f135}", ..args, body
)

/* A display box (without header) */
#let display-color = state("display-color", (header: rgb("#005050"), content: luma(240)))
#let display(..args, body) = context admonition(
  display-color.get(), header: none, gutter: 2pt, ..args, body
)
