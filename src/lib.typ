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
