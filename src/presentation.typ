#import "palette.typ": DEFAULT-PALETTE, update-palette, generate-admonition-palette
#import "common.typ": get-text-color

/* States */
#let _current-title = state("current-title", none)
#let _outline-title = state("outline-title", true)

#let _header(title: auto, logotype) = context {
  /* The page header contains the current title typeset to the left and
     optionally a logotype to the right. Since a title can potentially span
     multiple pages, we have a state to help make life easier. However, when
     we're asked to typeset the header for the first page the state has not been
     set. We resolve this by making a query looking for the next top-level
     heading. */

  let after = query(heading.where(level: 1).after(here()))
  let title-text = if _current-title.get() != none {
    _current-title.get()
  } else if after.len() > 0 {
    after.first().body.text
  } else {
    none
  }

  grid(
    columns: (auto, 1fr, auto),
    align: bottom,
    if title == auto {
      /* The title is automatically generated from the current context
         (`title-text`). Whether or not it's outline depends on if this is the
         first time we encounter the title or not. */
      [#heading(
        outlined: _outline-title.get(),
        bookmarked: _outline-title.get(),
        level: 1,
        title-text
      )<technogram-presentation-heading>]
      _outline-title.update(false)
    } else if type(title) in (content, str) {
      /* A custom title, specified as content. Not included in the outline. */
      [#heading(
        outlined: false,
        bookmarked: false,
        level: 1,
        title
      )<technogram-presentation-heading>]
    },
    none,
    logotype,
  )
}

#let _generate-palette(col) = {
  let palette = (col, col.lighten(25%), col.lighten(50%))
  palette.map(x => (background: x, text: get-text-color(x)))
}

#let _footer(document-name, classification, palette) = context {
  let palette = _generate-palette(palette.primary)
  set text(size: 50% * text.size)
  v(2.7em)
  grid(
    columns: (1fr, page.width * 25%, 1fr),
    align: (left + bottom, center + bottom, right + bottom),
    text(fill: palette.at(0).text)[#document-name],
    text(fill: palette.at(1).text)[#classification],
    text(fill: palette.at(2).text)[Page #counter(page).display("1 of 1", both: true)]
  )
}

#let _title-page(title, subtitle, author, palette, logotype) = {
  set page(header: _header(title: none, logotype))
  let author-content = if type(author) == array {
    author.join(", ", last: " and ")
  } else {
    author
  }

  align(center)[
    #v(33% - 1.4em)
    #text(weight: "bold", size: 1.4em, fill: palette.primary)[#title]\
    #v(0.3em)
    #text(weight: "bold")[#subtitle]
    #v(2em)
    #text(size: 0.8em)[
      #author-content\
      #datetime.today().display("[month repr:long] [day], [year]")
    ]
  ]
}

#let _background(palette) = context {
  let generated-palette = _generate-palette(palette.primary)
  set text(size: 50% * text.size)
  let height = 2em
  grid(
    columns: (1fr, page.width * 25%, 1fr),
    grid.cell(colspan: 3)[#rect(width: 100%, height: 100% - height, fill: palette.background)],
    rect(width: 100%, height: height, fill: generated-palette.at(0).background),
    rect(width: 100%, height: height, fill: generated-palette.at(1).background),
    rect(width: 100%, height: height, fill: generated-palette.at(2).background),
  )
}

#let _outline(logotype) = context {
  show outline: set par(leading: 0.8em, first-line-indent: 0pt)
  show outline.entry: it => { strong(it.body) }

  /* The outline is typeset on a custom page without a heading that shows up in the outline. */
  set page(columns: 2, header: _header(title: "Contents", logotype))
  outline(title: none)
}

#let presentation(
  title: none,
  subtitle: none,
  author: none,
  classification: "Public",
  url: none,
  logotype: none,
  font: "Arial",
  monofont: "Latin Modern Mono",
  fontsize: 20pt,
  palette-overrides: none,
  show-outline: false,
  body,
) = {

  /* Merge the default palette with any user overrides. */
  palette-overrides = DEFAULT-PALETTE + palette-overrides

  let document-name = title
  if subtitle != none {
    document-name += [ --- #subtitle]
  }

  /* Page */
  set page(
    paper: "presentation-16-9",
    margin: (
      left: 2cm,
      right: 2cm,
      top: 3cm,
      bottom: 2em,
    ),
    header-ascent: 1cm,
    footer-descent: 0em,
    header: _header(logotype),
    footer: _footer(document-name, classification, palette-overrides),
    background: _background(palette-overrides),
  )

  /* Paragraphs */
  set par(leading: 0.8em, first-line-indent: 15pt, justify: false)
  show par: set block(spacing: 0.8em)

  /* Fonts */
  set text(font: font, size: fontsize)
  show raw: set text(font: monofont, size: fontsize)

  /* Equations */
  set math.equation(numbering: "(1)")

  /* Links (we don't color references) */
  show link: set text(fill: palette-overrides.primary)

  /* Don't outline or bookmark the headings by default (we're going to hijack
     the syntax and move them into the slide headers). */
  set heading(outlined: false, bookmarked: false)

  _title-page(title, subtitle, author, palette-overrides, logotype)
  pagebreak()

  /* Headings --- a top-level heading begins a new slide. */
  set heading(numbering: none)
  show heading.where(level: 1): it => context {
    /* If the current title has yet to be set, we're dealing with the first one.
       Otherwise, we insert a pagebreak, but not before updating the title to
       allow the header to reflect the new title. */
    if it.at("label", default: none) == <technogram-presentation-heading> {
      it
    } else {
      let insert-pagebreak = _current-title.get() != none
      _current-title.update(it.body)
      _outline-title.update(true)
      if insert-pagebreak {
        pagebreak()
      }
    }
  }

  /* Conditionally insert the outline. */
  if show-outline {
    _outline(logotype)
  }

  /* Update the global palette and generate a matching one for admonition boxes. */
  set raw(theme: "raw.tmTheme")
  update-palette(..palette-overrides)
  generate-admonition-palette(palette-overrides.primary, palette-overrides.secondary)

  body
}
