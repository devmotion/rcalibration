# rcalibration

Estimation and hypothesis tests of calibration in R using CalibrationErrors.jl and CalibrationTests.jl.

[![Stable](https://img.shields.io/badge/Julia%20docs-stable-blue.svg)](https://devmotion.github.io/CalibrationErrors.jl/stable)
[![Dev](https://img.shields.io/badge/Julia%20docs-dev-blue.svg)](https://devmotion.github.io/CalibrationErrors.jl/dev)
[![R-CMD-check](https://github.com/devmotion/rcalibration/workflows/R-CMD-check/badge.svg?branch=main)](https://github.com/devmotion/rcalibration/actions?query=workflow%3AR-CMD-check+branch%3Amain)
[![CalibrationErrors.jl Status](https://img.shields.io/github/workflow/status/devmotion/CalibrationErrors.jl/CI/main?label=CalibrationErrors.jl)](https://github.com/devmotion/CalibrationErrors.jl/actions?query=workflow%3ACI+branch%3Amain)
[![CalibrationTests.jl Status](https://img.shields.io/github/workflow/status/devmotion/CalibrationTests.jl/CI/main?label=CalibrationTests.jl)](https://github.com/devmotion/CalibrationTests.jl/actions?query=workflow%3ACI+branch%3Amain)

rcalibration is a package for estimating calibration of probabilistic models in R.
It uses [CalibrationErrors.jl](https://github.com/devmotion/CalibrationErrors.jl)
and [CalibrationTests.jl](https://github.com/devmotion/CalibrationTests.jl) for its
computations. As such, the package allows the estimation of calibration errors (ECE and
SKCE) and statistical testing of the null hypothesis that a model is calibrated.

## Installation

You can install `rcalibration` with [`devtools`](https://devtools.r-lib.org/):

```R
> library(devtools)
> devtools::install_github("devmotion/rcalibration")
```

The use of `rcalibration` requires that its dependency
[`JuliaCall`](https://github.com/Non-Contradiction/JuliaCall) (installed automatically)
and itself are configured correctly.

For `JuliaCall`, you have to
[install Julia](https://github.com/Non-Contradiction/JuliaCall#installation).
The configuration process is described in the
[`JuliaCall` documentation](https://non-contradiction.github.io/JuliaCall/index.html).

When `JuliaCall` is configured correctly, you can install the Julia packages required by
`rcalibration`:

```R
> library(rcalibration)
> rcalibration::install()
```

### Crash on MacOS with Julia 1.6

Due to a [problem in Julia 1.6](https://github.com/JuliaLang/julia/issues/40246), `JuliaCall`
and `rcalibration` crash on MacOS with this Julia version. Please use Julia 1.5 on MacOS
until this issue is fixed.

### Custom Julia environment

With the default settings, `JuliaCall` and `rcalibration` install all Julia dependencies
in the default environment. In particular, if you use Julia for other projects as well,
a separate [project environment](https://pkgdocs.julialang.org/v1/environments/) can
simplify package management and ensure that the state of the Julia dependencies is
reproducible. In `JuliaCall` and `rcalibration`, a custom project environment is used if
you set the environment variable `JULIA_PROJECT`:

```shell
export JULIA_PROJECT="path/to/the/environment/"
```

## Usage

Import and setup

- estimation of calibration errors with
  ```R
  > ce <- calerrors()
  ```
- statistical hypothesis tests for calibration with
  ```R
  > ct <- caltests()
  ```

You can then do the same as would be done in Julia, except you have to add
`ce$` or `ct$` in front for functionality from CalibrationErrors.jl or
CalibrationTests.jl, respectively. Most of the commands will work without
any modification. Thus the documentation of the Julia packages are the main
in-depth documentation for this package.

### Callable objects

R does not support the callable object syntax that is a common idiom in Julia.
`JuliaCall` supports the
[syntax `f$.(x)` in R for the function call `f(x)`](https://github.com/Non-Contradiction/JuliaCall/pull/118#issuecomment-534203455)
with callable object `f` in Julia.

### Calibration errors

Let us estimate the squared kernel calibration error (SKCE) with the tensor
product kernel
```math
k((p, y), (p̃, ỹ)) = exp(-|p - p̃|) δ(y - ỹ)
```
from a set of predictions and corresponding observed outcomes.

```R
> ce <- calerrors()
> skce <- ce$SKCE(ce$tensor(ce$ExponentialKernel(), ce$WhiteKernel()))
```

Other estimators of the SKCE and estimators of other calibration errors such
as the expected calibration error (ECE) are available as well. The Julia package
[KernelFunctions.jl](https://github.com/JuliaGaussianProcesses/KernelFunctions.jl)
supports a variety of kernels, all compositions and transformations of
[kernels available there](https://juliagaussianprocesses.github.io/KernelFunctions.jl/stable/kernels/)
can be used.

#### Probabilities

Predictions can be provided as probabilities. In this case, the
predictions correspond to Bernoulli distributions with these parameters and the
targets are boolean values.

```R
> set.seed(1234)
> predictions <- runif(100)
> outcomes <- sample(c(TRUE, FALSE), 100, replace=TRUE)
> skce$.(predictions, outcomes)
[1] 0.01518318
```

#### Probability vectors

Predictions can be provided as probability vectors (i.e., vectors in the probability
simplex) as well. In this case, the predictions correspond to categorical
distributions with these class probabilities and the targets are integers in `{1,...,n}`.
The probability vectors can be given as a matrix. However, it is
required to specify if the probability vectors correspond to rows or columns of the matrix
by wrapping them in `ce.RowVecs` and `ce.ColVecs`, respectively. These wrappers are defined
in [KernelFunctions.jl](https://github.com/JuliaGaussianProcesses/KernelFunctions.jl).

```R
> library(extraDistr)
> set.seed(1234)
> predictions <- rdirichlet(100, c(3, 2, 5))
> outcomes <- sample(1:3, 100, replace=TRUE)
> skce$.(ce$RowVecs(predictions), outcomes)
[1] 0.02585344
```

#### Probability distributions

Predictions can also be provided as probability distributions defined in the
Julia package [Distributions.jl](https://github.com/JuliaStats/Distributions.jl). Currently,
analytical formulas for the estimators of the SKCE and unnormalized calibration mean embedding
(UCME) are implemented for uni- and multivariate normal distributions `ce$Normal` and
`ce$MvNormal` with squared exponential kernels on the target space and Laplace distributions
`ce$Laplace` with exponential kernels on the target space.

In this example we use the tensor product kernel
```math
k((p, y), (p̃, ỹ)) = exp(-W₂(p, p̃)) exp(-(y - ỹ)²/2),
```
where `W₂(p, p̃)` is the 2-Wasserstein distance of the two normal distributions `p` and `p̃`.
It is given by
```math
W₂(p, p̃) = √((μ - μ̃)² + (σ - σ̃)²),
```
where `p = N(μ, σ)` and `p̃ = N(μ̃, σ̃)`.

```R
> set.seed(1234)
> predictions <- replicate(100, ce$Normal(rnorm(1), runif(1)))
> outcomes <- rnorm(100)
> skce <- ce$SKCE(ce$tensor(ce$ExponentialKernel(metric=ce$Wasserstein()), ce$SqExponentialKernel()))
> skce$.(predictions, outcomes)
[1] 0.02301165
```

### Calibration tests

`rcalibration` provides different calibration tests that estimate the p-value of the null hypothesis
that a model is calibrated, based on a set of predictions and outcomes:
- `ct$ConsistencyTest` estimates the p-value with consistency resampling for a given calibration error estimator
- `ct$DistributionFreeSKCETest` computes distribution-free (and therefore usually quite weak) upper bounds of the p-value for different estimators of the SKCE
- `ct$AsymptoticBlockSKCETest` estimates the p-value based on the asymptotic distribution of the unbiased block estimator of the SKCE
- `ct$AsymptoticSKCETest` estimates the p-value based on the asymptotic distribution of the unbiased estimator of the SKCE
- `ct$AsymptoticCMETest` estimates the p-value based on the asymptotic distribution of the UCME

```R
> library(extraDistr)
> ct <- caltests()
> set.seed(1234)
> predictions <- rdirichlet(100, c(3, 2, 5))
> outcomes <- sample(1:3, 100, replace=TRUE)
> kernel <- ct$tensor(ct$ExponentialKernel(metric=ct$TotalVariation()), ct$WhiteKernel())
> test <- ct$AsymptoticSKCETest(kernel, ce$RowVecs(predictions), outcomes)
> print(test)
Julia Object of type AsymptoticSKCETest{KernelTensorProduct{Tuple{ExponentialKernel{TotalVariation}, WhiteKernel}}, Float64, Float64, Matrix{Float64}}.
Asymptotic SKCE test
--------------------
Population details:
    parameter of interest:   SKCE
    value under h_0:         0.0
    point estimate:          0.0259434

Test summary:
    outcome with 95% confidence: reject h_0
    one-sided p-value:           0.0100

Details:
    test statistic: -0.007291403994633658
> ct$pvalue(test)
[1] 0.004
```

## References

If you use pycalibration as part of your research, teaching, or other activities,
please consider citing the following publications:

Widmann, D., Lindsten, F., & Zachariah, D. (2019). [Calibration tests in multi-class
classification: A unifying framework](https://proceedings.neurips.cc/paper/2019/hash/1c336b8080f82bcc2cd2499b4c57261d-Abstract.html). In
*Advances in Neural Information Processing Systems 32 (NeurIPS 2019)* (pp. 12257–12267).

Widmann, D., Lindsten, F., & Zachariah, D. (2021).
[Calibration tests beyond classification](https://openreview.net/forum?id=-bxf89v3Nx).
To be presented at *ICLR 2021*.
