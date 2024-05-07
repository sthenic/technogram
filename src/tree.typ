#let tree-stroke = state("tree-stroke", 1pt + black)
#let tree-depth = state("tree-depth", 20pt)

/* Insert a tree. The nodes are ideally defined using the "tight" list syntax. */
#let tree(breakable: true, body) = context {
  let line-height = measure("M").height
  let indent = 0pt /* TODO: Dynamically set this somehow? */
  let row-gutter = par.leading * 150%
  let column-gutter = tree-depth.get() * 30%
  let stroke = tree-stroke.get()

  /* The symbol (├─) marking any entry but the last on a level. */
  let branch = ([], grid.cell(align: top, stroke: (left: stroke))[
    #rect(width: 100% - column-gutter, height: line-height / 2, stroke: (bottom: stroke))[]
  ])

  /* The symbol (└─) marking the final entry on a level. */
  let cap = ([], grid.cell(align: top)[
    #rect(width: 100% - column-gutter, height: line-height / 2, stroke: (left: stroke, bottom: stroke))[]
  ])

  /* A grid cell with a stroke on the left to wrap a lower level of the tree. */
  let pipe = ([], grid.cell(stroke: (left: stroke))[])

  /* Padding rows. The padding for the first item on a new level does not include a line. */
  let pad-first = ([], grid.cell(colspan: 2)[#v(row-gutter)])
  let pad-other = ([], grid.cell(stroke: (left: stroke), colspan: 2)[#v(row-gutter)])

  let _tree(content, is-first, is-last) = {

    /* Construct the grid cells of this level. We have to exempt content types
       which have `children` but which we should still consider as a whole. This
       is the `grid` type for now. */

    /* TODO: Is there a better way of doing this rather than exempting
             everything by hand? */

    let body = content.body
    let cells = if body.has("children") and body.func() != grid {
      let result = ()

      /* Rip out all content that's not descending into another list. We
         completely ignore paragraph breaks to support the "loose" list markdown
         syntax too (list items separated w/ blank lines). */

      let filtered = body.children.filter(x => x.func() != parbreak)
      let content-on-this-level = [#while filtered.len() > 0 and filtered.at(0).func() != list.item {
        filtered.remove(0)
      }]

      result.push(if is-first { pad-first } else { pad-other })
      result.push(if is-last { cap } else { branch })
      result.push(content-on-this-level)

      if filtered.len() != 0 {
        filtered = filtered.filter(x => x != [ ])
        let last = filtered.pop()
        for (i, it) in filtered.enumerate() {
          result.push(if is-last { ([], []) } else { pipe })
          result.push(_tree(it, i == 0, false))
        }
        result.push(if is-last { ([], []) } else { pipe })
        result.push(_tree(last, filtered.len() == 0, true))
      }

      result.flatten()
    } else {
      let result = ()
      result.push(if is-first { pad-first } else { pad-other })
      result.push(if is-last { cap } else { branch })
      result.push(body)
      result.flatten()
    }

    /* Spread the cells into a grid with three columns. The first one is the
       indent level, the second holds the tree outline and the third holds the
       contents.  */

    grid(
      columns: (indent, tree-depth.get(), 1fr),
      align: top,
      ..cells
    )
  }

  /* Rip out all top-level content that's not part of the list. This will be our root node. */
  let filtered = body.children.filter(x => x.func() != parbreak)
  let content-on-this-level = [#while filtered.len() > 0 and filtered.at(0).func() != list.item {
    filtered.remove(0)
  }]

  /* We wrap everything in a block to allow the user to choose whether the tree
     is breakable or not.  */
  block(breakable: breakable, {
    set block(spacing: 0pt)
    block[#content-on-this-level]

    let filtered = filtered.filter(x => x != [ ])
    let last = filtered.pop()

    for (i, it) in filtered.enumerate() {
      _tree(it, i == 0, false)
    }
    _tree(last, filtered.len() == 0, true)
  })
}

/* Convenience function for a grid with cells equal in size that number as many
   as there are positional arguments. All of these grid properties can be
   overridden by supplying named arguments. The idea is to provide "sane
   defaults" to a grid object that may be used as a tree item, e.g. to create an
   annotation to the right of the leaf text. */
#let tree-span(..any) = {
  grid(
    columns: (1fr,) * any.pos().len(),
    gutter: 1em,
    ..any
  )
}
