# Blickwinkel R Package
## Batch Sentiment Analysis for German

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)

---

### Overview

This project implements a batch sentiment analysis tool for the German language, leveraging the **Leipzig SentiWS** dataset to assign sentiment scores to sentences.

## Installation

You can install the `blickwinkel` package directly from GitHub using the `devtools` package:

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install blickwinkel from GitHub
devtools::install_github("DanielGall500/blickwinkel")
```

### Data Sources

**Leipzig SentiWS Dataset**
The Leipzig SentiWS dataset provides sentiment scores for German lexical items. Features include:
- **Sentiment Score Range:** -1 (very negative) to +1 (very positive).
- **Part-of-Speech (POS) Tags** for each term.
- **Alternate Forms** of lexical items for comprehensive coverage.

---

### Research Objective

The aim is to determine **which named entities appear in the most positive and negative contexts**. By analyzing a subset of 260 sentences, we can:
1. Test the effectiveness of the sentiment analysis tool.
2. Provide insights into sentiment distributions around named entities in German text.

---

### Methodology

#### 1. **Preprocessing**
- **Lexical Item Separation:** The SentiWS dataset is split into lexical items and their POS tags.
- **Sentence Data Loading:** The treebank data is formatted to identify named entities and their surrounding contexts.
- **Document-Term Matrix (DTM):** Created using the `tm` library in R to map terms to their respective sentences.

#### 2. **Matrix-Based Sentiment Analysis**
The analysis uses matrix operations to batch-process sentiment scores:
1. **Combine Forms:** Group lexical items with their alternate forms, consolidating their sentiment values into a single column in the matrix.
2. **Apply Sentiment Scores:** Multiply the sentiment scores of terms by their occurrence frequency in sentences using column-wise matrix operations.
3. **Generate Sentiment Matrix:** A sparse matrix is created, where:
   - Rows represent sentences.
   - Columns represent sentiment-relevant terms.
   - Values correspond to sentiment scores for each term-sentence pair.

#### 3. **Final Sentiment Calculation**
- Row sums of the sentiment matrix provide overall sentiment scores for each sentence.
- The dataset is then enriched with these scores for further analysis.

---

### Applications

This methodology can be applied to:
1. **Social Media Analysis:** Detect sentiment trends towards entities like brands, public figures, or events.
2. **Market Research:** Gauge public opinion from large text corpora.
3. **Linguistic Research:** Understand sentiment dynamics in different languages and contexts.

---
