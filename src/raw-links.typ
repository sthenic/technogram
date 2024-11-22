/* Return content where any markers in the `text` have been replaced with link
   objects. If no markers exist, `default` is returned. */
#let _markers-to-links(raw-text, default) = {
  let matches = raw-text.matches(regex("jdztDE(\w+)zRVeVY"))
  if matches.len() > 0 {
    let content = []
    let index = 0

    for match in matches {
      if index < match.start {
        content += raw-text.slice(index, match.start)
      }

      let link-text = match.text
        .replace("jdztDE", "")
        .replace("IbXRuT", "::")
        .replace("zRVeVY", "")

      let split = link-text.split("::")
      if split.len() > 1 {
        content += link(label(link-text), text(hyphenate: true, split.at(1)))
      } else {
        content += link(label(link-text), text(hyphenate: true, link-text))
      }

      index = match.end
    }

    /* Copy any remainder */
    if index < raw-text.len() {
      content += raw-text.slice(index)
    }

    content
  } else {
    /* TODO: Use text(hyphenate: true) here too? Could be nice. */
    default
  }
}

#let _insert-markers(identifier, ignore-prefix) = {
  /* Check for identifiers and scoped parameters with a matching link in the
     document. These get marked with a set of random letters to preserve the
     identifier through the syntax highlighting stage (mostly affects `::`).
     If we're instructed to ignore prefixes, we query for a matching link after
     removing the characters up to and including the first underscore. */
  if query(label(identifier)).len() > 0 {
    return "jdztDE" + identifier.replace("::", "IbXRuT") + "zRVeVY"
  } else if ignore-prefix {
    let split = identifier.split("_")
    if split.len() > 1 {
      let id = split.slice(1).join("_")
      if query(label(id)).len() > 0 {
        return split.at(0) + "_jdztDE" + id.replace("::", "IbXRuT") + "zRVeVY"
      }
    }
  }

  return identifier
}

#let _lex-and-insert-markers(text, ignore-prefix) = {
  let pos = 0
  let text-with-markers = ()

  /* Separate the two styles of comments from all other text with a simple
     lexer. Unfortunately, we have to keep all the logic in the loop since
     functions have to be pure (and thus cannot modify the lexer state). */

  let segment = ""
  while true {
    if pos >= text.len() {
      break
    }

    let c = text.at(pos)
    if c.match(regex("[a-zA-z]")) != none {
      /* Eject any ongoing segment without inserting markers, we're about to
         start an identifier. */
      if segment.len() > 0 {
        text-with-markers.push(segment)
      }
      segment = c
      pos += 1

      while true {
        c = text.at(pos, default: none)
        if c == none or c.match(regex("[a-zA-Z0-9_:]")) == none {
          /* End of the buffer or the identifier. Do not claim the character by
             advancing the buffer position. */
          text-with-markers.push(_insert-markers(segment, ignore-prefix))
          segment = ""
          break
        } else {
          segment += c
          pos += 1
        }
      }
    } else if c == "/" {
      /* Eject any ongoing segment, we're about to start a comment. */
      if segment.len() > 0 {
        text-with-markers.push(segment)
      }

      segment = "/"
      pos += 1

      /* Peek at the next character to determine the type of comment. */
      let next = text.at(pos, default: none)
      if next == "/" {
        segment += "/"
        pos += 1
        while true {
          c = text.at(pos, default: none)
          segment += c
          pos += 1

          /* A line comment keeps going until we encounter a newline or
             reach the end of the buffer. */
          if c in ("\n", none) {
            text-with-markers.push(segment)
            segment = ""
            break
          }
        }
      } else if next == "*" {
        segment += "*"
        pos += 1
        while true {
          c = text.at(pos, default: none)
          segment += c
          pos += 1

          /* A block comment keeps going until we encounter the first stop
             sequence or reach the end of the buffer. */
          next = text.at(pos, default: none)
          if next == none or c == "*" and next == "/" {
            text-with-markers.push(segment + next)
            segment = ""
            pos += 1
            break
          }
        }
      }
    } else {
      /* Any other type of character just gets added to the segment. */
      segment += c
      pos += 1
    }
  }

  /* Any remaining segment is neither a comment nor an identifier. */
  if segment.len() > 0 {
    text-with-markers.push(segment)
  }

  text-with-markers.join()
}

/* Hook into `raw` to replace special matching text with custom markers. */
#let format-raw(it, ignore-prefix: false) = {
  if it.at("label", default: none) == <technogram-modified-raw> {
    it
  } else {
    [#raw(
      _lex-and-insert-markers(it.text, ignore-prefix),
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
