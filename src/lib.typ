#import "descriptions.typ": *
#import "admonitions.typ": *
#import "tree.typ": *
#import "signatures.typ": *
#import "cpp.typ" as cpp
#import "registers.typ" as reg
#import "presentation.typ": presentation
#import "document.typ": document, changelog, changelog-section, backmatter, appendix
#import "palette.typ": DEFAULT-PALETTE, update-palette, get-palette, table-stroke-no-top-rule
#import "metadata.typ": get-metadata, get-metadata-value
#import "requirements.typ": requirements, req, reqcomment
#import "subfigure.typ": subfigure

#let fixme(body) = block(text(fill: red, [*FIXME:* ] + body))

#let center-block(..args) = {
  context if target() == "html" {
    html.div(class: "tg-centered")[#args.pos().join()]
  } else {
    block(width: 100%, ..args.named())[
      #set align(center)
      #args.pos().join()
    ]
  }
}

#let flipped-page(flip-captions: false, body) = {
  context if target() == "html" {
    /* Tables typeset on a flipped page gets a special container div to allow
       special handling in the CSS. */
    show table: it => {
      html.div(class: "tg-wide-table")[#it]
    }
    body
  } else {
    set page(flipped: true)
    /* Hook into the figure command to control the rendering on a flipped page. */
    show figure: it => {
      if flip-captions {
        grid(
          columns: (auto, 1fr),
          rotate(90deg, reflow: true)[#it.caption],
          it.body
        )
      } else {
        it
      }
    }
    body
  }
}

#let rotated-cell(angle: -35deg, inset: 4pt, min-width: none, body) = table.cell(
  align: left + bottom
)[
  #let rotated-content = rotate(angle, reflow: true, body)
  #context if target() == "html" {
    /* Size-hinting for columns. */
    let min-width = if min-width == none {
      0pt
    } else if type(min-width) == content {
      measure(min-width).width
    } else {
      min-width
    }

    html.span(
      class: "tg-rotated-cell",
      style: (
        "--tg-rotated-cell-angle: " + repr(angle) + ";" +
        "--tg-rotated-cell-inset: " + repr(inset) + ";" +
        "--tg-rotated-cell-height: " + repr(2.0 * measure(rotated-content).height) + ";" +
        "--tg-rotated-cell-min-width: " + repr(min-width) + ";" +
        "--tg-rotated-cell-shift: " + repr(0.7em) + ";"
      )
    )[
      #html.span(class: "tg-rotated-cell-label")[#body]
    ]
  } else {
    box(
      rotated-content,
      width: measure(rotated-content).width,
      inset: (bottom: inset)
    )
  }
]
