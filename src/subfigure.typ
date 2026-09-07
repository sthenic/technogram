#let _subfigure-counter = counter(figure.where(kind: "subfigure"))

/* Helper function to render content (figures) within a subfigure grid. */
#let _subfigure-rules(body) = {
  set figure(
    kind: "subfigure",
    supplement: none,
    numbering: "(a)",
    outlined: false,
  )
  set figure.caption(separator: none)
  _subfigure-counter.update(0)
  body
}

#let _grid-columns-to-css(tracks) = {
  if type(tracks) == int {
    "repeat(" + str(tracks) + ", auto)"
  } else if type(tracks) == array {
    tracks.map(repr).join(" ")
  } else {
    repr(tracks)
  }
}

/* Normalize the list of items in which figure objects can optionally be
   followed by a label which should attach to it. When we find such a pair, we
   join them in a content value so that the label attaches properly. */
#let _normalize-items(..items) = {
  let result = ()
  for item in items.pos() {
    if type(item) == label {
      if result.len() == 0 or result.last().func() != figure {
        panic("A subfigure label must follow a figure.")
      }
      let figure = result.pop()
      result.push([#figure #item])
    } else if item.func() == figure {
      result.push(item)
    } else {
      panic("A subfigure must only consist of figures and labels.")
    }
  }
  result
}

#let _subfigure-html(
  gutter,
  columns,
  ..items,
) = {
  let style = (
    "--tg-subfigure-columns:" + _grid-columns-to-css(columns) + ";" +
    "--tg-subfigure-gutter:" + repr(gutter) + ";"
  )
  _subfigure-rules[
    /* We have to adjust the caption rule manually to get the numbering alone
       since setting `supplement: none` disables the automatic prefix. */
    #show figure.caption: it => html.figcaption[
      #context numbering(it.numbering, it.counter.get().first()) #it.body
    ]
    #html.div(class: "tg-subfigure-grid", style: style)[
      #for child in _normalize-items(..items) {
        html.div(class: "tg-subfigure-item")[#child]
      }
    ]
  ]
}

#let _subfigure-pdf(
  gutter,
  columns,
  ..items,
) = {
  _subfigure-rules[
    #show figure: set block(above: 0pt, below: 0pt)
    #grid(
      columns: columns,
      gutter: gutter,
      .._normalize-items(..items),
    )
  ]
}

/* Custom formatter keyed by the referenced figure kind. */
#let reference-formatters = (
  subfigure: it => context {
    /* References to subfigures have to be handled as a special case. They
       inherit the customization of the enclosing figure. */
    let enclosing-figure = query(figure.where(kind: image).before(it.element.location())).last()

    /* With custom style rules defined by the user, the supplement may be a
       function taking a referenced element. We get the supplement by passing
       the enclosing figure to hide the internal subfigure structure. */
    let supplement = if type(it.supplement) == function {
      (it.supplement)(enclosing-figure)
    } else {
      it.supplement
    }

    /* The typeset reference prefixes the subfigure counter with the label from
       the enclosing figure. */
    let figure-number = counter(figure.where(kind: image)).at(it.target).first()
    let subfigure-number = _subfigure-counter.at(it.target).first()
    [#supplement #link(it.target)[#numbering("1", figure-number)#numbering("a", subfigure-number)]]
  },
)

#let subfigure(
  caption: none,
  gutter: 1em,
  columns: 1fr,
  ..items,
) = {
  /* The outer object is a regular figure to allow the caller to attach a label
     like usual, i.e. subfigure(...) <fig:my-figure> */
  figure(
    kind: image,
    caption: caption,
    context if target() == "html" {
      _subfigure-html(gutter, columns, ..items)
    } else {
      _subfigure-pdf(gutter, columns, ..items)
    }
  )
}
