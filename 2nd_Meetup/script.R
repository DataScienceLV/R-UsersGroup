# Packages to load 
# Install first if necessary

# Uncomment and edit as necessary
# install.packages(c("Lahman", "ggplot2", "plyr", "reshape2", 
                     "data.table", "tidyr"))

# Download and install latest version of dplyr
# On Windows and Macs, you need to install from source at present
# On Windows, this means you need to have Rtools3.1 
# installed from CRAN before installing dplyr. Should be OK on MacOS.
# The installation takes a couple of minutes since C++ files 
# must be compiled.
install.packages("dplyr", type = "source")


# Load packages

library(ggplot2)
library(Lahman)
library(data.table)
library(tidyr)
library(dplyr)


# Toy data frame for basic illustrations
DF <- data.frame(gp = gl(3, 4, labels = LETTERS[1:3]),
                  x = sample(seq(12)),
                  y = rnorm(12))

## Examples of how to use the tbl_*() functions

DT <- data.table(DF, key = "gp")
dft <- tbl_df(DF)   # data frame to dplyr tbl
dtt <- tbl_dt(DT)   # data table to dplyr tbl

str(dft)
str(dtt)
rm(DT, dtt)   # won't use data.table again 
detach(package:data.table, unload = TRUE)


###################
## One-table verbs
###################

# arrange(): sorting

arrange(dft, gp, y)
dft %>% arrange(gp, y)     # data pipeline version
dft %>% arrange(gp, desc(x))  # reverse sort by x w/i gp

# filter(): row subsetting

dft %>% filter(gp == "A")
dft %>% filter(gp %in% c("A", "B") & y > 0)


# count(): frequency tabulation
dft %>% count(gp)
dft %>% count(gp, y > 0)

# tally(): sums numeric vars

dft %>% group_by(gp) %>% tally(y)  # sum of y by gp


# select(): selects columns to retain

dft %>% select(-x)   # remove column named x
dft %>% select(starts_with("g"))   # returns gp

### Better idea of how the function works:
example(dplyr::select)

# summarise(): one-number summar[y/ies] of a variable

dft %>% group_by(gp) %>% summarise(mean_y = mean(y), sd_y = sd(y), n = n())


# mutate(): transforms or creates variables within a tbl object

dft %>% 
   group_by(gp) %>%
   mutate(abs_y = abs(y), norm_y = scale(y, scale = TRUE),
          z = x + 2 * y)

# transmute(): like mutate() except that it drops unused existing variables
#              New in version 0.3

dft %>% mutate(abs_y = abs(y), z = 1 + y/2)
dft %>% transmute(abs_y = abs(y), z = 1 + y/2)

### transmute() can also operate groupwise

dft %>% 
  group_by(gp) %>% 
  transmute(norm_y = scale(y, scale = TRUE))


# slice(): row indexing operator in dplyr using vector positions
#          rather than logical expressions

dft %>% slice(1:5)
dft %>% slice(c(2, 5, 7, 10))

dft %>% group_by(gp) %>% slice(n())
dft %>% group_by(gp) %>% slice(1)

# rename(): renames variables

rename(dft, xx = x, yy = y)
dft %>% rename(xx = x)


##################
# Two-table verbs
##################

t1 <- data.frame(name = c("Tom", "Rick", "Harriet", "Ralph", 
                          "Noriko", "Tyrone", "Ingrid"),
                 position = c("VP", "AVP", "VP", "AVP",
                              "CFO", "CEO", "IT"))
t2 <- data.frame(name = c("Tom", "Harriet", "Ralph", "Noriko",
                          "Ingrid"),
                 company = c("A", "A", "B", "B", "A"))

T1 <- tbl_df(t1)
T2 <- tbl_df(t2)
rm(t1, t2)

inner_join(T1, T2)
left_join(T1, T2)
left_join(T2, T1)   # right join
semi_join(T1, T2)
anti_join(T1, T2)



#################
# do() function
#################

# Used to apply a non-verb function groupwise to a tbl object
# Particularly useful for model-fitting functions

teams <- tbl_df(Lahman::Teams)
teams1013 <- teams %>% 
               filter(yearID >= 2010) %>%
               select(yearID, H, R, lgID)
# Reset the levels of lgID
teams1013 <- teams1013 %>% mutate(lgID = factor(lgID))

# Model runs scored vs. hits by team within season

mod1 <- teams1013 %>% 
          group_by(yearID, lgID) %>%
          do(mod = lm(R ~ H, data = .))

# Some useful things to extract from this object
class(mod1)
length(mod1)
sapply(mod1, class)
mod1


# Utility functions to extract R^2 and the model coefficients

r2 <- function(m) summary(m)$r.squared

coef_df <- function(m) 
{
  sc <- coef(m)
  names(sc) <- c("Intercept", "Slope")
  data.frame(as.list(sc))
}


## In this case, do() is working row-wise on mod1 because the
## mod component is a list, which is why we use [1] for the first
## two variables

mod1 %>% do(data.frame(year = .$yearID[1], league = .$lgID[1],
                       coef_df(.$mod), rsq = r2(.$mod)))

## Another approach, appending the results of do() to the first
## two columns of mod1

data.frame(mod1[, 1:2], 
           mod1 %>% do(data.frame(coef_df(.$mod), 
                                  rsq = r2(.$mod))))



# Alternative approach: all in one
summfun <- function(d)
{
   rsq <- do.call(c, lapply(d$mod, r2))
   coeff <- do.call(rbind, lapply(d$mod, coef))
   dd <- data.frame(d$yearID, d$lgID, coeff, rsq)
   names(dd) <- c("year", "league", "intercept", "slope", "rsq")
   dd
}
summfun(mod1)


##############
## tidyr
##############

# parallels dplyr as reshape2 parallels plyr


### gather()
### stacks multiple columns into two

m1 <- matrix(rnorm(20), ncol = 5, 
             dimnames = list(NULL, paste0("x", 1:5)))
m2 <- matrix(rnorm(20), ncol = 5, 
             dimnames = list(NULL, paste0("y", 1:5)))

DF1 <- data.frame(g = gl(2, 2, labels = LETTERS[1:2]),
                  m1, m2)
names(DF1)

dft1 <- tbl_df(DF1)
dft2 <- dft1 %>% 
         gather(xvar, xvalue, x1:x5)  %>%
         gather(yvar, yvalue, y1:y5)
str(dft2)


### spread() is the inverse function of gather():
### unstacks two columns into several

dft2 %>% spread(xvar, xvalue)



### separate() splits a variable name into two new ones

DF2 <- data.frame(smin = c(2, 4, 3), smax = c(3, 6, 7),
                  tmin = c(3, 0, 4), tmax = c(5, 1, 8))
DFT2 <- tbl_df(DF2)
( DFT3 <- DFT2 %>% gather(var, value, smin:tmax) %>%
                  separate(var, c("type", "stat"), 1) )


### unite() is the inverse function of separate

DFT3 %>% unite(type_stat, type, stat)

