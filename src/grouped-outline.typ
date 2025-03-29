/* We use a figure (taking up no space on the page) to place an outlineable item
   so that we can construct a custom outline later on. We set the kind based on
   the group and the supplement to something that all objects will have in
   common. That way, we can filter by groups and also look up all elements and
   later sort them by their groups. */

/* From https://github.com/typst/typst/discussions/2681 */

#let grouped-outline-entry(
  caption,
  group,
  default-group,
) = hide(box(height: 0pt, figure(
  none,
  kind: if group != none { group } else { default-group },
  supplement: default-group,
  caption: caption,
  outlined: true,
)))

/* Insert a grouped outline, optionally filtering on a list of groups. */
#let grouped-outline(
  groups,
  show-title,
  supplement,
  default-group,
) = context {
  /* Custom outline entry to remove the supplement (prefix). */
  set outline.entry(fill: repeat[#h(3pt).#h(3pt)])
  show outline.entry: it => {
    it.indented(none, it.inner())
  }

  /* Determine which object groups to include in the outline. */
  let outline-groups = if groups != none {
    groups
  } else {
    /* Put the objects without a group first. */
    let result = ()
    result.push(default-group)
    /* Query by the supplement and push unique entries using the `kind` field. */
    for it in query(figure.where(supplement: supplement)) {
      if it.kind not in result {
        result.push(it.kind)
      }
    }
    result
  }

  for group in outline-groups {
    if outline-groups.len() > 0 {
      /* Don't place a heading for the default group or if disabled altogether. */
      if show-title and group != default-group {
        /* Attempt to locate the page of any label with the same name as the group.
           We have to gate behind a `query` because `locate` must be successful. */
        v(1.2em, weak: true)
        let (label, page) = if query(label(group)).len() > 0 {
          let location = locate(label(group))
          (link(location)[#text(weight: "bold", fill: text.fill)[#group]], strong[#location.page()])
        } else {
          (strong(group), none)
        }

        /* We keep the heading together with the first entry. */
        block(sticky: true)[
          #grid(
            columns: (auto, 1fr),
            align: (left, right),
            label, page
          )
        ]
      }
    }

    outline(
      title: none,
      target: figure.where(kind: group)
    )
  }
}
