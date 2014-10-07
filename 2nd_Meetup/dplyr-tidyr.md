Introduction to dplyr and tidyr: Part 1
========================================================
author: Dennis Murphy
date: October 7, 2014

In the beginning of Hadleyverse...
========================================================

...there was `ggplot`, `plyr` and `reshape`.

* `ggplot` evolved into `ggplot2`,
* `reshape` evolved into `reshape2`.

In 2014,

* `ggplot2` development has moved to `ggvis`,
* `plyr` has been partially superseded by `dplyr`,
* `reshape2` has been partially superseded by `tidyr`.


Tonight's goals:
========================================================

To introduce you to:

* the basics of `dplyr`;
* the data pipeline operator `%>%`;
* the primary functions in the `tidyr` package.


What is dplyr?
========================================================

 * A data munging package to perform groupwise data processing.
 * A much faster (partial) successor to the `plyr` package, competitive
   to `data.table` in speed.
 * Uses a mix of R and C++ code (through the `Rcpp` package). 
 * Applies a new approach to programming in R.
 * Allows direct connections to databases.
 * Allows hybrid evaluation (a mix of R code with code 
   from another language).
 * SE versions of NSE functions (new in version 0.3)
   
We will not cover the last three in this talk.
 
 
Split-apply-combine
========================================================

The core principle of `plyr` and `dplyr` is the "split-apply-combine"
approach to data analysis:

* split the data into subsets designated by group membership;
* apply a function to each data split;
* combine the results into a new data object.

Basically, it's divide-and-conquer applied to data analysis.

The examples will illustrate this as we proceed.


Data objects in dplyr
=========================================================

Unlike `plyr`, `dplyr` only accepts a limited set of input data objects:

* data frames;
* data tables (from the `data.table` package);
* SQL tables
* data cubes (experimental).

The `tbl_*()` functions convert an object of one of the above forms to
a `tbl` object to which the "verb" functions in `dplyr` can be applied.


Basic example
========================================================


```r
library(data.table)
library(dplyr)

set.seed(409)
DF <- data.frame(g = gl(3, 4), 
                 labels = LETTERS[1:3],
                 y = rnorm(12))
DT <- data.table(DF, key = "g")
u1 <- tbl_df(DF)    # data frame -> tbl
u2 <- tbl_dt(DT)    # data table -> tbl
str(u1)             # note the classes 
```

```
Classes 'tbl_df', 'tbl' and 'data.frame':	12 obs. of  3 variables:
 $ g     : Factor w/ 3 levels "1","2","3": 1 1 1 1 2 2 2 2 3 3 ...
 $ labels: Factor w/ 3 levels "A","B","C": 1 2 3 1 2 3 1 2 3 1 ...
 $ y     : num  0.593 1.121 0.561 1.843 0.954 ...
```


Data pipeline operator %>%
========================================================

The author of the `magrittr` package, Stefan Bache, introduced 
a data pipeline operator `%>%` which is used extensively by the `dplyr` 
and `ggvis` packages. The idea is that

```
x %>% f(...)   <=>  f(x, ...)
```

* x is an input data object;
* f() is a function that takes x as its first argument, with others
  specified in the call to f().
  
One creates a data pipeline by starting with a data object, applying
a function that returns a data object, applying another function that
returns a data object, etc.

Single-table verbs
========================================================

* __arrange()__: sorts a `tbl` by one or more variables
* __count()__: computes frequencies by one or more grouping variables 
 (new in version 0.3)
* __filter()__: subsets rows of a `tbl` according to a logical expression
* __mutate()__: transforms/creates $>= 1$ variables in a `tbl`
* __select()__: selects a subset of variables from a `tbl`
* __summarise()__: provides a one-number summary of a variable in a `tbl`.

The `arrange()`, `count()`, `mutate()` and `summarise()` functions are
rewrites of functions of the same name in the `plyr` package.




group_by()
=========================================================

`group_by()` performs the "split" task in the "split-apply-combine" 
approach within `dplyr`. Its arguments are the variables
by which to group the `tbl` object, separated by commas. The order in
which they appear can matter, depending on context.

By contrast, one-table verbs often perform the "apply" task,
although other functions can be used for this purpose as well.


Two-table verbs
=========================================================

Two-table verbs refer to functions that perform some type of merge (or
join) operation. A limited number of joins are supported, each of which
take two `tbl` objects as its first two arguments:

* __inner_join(A, B)__: returns rows common to A and B;
* __left_join(A, B)__:  all of A and matching rows of B;
* __semi_join(A, B)__: include rows of A that match B;
* __anti_join(A, B)__:  the complement of `semi_join(A, B)`.


===========================================================

The third argument of `*_join()` allows specification of the variables
by which to merge the two `tbl` objects. By default, the join is
performed on all variables common to the two input `tbl` objects.



do() function
==========================================================

The `do()` function allows one to apply a general R function to each
group of a `tbl` object. A few simple examples:


```r
# Example 1:
u1 %>% group_by(g) %>% do(head(., 2))
```

```
Source: local data frame [6 x 3]
Groups: g

  g labels       y
1 1      A  0.5925
2 1      B  1.1213
3 2      B  0.9542
4 2      C  0.1922
5 3      C -0.1959
6 3      A  0.2597
```

=========================================================

```r
# Example 2:
u1 %>% group_by(g) %>% do(data.frame(z = .$y[1]))
```

```
Source: local data frame [3 x 2]
Groups: g

  g       z
1 1  0.5925
2 2  0.9542
3 3 -0.1959
```

The symbol `.` substitutes for the current sub-`tbl` being processed,
similar to the `.SD()` idiom in `data.table`.


tidyr package
==========================================================

Complements the `dplyr` package by supplying functions analogous to the
primary functions in the `reshape2` package:

* __gather()__: a replacement for `reshape2::melt()`
* __spread()__: a replacement for `reshape2::cast()`
* __separate()__: a rewrite of `reshape2::colsplit()`.

tidyr (cont.)
==========================================================

`gather()` stacks multiple columns into two: (a) the names of the
variables as levels of a factor variable; (b) the corresponding values.

`spread()` unstacks two variables (one a factor and the other a vector
of values) into multiple columns whose names are the factor levels.

`separate()` splits a name into pieces, each of which is assigned a
new variable name.

