#import "descriptions.typ": *
#import "admonitions.typ": *
#import "tree.typ": *
#import "signatures.typ": *
#import "cpp.typ" as cpp
#import "registers.typ" as reg
#import "presentation.typ": presentation
#import "document.typ": document, changelog, changelog-section, backmatter, appendix
#import "palette.typ": DEFAULT-PALETTE, update-palette, get-palette
#import "metadata.typ": get-metadata, get-metadata-value
#import "requirements.typ": requirements, req, reqcomment

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
