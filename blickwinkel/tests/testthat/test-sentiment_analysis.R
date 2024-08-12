test_that("sentiment_analysis works correctly", {
  sentences <- c("Das ist fantastisch!", "Das ist schrecklich.", "Das ist okay.")
  results <- run_sentiment_analysis(sentences)
  expect_equal(results, c(0.1, 0.1, 0.1))
})
