#import "palette.typ": DEFAULT-PALETTE, palette, generate-admonition-palette
#import "raw-links.typ" as _raw-links

/* A state that holds the page number where the `backmatter` starts at.
   We use this to exclude backmatter pages from the total page count. */
#let _page-before-backmatter = state("page-before-backmatter", none)

#let _margins = (
  right: 2.5cm,
  left: 2.5cm,
  top: 110pt,
  bottom: 79pt,
)

/* Header constructor */
#let _header(metadata, logotype) = grid(
  columns: (auto, 1fr, auto),
  align: top,
  logotype,
  v(42pt),
  if metadata != none {
    set text(size: 7pt)
    grid(
      columns: 2,
      gutter: 7pt,
      align: left,
      strong("Classification"), strong("Revision"),
      metadata.classification, metadata.revision,
      strong("Document ID"), strong("Date"),
      metadata.document-id, metadata.date,
    )
  },
)

/* Footer constructor (contextual) */
#let _footer(metadata) = context {
  set text(size: 9pt)
  let final-page = if _page-before-backmatter.final() != none {
    _page-before-backmatter.final()
  } else {
    counter(page).final().at(0)
  }

  grid(
    columns: (1fr, 1fr, 1fr),
    align: (left, center, right),
    grid.cell(colspan: 3)[
      #line(length: 100%, stroke: 0.5pt + black)
      #v(5pt)
    ],
    metadata.document-name,
    link(metadata.url.url)[#metadata.url.label],
    [Page #counter(page).display("1") of #final-page]
  )
}

/* Table fill pattern */
#let _table-fill = (_, y) => {
  if calc.even(y) and y > 0 { luma(240) } else { white }
}

/* Table stroke pattern */
#let _table-stroke = (x, y) => (
  left: 0pt,
  right: 0pt,
  top: if y == 0 { 1.2pt } else if y == 1 { 0.7pt } else { 0pt },
  bottom: 1.2pt,
)

