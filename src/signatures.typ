#let signature(layout: none, ..labels) = {
  v(5em)
  grid(
    columns: if layout != none { layout } else { labels.pos().len() * (1fr,) },
    stroke: (top: .5pt),
    gutter: 2em,
    inset: (top: 1em),
    ..labels
  )
}
