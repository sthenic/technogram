#import "descriptions.typ": *
#import "grouped-outline.typ" as _grouped-outline
#import "palette.typ": get-palette

/* TODO: Short description + typesetting in some compact way? */

/* States */
#let register-size = state("register-size", 32)

#let _number-cells(low, high, top: true) = {
  let color = luma(240)
  let stroke = (
    left: 1pt + color,
    right: 1pt + color,
    top: if top { 1pt + color } else { none },
    bottom: if top { none } else { 1pt + color },
  )

  range(high, low - 1, step: -1).map(x => grid.cell(
    fill: color,
    stroke: stroke,
  )[#x])
}

#let _field-cells(fields, register, show-descriptions, size-bytes) = {
  let reserved = none
  let result = ()

  for byte in range(0, size-bytes) {
    let bit = 8 * byte
    let high = 8 * (byte + 1) - 1
    let row = ()

    while bit <= high {
      let match = fields.find(x => { bit >= x.pos and bit < x.pos + x.size })
      if match != none {
        if reserved != none {
          /* Reserved field ends. */
          if target() == "html" {
            row.push(html.td(colspan: reserved.size, class: "tg-reg-reserved")[\u{2013}])
          } else {
            result.push(grid.cell(colspan: reserved.size, stroke: 1pt)[`-`])
          }
          reserved = none
        }

        /* Clamp the high index at the byte limit and calculate the size of
           the slice we're about to typeset by referencing the current bit. */

        let slice-size = calc.clamp(match.pos + match.size - 1, 0, high) - bit + 1
        let slice-low = bit - match.pos
        let slice-high = slice-low + slice-size - 1
        let slice-label = raw(
          if show-descriptions { register + "::" } else { "" } + match.name + if match.size > 1 {
            if slice-high == slice-low {
              "[" + str(slice-low) + "]"
            } else {
              "[" + str(slice-high) + ":" + str(slice-low) + "]"
            }
          }
        )

        if target() == "html" {
          row.push(html.td(colspan: slice-size, class: "tg-reg-field")[#slice-label])
        } else {
          result.push(grid.cell(colspan: slice-size, stroke: 1pt)[#slice-label])
        }
        bit += slice-size
      } else if reserved != none {
        /* Extending the reserved field. */
        reserved.size += 1
        bit += 1
      } else {
        /* Starting a new reserved field. */
        reserved = (pos: bit, size: 1)
        bit += 1
      }
    }

    /* Add any reserved field trailing at the end of the byte. */
    if reserved != none {
      if target() == "html" {
        row.push(html.td(colspan: reserved.size, class: "tg-reg-reserved")[\u{2013}])
      } else {
        result.push(grid.cell(colspan: reserved.size, stroke: 1pt)[`-`])
      }
      reserved = none
    }

    /* HTML cells needs wrapping in a table row element. We need to reverse the
       order since we traversed the byte from low to high. */
    if target() == "html" {
      result.push(html.tr()[#row.rev().join()])
    }
  }

  /* Reverse the array of cells since we went through the register from low to high. */
  result.rev()
}

#let _register-descriptions(name, size-bits, fields) = {
  let last_lsb = size-bits
  let seen = ()
  for field in fields.pos().sorted(key: x => { x.pos }).rev() {
    let field-name = name + "::" + field.name
    let msb = field.pos + field.size - 1
    let lsb = field.pos

    /* The field must be unique, reside within the register and not overlap with another field. */
    if field.name in seen {
      panic("Field " + field-name + " already exists in the register.")
    }

    if msb >= size-bits or lsb < 0 {
      panic("Field " + field-name + " exceeds the bounds of the register.")
    }

    if msb >= last_lsb {
      panic("Field " + field-name + " overlaps with another field in the register.")
    }

    let field-label = [
      *Bit #if field.size > 1 [ #str(msb):#str(lsb) ] else { str(lsb) }* --- #raw(field.name)
    ]

    if field.short-description != none {
      field-label += [ --- #field.short-description]
    }

    describe([
        #field-label
        #label(field-name)
      ],
      note: field.access
    )[#field.body]

    last_lsb = lsb
    seen.push(field.name)
  }
}

#let _register-html(
  name,
  offset,
  default,
  group,
  see-also,
  show-descriptions,
  fields,
  size-bits,
  size-bytes,
  description
) = {
  let primary = get-palette().primary.to-hex()

  /* Metadata grid. */
  let meta-rows = (
    html.div(class: "tg-reg-name")[#html.span[*Name*] #html.span[#raw(name) #label(name)]],
    html.div(class: "tg-reg-offset")[#html.span[*Offset*] #html.span[#raw(offset)]],
    html.div(class: "tg-reg-default")[#html.span[*Default*] #html.span[#raw(default)]],
  )

  if group != none {
    let group-link = if query(label(group)).len() > 0 {
      link(label(group))[#group]
    } else {
      group
    }
    meta-rows.push(html.div(class: "tg-reg-group")[
      #html.span[*Group*]
      #html.span()[#group-link]
    ])
  }

  if see-also != none {
    meta-rows.push(html.div(class: "tg-reg-see-also")[
      #html.span[*See also*]
      #html.span()[#see-also.join(", ")]
    ])
  }

  let top-row = html.tr()[
    #range(size-bits - 1, size-bits - 9, step: -1).map(x =>
      html.th(class: "tg-reg-bit-num-top")[#str(x)]
    ).join()
  ]

  let bottom-row = if size-bits > 8 {
    html.tr()[
      #range(7, -1, step: -1).map(x =>
        html.th(class: "tg-reg-bit-num-bottom")[#str(x)]
      ).join()
    ]
  } else {
    none
  }

  html.div(class: "tg-reg-object")[
    #html.div(class: "tg-reg-header", style: "border-top: 3px solid " + primary + ";")[
      #html.div(class: "tg-reg-meta")[
        #meta-rows.join()
      ]
    ]
    #if description != none { html.div(class: "tg-reg-description")[#description] }
    #html.table(class: "tg-reg-bitfield")[
      #html.tbody()[
        #top-row
        #_field-cells(fields.pos(), name, show-descriptions, size-bytes).join()
        #bottom-row
      ]
    ]
    #if show-descriptions and fields.pos().len() > 0 {
      _register-descriptions(name, size-bits, fields)
    }
  ]
}

#let _register-pdf(
  name,
  offset,
  default,
  group,
  see-also,
  show-descriptions,
  fields,
  size-bits,
  size-bytes,
  description
) = {
  let see-also-cells = if see-also != none {
    (strong("See also"), see-also.join(", "))
  } else {
    none
  }

  let group-cells = if group != none {
    let label = if query(label(group)).len() > 0 {
      link(label(group))[#text(fill: text.fill)[#group]]
    } else {
      group
    }
    (strong("Group"), label)
  } else {
    none
  }

  /* This information is expected to be compact with mostly one output line per
     grid row. We use an unbreakable block to keep things together. */
  block(breakable: false)[
    #set block(spacing: 8pt)
    #line(length: 100%, stroke: 1pt + get-palette().primary)
    #grid(
      columns: (auto, 1fr),
      align: bottom,
      row-gutter: 1em,
      column-gutter: 1em,
      [*Name* #label(name)], raw(name),
      strong("Offset"), raw(offset),
      strong("Default"), raw(default),
      ..group-cells,
      ..see-also-cells
    )
  ]

  /* Add the description if defined. */
  if description != none { block[#description] }

  /* Add a two-dimensional view of the register. */
  let top-row = _number-cells(size-bits - 8, size-bits - 1, top: true)
  let bottom-row = if size-bits > 8 { _number-cells(0, 7, top: false) } else { none }

  block(breakable: false)[
    #grid(
      columns: (100% / 8,) * 8,
      align: center + horizon,
      inset: 0.5em,
      ..top-row,
      .._field-cells(fields.pos(), name, show-descriptions, size-bytes),
      ..bottom-row,
    )
  ]

  /* Add the field descriptions. */
  if show-descriptions and fields.pos().len() > 0 {
    _register-descriptions(name, size-bits, fields)
  }
}

/* Define a register */
#let register(
  name: none,
  offset: none,
  default: none,
  group: none,
  see-also: none,
  show-descriptions: true,
  ..fields,
  description,
) = context {

  if name == none { panic("A 'name' must be specified.") }
  if offset == none { panic("An 'offset' must be specified.") }
  if default == none { panic("A 'default' value must be specified.") }
  for field in fields.pos() {
    if field.name == none { panic("A field 'name' must be specified.") }
    if field.pos == none { panic("A field 'pos' (position) must be specified.") }
    if field.size == none { panic("A field 'size' must be specified.") }
  }

  /* Add entry so we can retrieve the object for the outline. */
  _grouped-outline.grouped-outline-entry(raw(name), group, "reg")

  let size-bits = register-size.get()
  let size-bytes = int(size-bits / 8)
  if size-bits != size-bytes * 8 {
    panic("The register size (" + str(size-bits) + ") must be divisible by 8.")
  }

  if target() == "html" {
    _register-html(
      name, offset, default, group, see-also, show-descriptions, fields,
      size-bits, size-bytes, description
    )
  } else {
    _register-pdf(
      name, offset, default, group, see-also, show-descriptions, fields,
      size-bits, size-bytes, description
    )
  }
}

#let field(
  name: none,
  pos: none,
  size: none,
  access: none,
  read-only: false,
  write-only: false,
  default: "0",
  short-description: none,
  body
) = {
  (
    name: name,
    pos: pos,
    size: size,
    access: if access != none {
      access
    } else if read-only [
      Read-only
    ] else if write-only [
      Write-only
    ] else { "R/W" },
    default: default,
    short-description: short-description,
    body: body
  )
}

#let outline(
  groups: none,
  show-title: true
) = _grouped-outline.grouped-outline(groups, show-title, [reg], "reg")
