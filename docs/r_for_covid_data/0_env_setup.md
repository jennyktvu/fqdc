# Setup R env


## Installation

The simplest way is to  use Homebrew:
```
brew install r
```

Another way is to download installation package from https://cloud.r-project.org/


## "Hello world" of R


### Run it from R console

Command `R` will start a R console, and you can run R code inside R console.
```
(base) ➜  benchling git:(b_test_pr) ✗ R

R version 4.2.2 (2022-10-31) -- "Innocent and Trusting"
Copyright (C) 2022 The R Foundation for Statistical Computing
Platform: aarch64-apple-darwin20 (64-bit)

...
> print("hello,world")
[1] "hello,world"
```

### Run it from terminal
`Rscript` is a binary front-end to R, for use in scripting applications, see https://linux.die.net/man/1/rscript for more detail
```
(base) ➜  R git:(b_test_pr) ✗ cat hello.R
print("hello,world")
(base) ➜  R git:(b_test_pr) ✗ Rscript hello.R
[1] "hello,world"
```




## Install commonly used packages

R installation package comes along with a lot of useful packages, besides that, there are a lot of useful packages available from [CRAN](https://cran.r-project.org/web/packages/).

Here are top 10 most important packages in R for data science.

  - ggplot2.
  - data.table.
  - dplyr.
  - tidyr.
  - Shiny.
  - plotly.
  - knitr.
  - mlr3.


To install those packages from CRAN, we can just simiply follow below steps.

- Start R console
- Call "install.packages(XXX)"

Here is one example:
```
> install.packages("mlr3")
--- Please select a CRAN mirror for use in this session ---
Secure CRAN mirrors

 1: 0-Cloud [https]
 2: Australia (Canberra) [https]
 3: Australia (Melbourne 1) [https]
 ....
 Selection: 1
also installing the dependencies ‘globals’, ‘listenv’, ‘PRROC’, ‘future’, ‘future.apply’, ‘lgr’, ‘mlbench’, ‘mlr3measures’, ‘mlr3misc’, ‘parallelly’, ‘palmerpenguins’, ‘paradox’

trying URL 'https://cloud.r-project.org/bin/macosx/big-sur-arm64/contrib/4.2/globals_0.16.2.tgz'
...
>> library(mlr3)
> ?mlr3
```

as above, After installation complete, we can try to run `library(<package name>)` to verify, and run `?<package name>` to see its document.


## Reference
 - https://www.w3schools.com/r/r_get_started.asp
 - https://www.datacamp.com/tutorial/top-ten-most-important-packages-in-r-for-data-science
