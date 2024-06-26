/* We keep document metadata in a stateful dict so that the we (and the user)
   can query these values at arbitrary locations in the document. */

/* The global metadata state. */
#let metadata = state("metadata", (
  title: none,
  subtitle: none,
  document-name: none,
  author: none,
  classification: none,
  revision: none,
  document-id: none,
  date: none,
  url: none,
))

/* Convenience function to override any number of entries in the state. */
#let update-metadata(..args) = context {
  metadata.update(metadata.get() + args.named())
}

/* Convenience function to avoid exporting the state variable directly. */
#let get-metadata() = metadata.get()
