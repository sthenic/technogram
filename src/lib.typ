#import "descriptions.typ": *
#import "admonitions.typ": *
#import "tree.typ": *
#import "cpp.typ" as cpp
#import "registers.typ" as reg
#import "presentation.typ": presentation
#import "document.typ": document, backmatter
#import "palette.typ": DEFAULT-PALETTE, update-palette

#let fixme(body) = block(text(fill: red, [*FIXME:* ] + body))