#let _title-page(metadata, logotype, palette) = {
  /* Suppress the footer and remove the header metadata. */
  set page(
    header: _header(none, logotype),
    footer: none,
    margin: (.._margins, bottom: _margins.left)
  )

  /* Title and subtitle */
  set align(center + top)
  v(26%)
  text(size: 26pt, weight: "bold", fill: palette.primary)[#metadata.title]
  v(5pt)
  text(size: 16pt, weight: "bold", fill: palette.primary)[#metadata.subtitle]

  /* Helper to format the author line. */
  let format-author = {
    if type(metadata.author) == array {
      let label = if metadata.author.len() > 0 { "Authors:" } else { "Author:" }
      let author = metadata.author.join(", ", last: " and ")
      (strong(label), author)
    } else if type(metadata.author) == str {
      (strong("Author:"), metadata.author)
    }
  }

  /* Metadata typeset in the bottom left corner. */
  set align(left + bottom)
  grid(
    columns: 2,
    row-gutter: 7pt,
    column-gutter: 15pt,
    align: left,
    ..format-author,
    strong("Document ID:"), metadata.document-id,
    strong("Classification:"), metadata.classification,
    strong("Revision:"), metadata.revision,
    strong("Date:"), metadata.date,
  )
}

/* Outline with custom styling applied in a scope so as not to affect other outlines. */
#let _outline() = {
  // TODO: The spacing between the heading number and the label is rather small but fine
  //       with a space at the end in heading.numbering, acceptable workaround?
  set outline(indent: auto)
  show outline: set par(leading: 0.8em, first-line-indent: 0pt)

  // From https://stackoverflow.com/questions/77031078/how-to-remove-numbers-from-outline
  show outline.entry: it => {
    if it.at("label", default: none) == <technogram-outline-entry> {
      it
    } else {
      let fill = if it.level > 1 { repeat[#h(3pt).#h(3pt)] } else []

      let body = if it.level == 1 {
        v(20pt, weak: true)
        strong(it.body)
      } else {
        it.body
      }

      let page = if it.level == 1 {
        strong(it.page)
      } else {
        it.page
      }

      [#outline.entry(
        it.level,
        it.element,
        body,
        fill,
        page
      )<technogram-outline-entry>]
    }
  }

  outline()
}

#let document(
  title: none,
  subtitle: none,
  document-name: none,
  author: none,
  classification: "Public",
  revision: none,
  document-id: none,
  date: datetime.today().display(),
  url: none,
  logotype: none,
  show-title-page: true,
  show-outline: true,
  font: "Linux Libertine",
  monofont: "Latin Modern Mono",
  fontsize: 10pt,
  palette-overrides: none,
  body,
) = {

  /* Merge the default palette with any user override. */
  palette-overrides = DEFAULT-PALETTE + palette-overrides

  /* Attempt to read the revision from the command line parameters. */
  if revision == none {
    revision = sys.inputs.at("revision", default: none)
    /* TODO: Error if still none? */
  }

  /* Construct the document name. */
  if document-name == none and title != none {
    document-name = title
    if subtitle != none {
      document-name += [ --- #subtitle]
    }
  }

  /* Pack a metadata dictionary for to pass to typesetting functions. */
  let metadata = (
    title: title,
    subtitle: subtitle,
    document-name: document-name,
    author: author,
    classification: classification,
    revision: revision,
    document-id: document-id,
    date: date,
    url: url,
  )

  /* Page */
  set page(
    paper: "a4",
    margin: _margins,
    header: _header(metadata, logotype),
    footer: _footer(metadata),
    header-ascent: 24pt,
    footer-descent: 12pt,
  )

  /* Paragraphs */
  set par(leading: 0.7em, first-line-indent: 15pt, justify: true)
  show par: set block(spacing: 0.7em)

  /* Fonts */
  set text(font: font, size: fontsize)
  show raw: set text(font: monofont, size: fontsize)

  /* Sections */
  set heading(numbering: "1.1  ")
  show heading: set block(above: 2.4em, below: 1.4em)

  /* Equations */
  set math.equation(numbering: "(1)")

  /* Links (we don't color references) */
  show link: set text(fill: palette-overrides.primary)

  /* Tables */
  show table.cell.where(y: 0): strong
  set table(fill: _table-fill, stroke: _table-stroke, align: left)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set block(inset: (left: 5%, right: 5%))

  /* Lists */
  set list(indent: 1.5em, body-indent: 1em)
  set enum(indent: 1.5em, body-indent: 1em, number-align: start + top)

  /* We only want the first level of a list to be indented so we have a global
     show rule to make it so the objects are created with a nonzero indentation.
     Then, once the show rules below are invoked, we change the indentation to
     zero. This works (I think) because nested lists specified with the markdown
     syntax do not create list objects until they are encountered when walking
     through the top level items. */

  show list: it => {
    set list(indent: 0pt)
    it
  }

  show enum: it => {
    set enum(indent: 0pt)
    it
  }

  /* Hook to pass raw content through the function library. */
  show raw: it => { _raw-links.format-raw(it) }
  show raw.line: it => { _raw-links.format-raw-line(it) }

  /* Conditionally insert the title page. */
  if show-title-page {
    _title-page(metadata, logotype, palette-overrides)
    counter(page).update(1)
  }

  /* Conditionally insert the outline and a pagebreak. */
  if show-outline {
    _outline()
    pagebreak()
  }

  /* Update the global palette and generate a matching one for admonition boxes. */
  set raw(theme: "raw.tmTheme")
  palette.update(palette-overrides)
  generate-admonition-palette(palette-overrides.primary, palette-overrides.secondary)

  /* FIXME: Probably need referenceable enumeration items with https://gist.github.com/PgBiel/23a116de4a235ad4cf6c7a05d6648ca9 */

  body
}

/* Insert unnumbered pages w/o header and footer at the end of the document. */
#let backmatter(logotype: none, footer: none, body) = {
  context _page-before-backmatter.update(counter(page).get().at(0))
  set page(footer: footer, header: _header(none, logotype), numbering: none)
  body
}