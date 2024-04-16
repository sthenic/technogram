/* Return content where any markers in the `text` have been replaced with link
   objects. If no markers exist, `default` is returned. */
#let _markers-to-links(text, default) = {
  let matches = text.matches(regex("jdztDE(\w+?)zRVeVY"))
  if matches.len() > 0 {
    let content = []
    let index = 0

    for match in matches {
      if index < match.start {
        content += text.slice(index, match.start)
      }

      let link-text = match.text
        .replace("jdztDE", "")
        .replace("IbXRuT", "::")
        .replace("zRVeVY", "")

      /* Insert "zero-valued" whitespace at reasonable locations (Pascal and
         snake case separators) to encourage discretionary breaks. */
      let insert-discretionary-breaks(text) = {
        text
          .replace(regex("[a-z][A-Z]"), x => { x.text.at(0) + sym.zws + x.text.at(1) })
          .replace("_", "_" + sym.zws)
      }

      let split = link-text.split("::")
      if split.len() > 1 {
        content += link(label(link-text), insert-discretionary-breaks(split.at(1)))
      } else {
        content += link(label(link-text), insert-discretionary-breaks(link-text))
      }

      index = match.end
    }

    /* Copy any remainder */
    if index < text.len() {
      content += text.slice(index)
    }

    content
  } else {
    default
  }
}

/* Hook into `raw` to replace special matching text with custom markers. */
#let format-raw(it) = {
  if it.at("label", default: none) == <technogram-modified-raw> {
    it
  } else {

    /* Check for identifiers and scoped parameters with a matching link in the
       document. These get marked with a set of random letters to preserve the
       identifier through the syntax highlighting stage (mostly affects `::`).
       We have to be careful to only consider unique replacements because the
       same term may occur multiple times within the text. Moreover, we have to
       do this in two phases since the first part of a scoped link is a linkable
       object on its own but, when followed by `::`, should be considered
       together with the next part. Ideally, we would be able to do the
       replacement using a regex with negative look-ahead assertion for `::`,
       but instead we'll have to undo the marker wrapping when we get a match in
       phase two. */

    let text-with-markers = it.text
    let seen = ()
    for match in text-with-markers.matches(regex("\w+")) {
      if query(label(match.text)).len() > 0 and match.text not in seen {
        text-with-markers = text-with-markers
          .replace(match.text, "jdztDE" + match.text + "zRVeVY")
        seen.push(match.text)
      }
    }

    for match in text-with-markers.matches(regex("\w+::\w+")) {
      let text = match.text
        .replace("jdztDE", "")
        .replace("zRVeVY", "")

      if query(label(text)).len() > 0 and text not in seen {
        text-with-markers = text-with-markers
          .replace(match.text, "jdztDE" + text.replace("::", "IbXRuT") + "zRVeVY")
        seen.push(text)
      }
    }

    [#raw(
      text-with-markers,
      block: it.block,
      lang: it.lang,
      align: it.align,
      tab-size: it.tab-size,
    )<technogram-modified-raw>]
  }
}

/* Hook into `raw.line` to replace custom markers with links. */
#let format-raw-line(it) = {
  /* TODO: Only do this for lang c/cpp? */
  if it.at("label", default: none) == <technogram-modified-raw-line> {
    it
  } else {
    let content = []
    if it.body.has("children") {
      /* Array of content */
      for c in it.body.children {
        if c.has("child") {
          content += _markers-to-links(c.child.text, c)
        } else if c.has("text") {
          content += _markers-to-links(c.text, c)
        } else {
          content += c
        }
      }
    } else if it.body.has("text") {
      /* Simple text */
      content += _markers-to-links(it.body.text, it.body)
    } else {
      content += it.body
    }

    [#raw.line(
      it.number,
      it.count,
      it.text,
      content,
    )<technogram-modified-raw-line>]
  }
}
