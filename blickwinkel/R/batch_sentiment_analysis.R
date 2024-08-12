# SentiWS provides a file for positive scores and negative scores separately
sentiws_neg_path <- "R/SentiWS/SentiWS_v2.0_Negative.txt"
sentiws_pos_path <- "R/SentiWS/SentiWS_v2.0_Positive.txt"

# create a simple function to read in tab-separated value formats
read_tsv <- function(path, cols) {
  table <- read.table(path,
                      header = TRUE,
                      sep = "\t",
                      stringsAsFactors = FALSE,
                      fill = TRUE,
                      row.names = NULL,
                      col.names = cols)
  return (table)
}

load_sentiws <- function(path) {
  cols <- c("lexical_item", "sent_score", "alt_forms")
  sentiws_data <- read_tsv(path, cols)

  # we first need to split the lexical items and POS tags
  # since they are initially provided in the same column
  item_and_pos_col <- sentiws_data$lexical_item
  item_pos_split <- lapply(item_and_pos_col,
                           function(x) strsplit(x, split="\\|")[[1]])

  # create a column for the items and the pos tags
  lexical_items <- sapply(item_pos_split, function(x) x[1])
  pos_tags <- sapply(item_pos_split, function(x) x[2])

  # update the columns with item and pos tag
  sentiws_data["lexical_item"] = lexical_items
  sentiws_data["pos"] = pos_tags

  return (sentiws_data)
}

create_document_term_matrix <- function(sentence,
                                        language) {
  corpus <- VCorpus(VectorSource(sentences))

  # preprocessing: remove whitespace, punctuation, and stopwords
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeWords, stopwords(language))
  return (
    DocumentTermMatrix(corpus, control = list(tolower = FALSE))
  )
}

# calculate sum for specified columns
calculate_column_sums <- function(m, col_names) {
  selected_cols <- m[, col_names, drop = FALSE]

  if (ncol(selected_cols) > 1) {
    result <- apply(selected_cols, 1, sum)
  } else {
    result <- selected_cols
  }

  return(result)
}

combine_forms <- function(dtm_forms, lexical_items, alt_forms) {
  all_terms <- Terms(dtm_forms)
  dtm_forms <- as.matrix(dtm_forms)

  base_words_in_dtm <- lapply(lexical_items, function(item) item %in% all_terms)

  for (i in 1:length(lexical_items)) {
    # check if it contains the lexical_item
    lex <- lexical_items[i]
    alternatives <- alt_forms[i]
    alternatives <- unlist(alternatives)
    lexical_item_in_dtm <- base_words_in_dtm[[i]]

    # get a boolean list of which alternate forms
    # for lexical item i appear in the DTM
    contains_alt_forms <- lapply(alternatives, function(x) x %in% all_terms)
    contains_alt_forms <- unlist(contains_alt_forms)

    # isolate only those alternate forms which appear
    contained_alt_forms <- alternatives[contains_alt_forms]

    # first we'll concatenate the columns into the one base word column
    # since they will all have the same sentiment value
    n_alt_forms_in_dtm <- length(contained_alt_forms)
    if (!lexical_item_in_dtm && n_alt_forms_in_dtm == 0) {
      next
    }
    else if(!lexical_item_in_dtm) {
      empty_col <- rep(0, nrow(dtm_forms))
      dtm_forms <- cbind(dtm_forms, empty_col)
      colnames(dtm_forms)[ncol(dtm_forms)] <- lex
    }
    # otherwise the lexical item is in the DTM
    # and we don't need to create a column

    if (n_alt_forms_in_dtm >= 1) {
      # does the following line work?
      alternate_form_sum <- calculate_column_sums(dtm_forms,
                                                  contained_alt_forms)

      dtm_forms[, lex] <- dtm_forms[, lex] + alternate_form_sum
    }

    # then we remove the original alternative form columns from the table
    dtm_forms <- dtm_forms[, !colnames(dtm_forms) %in% contained_alt_forms]
  }
  # then we remove all the words which are not base words in the sentiment
  # dataset as they will not contribute to the final score
  # behaves strangely if only one column returned
  dtm_forms <- dtm_forms[, colnames(dtm_forms) %in% lexical_items]
  return (dtm_forms)
}

apply_sentiment_scores <- function(dtm_forms,
                                   lexical_items,
                                   sentiment_scores) {
  cols <- colnames(dtm_forms)
  required_scores <- lapply(lexical_items, function(x) x %in% cols)
  required_scores <- unlist(required_scores)
  required_scores <- sentiment_scores[required_scores]

  dtm_forms <- dtm_forms %*% diag(required_scores)
  colnames(dtm_forms) <- cols
  return (dtm_forms)
}

# A matrix with each sentence as a row and each term as a column
# and the values representing the sentiment provided by that term
# for the given sentence
# if a term occurs multiple times in a sentence, the value corresponds to:
# (# occurrences) x (sentiment score)
get_sentiment_matrix <- function(dtm, df_sentiws) {
  lexical_items <- unlist(df_sentiws$lexical_item)

  # check which alternate forms it contains - should be a vector
  alt_forms <- df_sentiws$alt_forms
  alt_forms_processed <- lapply(alt_forms,
                                function(x) strsplit(x, split = ","))
  alt_forms_processed <- unlist(alt_forms_processed)

  final_dtm <- combine_forms(dtm,
                             lexical_items,
                             alt_forms_processed)

  # SENTIMENT
  sentiment_scores <- unlist(df_sentiws$sent_score)
  sentiment_matrix <- apply_sentiment_scores(final_dtm,
                                             lexical_items,
                                             sentiment_scores)

  return (sentiment_matrix)
}

# load the positive and negative SentiWS sentiment scores
# as a dataframe with some preprocessing
SENTIWS_POS <- load_sentiws(sentiws_pos_path)
SENTIWS_NEG <- load_sentiws(sentiws_neg_path)

#' Batch Sentiment Analysis for German Sentences
#' This function performs sentiment analysis on sentences written in German.
#'
#' @param sentences A character vector containing German sentences.
#' @return A vector of sentiment scores.
#' @examples
#' sentences <- c("Das ist fantastisch!", "Das ist schrecklich.")
#' run_sentiment_analysis(sentences)
#' @export
run_sentiment_analysis <- function(sentences) {

  dtm <- create_document_term_matrix(sentences, lang="german")

  sentiment_matrix_neg <- get_sentiment_matrix(dtm, SENTIWS_NEG)
  sentiment_matrix_pos <- get_sentiment_matrix(dtm, SENTIWS_POS)

  # sum together the rows of the matrix to get the sentiments
  sentence_sentiments_neg <- rowSums(sentiment_matrix_neg)
  sentence_sentiments_pos <- rowSums(sentiment_matrix_pos)
  return (sentence_sentiments_neg + sentence_sentiments_pos)
}
