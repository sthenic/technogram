#import "descriptions.typ": *
#import "admonitions.typ": *
#import "tree.typ": *
#import "cpp.typ" as cpp
#import "registers.typ" as reg
#import "presentation.typ": presentation
#import "document.typ": document, changelog, changelog-section, backmatter
#import "palette.typ": DEFAULT-PALETTE, update-palette, get-palette
#import "metadata.typ": get-metadata
#import "requirements.typ": requirements, req, reqcomment

#let fixme(body) = block(text(fill: red, [*FIXME:* ] + body))
