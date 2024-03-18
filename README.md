
<!-- README.md is generated from README.Rmd. Please edit that file -->

# larkdown

<!-- badges: start -->
<!-- badges: end -->

**Larkdown** is Markdown for **lar**ge **la**nguage models, specifically
made to work with **La**ngChain and **La**ngServe.

## Installation

You can install the development version of larkdown like so:

``` r
devtools::install_github("markwh/larkdown")
library(larkdown)
```

Larkdown requires a deployed [LangServe
endpoint](https://github.com/langchain-ai/langserve). This can be set
via the `register_endpoint()` function. The endpoint should take a
single input that is a list of messages.
