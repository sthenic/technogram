[![TYPST](https://img.shields.io/badge/Typst-0.11.0-orange.svg?style=flat-square)](https://typst.app)
[![LICENSE](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://opensource.org/licenses/MIT)

# Technogram

Technogram is a collection of [Typst](https://typst.app) packages and document
classes that together form a typesetting framework for technical documentation.

This project was originally written i LuaLaTeX and is a work in progress.

## Installation

Until the project is stable, manual installation is required (see below).
Importing is done with

```typst
#import "@local/technogram:0.1.0" as tg
```

to import all symbols to the `tg` namespace. Refer to the [Typst package repository](https://github.com/typst/packages/?tab=readme-ov-file#local-packages) for more information.

### Linux

Make a symbolic link to the repository in the local package directory

    ln -s /path/to/repository $HOME/.local/share/typst/packages/local/technogram/0.1.0

### Windows

Copy the repository to

    %APPDATA%/typst/packages/local/technogram/0.1.0

## License

This application is free software released under the [MIT
license](https://opensource.org/licenses/MIT).

