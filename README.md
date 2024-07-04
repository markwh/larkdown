
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Larkdown

<!-- badges: start -->
<!-- badges: end -->

**Larkdown** is an R package that transforms Rmarkdown documents into a
chat interface for Large Language Models (LLMs). Built to work with
[LangChain](https://github.com/langchain-ai/langchain) and
[LangServe](https://github.com/langchain-ai/langserve), Larkdown
empowers users to interact with AI in a familiar, flexible, and powerful
environment.

<figure>
<img src="inst/media/gifs/larkdown-intro-fast.gif"
alt="Larkdown Demo" />
<figcaption aria-hidden="true">Larkdown Demo</figcaption>
</figure>

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Caveats](#caveats)
- [Contributing](#contributing)
- [License](#license)

## Introduction

Larkdown provides a robust interface for leveraging Large Language
Models (LLMs) through Rmarkdown documents. This package includes tools
for converting Rmarkdown text into chat messages, submitting those
messages to an LLM, and rendering the responses back into the document.
It aims to offer a streamlined and efficient way to interact with LLMs
within the R ecosystem.

## Installation

To get started with Larkdown, you can install the development version
from GitHub:

``` r
devtools::install_github("markwh/larkdown")
library(larkdown)
```

Larkdown requires a deployed [LangServe
endpoint](https://github.com/langchain-ai/langserve). This can be
configured using the `register_endpoint()` function:

``` r
register_endpoint("your_endpoint_url")
```

## Usage

Creating a new Larkdown document is simple. Use the `new_larkdown()`
function to start a new chat interface:

``` r
new_larkdown("my_chat.Rmd")
```

Interact with the document by knitting and submitting it to the LLM
endpoint:

``` r
knit_and_stream_current()
```

## Features

Larkdown offers a range of features designed to enhance interaction with
AI:

- **Code Execution**: Execute code directly within the Rmarkdown
  document, supporting multiple languages like Python, SQL, and more.
- **Editable Chat History**: Easily edit upstream messages, correct
  errors, or modify instructions.
- **Flexible Chat Interface**: Use any LLM provider by configuring the
  endpoint, giving you freedom from provider lock-in.
- **Rstudio Integration**: Includes Rstudio addins and keyboard
  shortcuts for a streamlined workflow.
- **Persistent Conversations**: Store chat history as text files and
  resume conversations effortlessly.
- **Customizable Output**: Render conversations in various formats
  including HTML and PDF.

## Caveats

Larkdown is currently designed with a specific workflow in mind and may
not be universally applicable. It is not built to be production-grade or
universally stable. Users are encouraged to adapt and extend the tool to
fit their own needs.

## Contributing

Contributions are welcome. Feel free to open issues and submit pull
requests. Larkdown aims to inspire others to build their own tools and
workflows for interacting with AI.

## License

Larkdown is licensed under the MIT License. See the [LICENSE](LICENSE)
file for more details.
