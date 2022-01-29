# load support for calibration tests
ct <- caltests()

# sample data
set.seed(1234)
predictions <- as.matrix(rdirichlet(500, c(1, 1)))
targets_consistent <- 2L - (runif(500) < predictions[, 1])
targets_onlytwo <- rep(2L, 500)

kernel <- ct$tensor(ct$compose(ct$ExponentialKernel(), ct$ScaleTransform(3)), ct$WhiteKernel())

test_that("Consistency test", {
  estimators <- list(ct$SKCE(kernel, unbiased=FALSE), ct$SKCE(kernel))
  for (estimator in estimators) {
    test <- ct$ConsistencyTest(estimator, ct$RowVecs(predictions), targets_consistent)
    expect_gte(ct$pvalue(test), 0.7)
    print(test)

    test <- ct$ConsistencyTest(estimator, ct$RowVecs(predictions), targets_onlytwo)
    expect_lte(ct$pvalue(test), 1e-6)
    print(test)
  }
})

test_that("Distribution-free test", {
  estimators <- list(ct$SKCE(kernel, unbiased=FALSE), ct$SKCE(kernel), ct$SKCE(kernel, blocksize=2L))
  for (i in seq_along(estimators)) {
    estimator <- estimators[[i]]
    test <- ct$DistributionFreeSKCETest(estimator, ct$RowVecs(predictions), targets_consistent)
    expect_gte(ct$pvalue(test), 0.7)
    print(test)

    test <- ct$DistributionFreeSKCETest(estimator, ct$RowVecs(predictions), targets_onlytwo)
    if (i == 1) {
      expect_lte(ct$pvalue(test), 1e-6)
    } else {
      expect_lte(ct$pvalue(test), 0.3)
    }
    print(test)
  }
})


test_that("Asymptotic block SKCE", {
  for (blocksize in c(2L, 10L)) {
    test <- ct$AsymptoticBlockSKCETest(kernel, blocksize, ct$RowVecs(predictions), targets_consistent)
    expect_gte(ct$pvalue(test), 0.4)
    print(test)

    test <- ct$AsymptoticBlockSKCETest(kernel, blocksize, ct$RowVecs(predictions), targets_onlytwo)
    expect_lte(ct$pvalue(test), 1e-6)
    print(test)
  }
})

test_that("Asymptotic SKCE", {
  test <- ct$AsymptoticSKCETest(kernel, ct$RowVecs(predictions), targets_consistent)
  expect_gte(ct$pvalue(test), 0.7)
  print(test)

  test <- ct$AsymptoticSKCETest(kernel, ct$RowVecs(predictions), targets_onlytwo)
  expect_lte(ct$pvalue(test), 1e-6)
  print(test)
})

test_that("Asymptotic CME", {
  set.seed(5678)
  testpredictions <- ct$RowVecs(as.matrix(rdirichlet(5, c(1, 1))))
  testtargets <- sample(1:2, 5, replace = TRUE)
  estimator <- ct$UCME(kernel, testpredictions, testtargets)

  test <- ct$AsymptoticCMETest(estimator, ct$RowVecs(predictions), targets_consistent)
  expect_gte(ct$pvalue(test), 0.7)
  print(test)

  test <- ct$AsymptoticCMETest(estimator, ct$RowVecs(predictions), targets_onlytwo)
  expect_lte(ct$pvalue(test), 1e-6)
  print(test)
})
