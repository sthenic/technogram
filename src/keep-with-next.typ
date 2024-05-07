/* We resort to a somewhat hacky solution to prevent a page break between the
   content supplied as `body` and the upcoming content (which is usually text).
   We create an unbreakable block containing the `body` and vertical spacing
   equal to the height of four lines of text. This threshold is configurable,
   but `4em` is an empirical value that seems to work in all situations where
   the `body` is followed by free-form text. Likely this has something to do
   with Typst's runt limits. If this unbreakable block gets pushed to the next
   page, we know the content wouldn't stay together like we wanted to. We follow
   up by undoing the vertical spacing.

   See https://github.com/typst/typst/issues/993 */

#let keep-with-next(threshold: 4em, body) = {
  block(breakable: false)[
    #body
    #v(threshold)
  ]
  v(-threshold)
}
