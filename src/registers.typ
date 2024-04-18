#import "descriptions.typ": *
#import "grouped-outline.typ" as _grouped-outline

/* TODO: Short description + typesetting in some compact way? */

#let primary-color = state("primary-color", rgb("#005050"))

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

#let _field-cells(fields, register, show-descriptions) = {
  let reserved = none
  let result = ()

  /* TODO: Allow arbitrary register sizes? */

  for byte in range(0, 4) {
    let bit = 8 * byte
    let high = 8 * (byte + 1) - 1

    while bit <= high {
      let match = fields.find(x => { bit >= x.pos and bit < x.pos + x.size })
      if match != none {
        if reserved != none {
          /* Reserved field ends. */
          result.push(grid.cell(colspan: reserved.size, stroke: 1pt)[`-`])
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

        result.push(grid.cell(colspan: slice-size, stroke: 1pt)[#slice-label])
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
      result.push(grid.cell(colspan: reserved.size, stroke: 1pt)[`-`])
      reserved = none
    }
  }

  /* Reverse the array of cells since we went through the register from low to high. */
  result.rev()
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

  /* Not having these as positional arguments leads to more readable
     invocations. Ideally, the LSP could be leveraged for that but lookup of
     custom functions seems a bit shaky? */

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

  block[
    #set block(spacing: 8pt)
    #line(length: 100%, stroke: 1pt + primary-color.get())
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
  block(breakable: false)[
    #grid(
      columns: (100% / 8,) * 8,
      align: center + bottom,
      inset: 0.5em,
      .._number-cells(24, 31, top: true),
      .._field-cells(fields.pos(), name, show-descriptions),
      .._number-cells(0, 7, top: false),
    )
  ]

  /* Add the field descriptions. */
  if show-descriptions and fields.pos().len() > 0 {
    let last_lsb = 32
    let seen = ()
    for field in fields.pos().sorted(key: x => { x.pos }).rev() {
      let field-name = name + "::" + field.name
      let msb = field.pos + field.size - 1
      let lsb = field.pos

      /* The field must be unique, reside within the register and not overlap with another field. */
      if field.name in seen {
        panic("Field " + field-name + " already exists in the register.")
      }
      if msb >= 32 or lsb < 0 {
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
      /* TODO: These might be confusing... */
      #text(font: "Font Awesome 6 Free Solid", "\u{f304}")
      #box(width: -2pt)[#text(font: "Font Awesome 6 Free Solid", "\u{f715}")]
      Read-only
    ] else if write-only [
      #text(font: "Font Awesome 6 Free Solid", "\u{f070}")
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
