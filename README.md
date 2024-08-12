# Blickwinkel R Package
## Batch Sentiment Analysis for German

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)

## Overview

**Blickwinkel** is an R package that provides tools for performing batch sentiment analysis on German sentences. It uses the Leipzig SentiWS resource to analyse the sentiment of input sentences, classifying them with a negative or positive value depending on their sentiment.

## Installation

You can install the `blickwinkel` package directly from GitHub using the `devtools` package:

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install blickwinkel from GitHub
devtools::install_github("DanielGall500/blickwinkel")
