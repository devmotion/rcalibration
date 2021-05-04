ce <- calerrors()

test_that("ECE tests", {
  ece <- ce$ECE(ce$UniformBinning(10L))

  # binary classification
  for (predictions in list(matrix(c(1, 0, 0, 1), nrow = 2, byrow = TRUE), diag(2))) {
    expect_equal(ece$.(ce$ColVecs(predictions), c(1L, 2L)), 0)
    expect_equal(ece$.(ce$RowVecs(predictions), c(1L, 2L)), 0)
  }
  expect_equal(ece$.(ce$ColVecs(matrix(c(0, 0.5, 0.5, 1, 1, 0.5, 0.5, 0), nrow = 2, byrow = TRUE)), c(2L, 2L, 1L, 1L)), 0)

  # multi-class classification
  predictions <- ce$RowVecs(as.matrix(rdirichlet(1000, rep(1, 5))))
  targets <- sample(1:5, 1000, replace = TRUE)

  x <- ece$.(predictions, targets)
  expect_gte(x, 0)
  expect_lte(x, 1)

  # non-uniform binning
  ece <- ce$ECE(ce$MedianVarianceBinning(10L))
  x <- ece$.(predictions, targets)
  expect_gte(x, 0)
  expect_lte(x, 1)
})

test_that("Biased SKCE", {
  # binary example

  # categorical distributions
  skce <- ce$BiasedSKCE(ce$SqExponentialKernel(), ce$WhiteKernel())
  for (data in list(matrix(c(1, 0, 0, 1), nrow = 2, byrow = TRUE), diag(2))) {
    for (predictions in list(ce$ColVecs(data), ce$RowVecs(data))) {
      expect_equal(skce$.(predictions, c(1L, 2L)), 0)
      expect_equal(skce$.(predictions, c(1L, 1L)), 0.5)
      expect_equal(skce$.(predictions, c(2L, 1L)), 1 - exp(-1))
      expect_equal(skce$.(predictions, c(2L, 2L)), 0.5)
    }
  }

  # probabilities
  skce <- ce$BiasedSKCE(ce$compose(ce$SqExponentialKernel(), ce$ScaleTransform(sqrt(2))), ce$WhiteKernel())
  expect_equal(skce$.(c(1, 0), c(TRUE, FALSE)), 0)
  expect_equal(skce$.(c(1, 0), c(TRUE, TRUE)), 0.5)
  expect_equal(skce$.(c(1, 0), c(FALSE, TRUE)), 1 - exp(-1))
  expect_equal(skce$.(c(1, 0), c(FALSE, FALSE)), 0.5)

  # multi-dimensional data
  skce <- ce$BiasedSKCE(
    ce$compose(ce$ExponentialKernel(), ce$ScaleTransform(0.1)),
    ce$WhiteKernel()
  )
  for (nclasses in c(2L, 10L, 100L)) {
    for (i in 1:1000) {
      predictions <- ce$RowVecs(as.matrix(rdirichlet(20, rep(1, nclasses))))
      targets <- sample(1:nclasses, 20, replace = TRUE)
      expect_gte(skce$.(predictions, targets), 0)
    }
  }
})

test_that("Unbiased SKCE", {
  # binary example

  # categorical distributions
  skce <- ce$UnbiasedSKCE(ce$SqExponentialKernel(), ce$WhiteKernel())
  for (data in list(matrix(c(1, 0, 0, 1), nrow = 2, byrow = TRUE), diag(2))) {
    for (predictions in list(ce$ColVecs(data), ce$RowVecs(data))) {
      expect_equal(skce$.(predictions, c(1L, 2L)), 0)
      expect_equal(skce$.(predictions, c(1L, 1L)), 0)
      expect_equal(skce$.(predictions, c(2L, 1L)), -2 * exp(-1))
      expect_equal(skce$.(predictions, c(2L, 2L)), 0)
    }
  }

  # probabilities
  skce <- ce$UnbiasedSKCE(ce$compose(ce$SqExponentialKernel(), ce$ScaleTransform(sqrt(2))), ce$WhiteKernel())
  expect_equal(skce$.(c(1, 0), c(TRUE, FALSE)), 0)
  expect_equal(skce$.(c(1, 0), c(TRUE, TRUE)), 0)
  expect_equal(skce$.(c(1, 0), c(FALSE, TRUE)), -2 * exp(-1))
  expect_equal(skce$.(c(1, 0), c(FALSE, FALSE)), 0)

  # multi-dimensional data
  skce <- ce$UnbiasedSKCE(
    ce$compose(ce$ExponentialKernel(), ce$ScaleTransform(0.1)),
    ce$WhiteKernel()
  )
  for (nclasses in c(2L, 10L, 100L)) {
    estimates <- replicate(1000, {
      predictions <- ce$RowVecs(as.matrix(rdirichlet(20, rep(1, nclasses))))
      targets <- sample(1:nclasses, 20, replace = TRUE)
      skce$.(predictions, targets)
    })
    expect_equal(mean(estimates), 0, tolerance = 1e-2)
  }
})

test_that("Block unbiased SKCE", {
  # binary example

  # categorical distributions
  skce <- ce$BlockUnbiasedSKCE(ce$SqExponentialKernel(), ce$WhiteKernel())
  for (data in list(matrix(c(1, 0, 0, 1), nrow = 2, byrow = TRUE), diag(2))) {
    for (predictions in list(ce$ColVecs(data), ce$RowVecs(data))) {
      expect_equal(skce$.(predictions, c(1L, 2L)), 0)
      expect_equal(skce$.(predictions, c(1L, 1L)), 0)
      expect_equal(skce$.(predictions, c(2L, 1L)), -2 * exp(-1))
      expect_equal(skce$.(predictions, c(2L, 2L)), 0)
    }
  }

  # probabilities
  skce <- ce$BlockUnbiasedSKCE(ce$compose(ce$SqExponentialKernel(), ce$ScaleTransform(sqrt(2))), ce$WhiteKernel())
  expect_equal(skce$.(c(1, 0), c(TRUE, FALSE)), 0)
  expect_equal(skce$.(c(1, 0), c(TRUE, TRUE)), 0)
  expect_equal(skce$.(c(1, 0), c(FALSE, TRUE)), -2 * exp(-1))
  expect_equal(skce$.(c(1, 0), c(FALSE, FALSE)), 0)

  # multi-dimensional data
  skce <- ce$BlockUnbiasedSKCE(
    ce$compose(ce$ExponentialKernel(), ce$ScaleTransform(0.1)),
    ce$WhiteKernel()
  )
  for (nclasses in c(2L, 10L, 100L)) {
    estimates <- replicate(1000, {
      predictions <- ce$RowVecs(as.matrix(rdirichlet(20, rep(1, nclasses))))
      targets <- sample(1:nclasses, 20, replace = TRUE)
      skce$.(predictions, targets)
    })
    expect_equal(mean(estimates), 0, tolerance = 5e-2)
  }
})
