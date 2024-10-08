/* We keep the default palette as a noncontextual object. */
#let DEFAULT-PALETTE = (
  primary: rgb("#005050"),
  secondary: rgb("#D2E6E6"),
  background: rgb("#FFFFFF"),

  note-header: rgb("#005050"),
  note-body: rgb("#D2E6E6"),

  tip-header: rgb("#005050"),
  tip-body: rgb("#D2E6E6"),

  important-header: rgb("#BF2629"),
  important-body: rgb("#FDF3F2"),

  warning-header: rgb("#E97211"),
  warning-body: rgb("#FFEFE1"),

  example-header: rgb("#005050"),
  example-body: rgb("#D2E6E6"),

  release-header: rgb("#005050"),
  release-body: rgb("#D2E6E6"),

  display-header: rgb("#005050"),
  display-body: luma(240),
)

/* The global palette state. */
#let palette = state("palette", DEFAULT-PALETTE)

/* Convenience function to override any number of entries in the state. */
#let update-palette(..args) = context {
  palette.update(palette.get() + args.named())
}

/* Convenience function to avoid exporting the state variable directly. */
#let get-palette() = palette.get()

/* Convenience function to generate a somewhat unified palette for the admonitions. */
#let generate-admonition-palette(primary, secondary) = {
  /* TODO: Explicit for now, warning keeps its color. */
  update-palette(
    note-header: primary,
    note-body: secondary,
    tip-header: primary,
    tip-body: secondary,
    important-header: primary,
    important-body: secondary,
    example-header: primary,
    example-body: secondary,
    release-header: primary,
    release-body: secondary,
    display-header: primary,
  )
}

/* Table fill pattern */
#let table-fill = (_, y) => {
  if calc.even(y) and y > 0 { luma(240) } else { white }
}

/* Table stroke pattern */
#let table-stroke = (x, y) => (
  left: 0pt,
  right: 0pt,
  top: if y == 0 { 1.2pt } else if y == 1 { 0.7pt } else { 0pt },
  bottom: 1.2pt,
)
