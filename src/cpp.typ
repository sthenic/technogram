#import "descriptions.typ": *
#import "grouped-outline.typ" as _grouped-outline
#import "palette.typ": get-palette

/* Typeset the description of a subobject using the describe environment. */
#let _subobject_description(subobject, label-prefix: "") = {
  describe([
      #raw(subobject.name + subobject.dimension + " (" + subobject.type + ")", lang: "cpp")
      #label(label-prefix + subobject.name)
    ],
    note: subobject.note
  )[#subobject.body]
}

/* A function parameter. */
#let _parameter(parameter, prefix: "", last: false) = {
  (none, grid.cell(colspan: 2)[
    #raw(parameter.type + " " +
         prefix + parameter.name + parameter.dimension +
         if not last { "," }, lang: "cpp")
  ])
}

/* A struct member. */
#let _member(member, prefix: "") = {
  (none, grid.cell(colspan: 2)[
    #raw(member.type + " " + prefix + member.name + member.dimension + ";", lang: "cpp")
  ])
}

/* An enumeration. */
#let _enumeration(enumeration, last: false) = {
  (none, grid.cell(colspan: 2)[
    #raw(enumeration.name + " = " + enumeration.type + if not last { "," }, lang: "cpp")
  ])
}

/* Define an object (function, struct, enumeration or define). */
#let _object(
  name: none,
  type: none,
  returns: none,
  note: none,
  short-description: none,
  see-also: none,
  value: none,
  group: none,
  show-descriptions: true,
  breakable: false,
  ..subobjects,
  description,
) = context {
  let is-struct = type == "struct"
  let is-enum = type == "enum"
  let is-define = type == "define"

  /* Not having these as positional arguments leads to more readable
     invocations. Ideally, the LSP could be leveraged for that but lookup of
     custom functions seems a bit shaky? */

  if name == none { panic("A 'name' must be specified.") }
  if type == none { panic("A 'type' must be specified.") }

  let seen = ()
  for subobject in subobjects.pos() {
    if subobject.name in seen {
      panic(name + "::" + subobject.name + " is already defined.")
    }
    seen.push(subobject.name)
  }

  /* We change the typesetting of subobjects depending on the object type. */
  let rows = subobjects.pos().enumerate().map(((i, x)) => {
    let prefix = if show-descriptions { name + "::" } else { none }
    if is-struct {
      _member(x, prefix: prefix)
    } else if is-enum {
      _enumeration(x, last: i == subobjects.pos().len() - 1)
    } else {
      _parameter(x, prefix: prefix, last: i == subobjects.pos().len() - 1)
    }
  }).join()

  /* Determine the opening and closing symbols depending on the object type and
     whether or not we have collected any subobjects. */
  let (opening-symbol, closing-symbol) = {
    if is-struct or is-enum {
      if subobjects.pos().len() > 0 {
        (" {", `}`)
      } else {
        (" {}", none)
      }
    } else if is-define {
      (" " + value, none)
    } else {
      if subobjects.pos().len() > 0 {
        ("(", `)`)
      } else {
        ("()", none)
      }
    }
  }

  /* Add entry so we can retrieve the object for the outline. */
  _grouped-outline.grouped-outline-entry(raw(name), group, "cpp")

  let opening-text = if is-define { "#" } else { "" } + type + " " + name + opening-symbol
  block(breakable: breakable)[
    #set block(spacing: 8pt)
    #line(length: 100%, stroke: 1pt + get-palette().primary)
    #grid(
      columns: (20pt, 1fr, auto),
      align: left + bottom,
      row-gutter: 6pt,
      /* The opening row. */
      grid.cell(colspan: 2)[
        #raw(opening-text, lang: "cpp")
        #label(name)
      ],
      grid.cell(align: right + bottom)[#note],
      /* Spread the rows into the grid. */
      ..rows,
      /* The closing row. */
      closing-symbol
    )
  ]

  /* Insert the short description if any. */
  if short-description != none {
    block[#emph[#short-description]]
  }

  /* Return value content with a heading that's not included in the outline. */
  if returns != none {
    heading(level: 3, numbering: none, outlined: false)[Return value]
    block[#returns]
  }

  /* Insert references to related objects. */
  if see-also != none {
    heading(level: 3, numbering: none, outlined: false)[See also]
    block[#see-also.join(", ")]
  }

  /* Long description content if not empty. */
  if description != [] {
    heading(level: 3, numbering: none, outlined: false)[Description]
    block[#description]
  }

  /* Subobject descriptions. */
  if show-descriptions and subobjects.pos().len() > 0 {
    heading(level: 3, numbering: none, outlined: false)[
      #if is-struct [Members] else if is-enum [Values] else [Parameters]
    ]

    subobjects.pos().map(x => { _subobject_description(x, label-prefix: if is-enum { "" } else { name + "::" }) }).join()
  }
}

/* Add documentation for a function. */
#let function(
  name: none,
  type: none,
  returns: none,
  note: none,
  short-description: none,
  see-also: none,
  group: none,
  thread-safe: false,
  show-descriptions: true,
  breakable: false,
  ..parameters,
  description,
) = _object(
  name: name,
  type: type,
  returns: returns,
  note: if note != none { note } else if thread-safe [
    #text(font: "Font Awesome 6 Free Solid", "\u{f074}")
    Thread-safe
  ] else { none },
  short-description: short-description,
  see-also: see-also,
  value: none,
  group: group,
  show-descriptions: show-descriptions,
  breakable: breakable,
  ..parameters,
  description,
)

/* Define a function parameter. This is the subobject type of `function`. */
#let parameter(
  name: none,
  type: none,
  dimension: none,
  note: none,
  body,
) = {
  if name == none { panic("A parameter 'name' must be specified.") }
  if type == none { panic("A parameter 'type' must be specified.") }
  (name: name, type: type, dimension: dimension, note: note, body: body)
}

/* Add documentation for a struct. */
#let struct(
  name: none,
  note: none,
  short-description: none,
  see-also: none,
  group: none,
  show-descriptions: true,
  breakable: false,
  ..members,
  description,
) = _object(
  name: name,
  type: "struct",
  returns: none,
  note: note,
  short-description: short-description,
  see-also: see-also,
  value: none,
  group: group,
  show-descriptions: show-descriptions,
  breakable: breakable,
  ..members,
  description,
)

/* Define a struct member. This is the subobject type of `struct`. */
#let member(
  name: none,
  type: none,
  dimension: none,
  note: none,
  body,
) = {
  if name == none { panic("A member 'name' must be specified.") }
  if type == none { panic("A member 'type' must be specified.") }
  (name: name, type: type, dimension: dimension, note: note, body: body)
}

/* Add documentation for an enumeration. */
#let enumeration(
  name: none,
  note: none,
  short-description: none,
  see-also: none,
  group: none,
  show-descriptions: true,
  breakable: false,
  ..values,
  description,
) = _object(
  name: name,
  type: "enum",
  returns: none,
  note: note,
  short-description: short-description,
  see-also: see-also,
  value: none,
  group: group,
  show-descriptions: show-descriptions,
  breakable: breakable,
  ..values,
  description,
)

/* Define an enumeration value. This is the subobject type of `enumeration`. */
#let value(
  name: none,
  value: none,
  note: none,
  body,
) = {
  if name == none { panic("A value 'name' must be specified.") }
  (name: name, type: value, dimension: none, note: note, body: body)
}

/* Add documentation for a define. */
#let define(
  name: none,
  value: none,
  note: none,
  see-also: none,
  group: none,
  description,
) = _object(
  name: name,
  type: "define",
  returns: none,
  note: note,
  short-description: none,
  see-also: see-also,
  value: value,
  group: group,
  show-descriptions: false,
  breakable: false,
  description,
)

#let outline(
  groups: none,
  show-title: true
) = _grouped-outline.grouped-outline(groups, show-title, [cpp], "cpp")
