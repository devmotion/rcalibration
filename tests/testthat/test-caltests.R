# load calibration environment
Sys.setenv(LD_LIBRARY_PATH = "")
ca <- rcalibration::load()

# sample data
set.seed(1234)
predictions <- as.matrix(rdirichlet(500, c(1, 1)))
targets_consistent <- 2L - (runif(500) < predictions[, 1])
targets_onlytwo <- rep(2L, 500)

kernel <- ca$tensor(ca$compose(ca$ExponentialKernel(), ca$ScaleTransform(3)), ca$WhiteKernel())

test_that("Consistency test", {
  estimators <- list(ca$SKCE(kernel, unbiased=FALSE), ca$SKCE(kernel))
  for (estimator in estimators) {
    test <- ca$ConsistencyTest(estimator, ca$RowVecs(predictions), targets_consistent)
    expect_gte(ca$pvalue(test), 0.7)
    print(test)

    test <- ca$ConsistencyTest(estimator, ca$RowVecs(predictions), targets_onlytwo)
    expect_lte(ca$pvalue(test), 1e-6)
    print(test)
  }
})

test_that("Distribution-free test", {
  estimators <- list(ca$SKCE(kernel, unbiased=FALSE), ca$SKCE(kernel), ca$SKCE(kernel, blocksize=2L))
  for (i in seq_along(estimators)) {
    estimator <- estimators[[i]]
    test <- ca$DistributionFreeSKCETest(estimator, ca$RowVecs(predictions), targets_consistent)
    expect_gte(ca$pvalue(test), 0.7)
    print(test)

    test <- ca$DistributionFreeSKCETest(estimator, ca$RowVecs(predictions), targets_onlytwo)
    if (i == 1) {
      expect_lte(ca$pvalue(test), 1e-6)
    } else {
      expect_lte(ca$pvalue(test), 0.3)
    }
    print(test)
  }
})


test_that("Asymptotic block SKCE", {
  for (blocksize in c(2L, 10L)) {
    test <- ca$AsymptoticBlockSKCETest(kernel, blocksize, ca$RowVecs(predictions), targets_consistent)
    expect_gte(ca$pvalue(test), 0.4)
    print(test)

    test <- ca$AsymptoticBlockSKCETest(kernel, blocksize, ca$RowVecs(predictions), targets_onlytwo)
    expect_lte(ca$pvalue(test), 1e-6)
    print(test)
  }
})

test_that("Asymptotic SKCE", {
  test <- ca$AsymptoticSKCETest(kernel, ca$RowVecs(predictions), targets_consistent)
  expect_gte(ca$pvalue(test), 0.7)
  print(test)

  test <- ca$AsymptoticSKCETest(kernel, ca$RowVecs(predictions), targets_onlytwo)
  expect_lte(ca$pvalue(test), 1e-6)
  print(test)
})

test_that("Asymptotic CME", {
  set.seed(5678)
  testpredictions <- ca$RowVecs(as.matrix(rdirichlet(5, c(1, 1))))
  testtargets <- sample(1:2, 5, replace = TRUE)
  estimator <- ca$UCME(kernel, testpredictions, testtargets)

  test <- ca$AsymptoticCMETest(estimator, ca$RowVecs(predictions), targets_consistent)
  expect_gte(ca$pvalue(test), 0.7)
  print(test)

  test <- ca$AsymptoticCMETest(estimator, ca$RowVecs(predictions), targets_onlytwo)
  expect_lte(ca$pvalue(test), 1e-6)
  print(test)
})
