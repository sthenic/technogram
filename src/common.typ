/* A function to get text color (white/black) that's appropriate for the background. */
/* See https://stackoverflow.com/a/3943023 */
#let get-text-color(col) = {
  let (red, green, blue) = rgb(col).components(alpha: false)
  if red * 29.9% + green * 58.7% + blue * 11.4% > 73% {
    black
  } else {
    white
  }
}
