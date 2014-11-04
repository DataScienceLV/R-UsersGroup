# Supplemental code script for LVRUG ggplot2 talk
# Contains more advanced examples than those in presentation
# Several of these are not trivial and will require some study

# Load packages
library(ggplot2, quietly = TRUE)
library(scales, quietly = TRUE)
library(gridExtra, quietly = TRUE)
library(plyr, quietly = TRUE)
library(reshape2, quietly = TRUE)

## Introductory graph to show off basic elements of ggplot2

# Toy data set to simulate a white noise series
DF <- data.frame(t = seq(40), y = rnorm(40))

# Build the plot step by step

# p1 contains the base layer, including default theme and scales 
# geom_blank() generates an empty plot layer
p1 <- ggplot(DF, mapping = aes(x = x, y = y)) +
  geom_blank()

# Change default theme to black-and-white
p2 <- p1 + theme_bw()

# Add lines and points
p3 <- p2 + geom_line()
p4 <- p3 + geom_point()

# Add a title - grabs some vertical space
p5 <- p4 + ggtitle("White noise series") +
        labs(x = "Time", y = "Z")

# Add a line of text
p6 <- p5 + annotate("text", x = 0, y = 2, label = "Some text")

# Show the incremental layers/modifications of the plot
# Plot layers added as you go from upper left to 
# lower right by row
grid.arrange(p1, p2, p3, p4, p5, p6, ncol = 3)


######## Some toying around with bar charts and histograms ########

## (1) 
##  Investigate different positional adjustments with bar charts

# This toy data frame contains two factors plus their joint frequencies

DF0 <- data.frame(f1 = gl(2, 3, labels = c("A", "B")),
                  f2 = gl(3, 1, length = 6, labels = c("I", "II", "III")),
                  freq = c(10, 16, 14, 20, 21, 18))

# Default position adjustment is to stack
# Use stat = "identity" when the frequencies are provided
ggplot(DF0, aes(x = f1, y = freq, fill = f2)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("yellow", "darkorange", "royalblue")) +
  labs(x = "Factor 1", y = "Frequency", fill = "Factor 2")

# Create side-by-side bar charts by dodging:
ggplot(DF0, aes(x = f1, y = freq, fill = f2)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("yellow", "darkorange", "royalblue")) +
  labs(x = "Factor 1", y = "Frequency", fill = "Factor 2")

# Stack to a total of 1 with position = "fill"
# This plots conditional distributions of f2 for each level of f1
ggplot(DF0, aes(x = f1, y = freq, fill = f2)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_fill_manual(values = c("yellow", "darkorange", "royalblue")) +
  labs(x = "Factor 1", y = "Relative frequency", fill = "Factor 2")

# A common request is to plot the (relative) frequency values as text
# annotations. Here is the trick to doing this:

require(plyr, quietly = TRUE)
ypos <- ddply(DF0, .(f1), mutate, 
                ypos = cumsum(freq) - freq/2,
                yrelpos = round(ypos/sum(freq), 3),
                yrelval = round(freq/sum(freq), 3))

# Conditional frequency distributions with annotation
ggplot(DF0, aes(x = f1, y = freq, fill = f2)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("yellow", "darkorange", "royalblue")) +
  labs(x = "Factor 1", y = "Frequency", fill = "Factor 2") +
  geom_text(data = ypos, aes(y = ypos, label = freq), size = 6)

# Conditional relative frequency distributions
ggplot(DF0, aes(x = f1, y = freq, fill = f2)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_fill_manual(values = c("yellow", "darkorange", "royalblue")) +
  labs(x = "Factor 1", y = "Relative Frequency", fill = "Factor 2") +
  geom_text(data = ypos, aes(y = yrelpos, label = yrelval), size = 6)

# Conditional percent frequency distributions
# Uses a function from the scales package

require(scales, quietly = TRUE)
ggplot(DF0, aes(x = f1, y = freq, fill = f2)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_fill_manual(values = c("yellow", "darkorange", "royalblue")) +
  labs(x = "Factor 1", y = "Relative Frequency", fill = "Factor 2") +
  geom_text(data = ypos, aes(y = yrelpos, label = 100 * yrelval), size = 6) +
  scale_y_continuous(labels = percent)

# Relative and percent frequency charts

# Relative frequency histograms are a PITA - 
# you need to adjust the density in each class by the binwidth.
# When the binwidth is 1, the density histogram *is* the relative
# frequency histogram. Otherwise, the relative frequency in a histogram
# is ..density.. * binwidth. Here's a way to specify a relative
# frequency histogram in ggplot2 (non-faceted!):

DF1 <- data.frame(x = rnorm(1000))

ggplot(DF1, aes(x = x)) +
  geom_histogram(aes(y = ..density.. * 0.2),
                 binwidth = 0.2, fill = "blue") +
  ylab("Relative frequency")

# Unfortunately, you need to specify the value of the binwidth
# explicitly when doing it this way.

# To plot percentages on the y-axis, first plot the y-values as
# proportions and then add
# ... + scale_y_continuous(labels = percent)
#
# where the percent_format() function comes from the scales package

#################################################################


## Linear regression example

# Remove the 5-cylinder cars from the mpg data frame,
# which is built into the ggplot2 package
mpg0 <- subset(mpg, cyl != 5)

# Regress highway mileage on city mileage
m <- lm(hwy ~ cty, data = mpg0)

# Construct the basic plot
# Jittered points + fitted line with 95% confidence limits for
# the conditional mean
p <- ggplot(mpg0, aes(x = cty, y = hwy)) +
  geom_point(position = position_jitter(width = 0.4, height = 0.4)) +
  geom_smooth(method = lm, size = 1)

p    # plots all of the data together
p + facet_wrap(~ cyl)     # facet by no. cylinders

betas <- round(coef(m), 3)   # extract fitted model coefficients
r2 <- round(summary(m)$r.square, 3)
# Create a data frame to pass to ggplot2 for annotation purposes.
# txt consists of character strings representing the LHS of an
# equality, val represents the values on the RHS

# Note: the code used to create the strings comes from plotmath
# Type ?plotmath to view its help page
regout <- data.frame(cty = 10, hwy = c(35, 45, 40),
                     txt = c("R^2 ==", "b[0] ==", "b[1] =="),
                     val = c(r2, betas),
                     stringsAsFactors = FALSE)

# Add information about regression model by pasting the pieces
# together as a character string - parse = TRUE converts the string
# into a plotmath expression
p + geom_text(data = regout, aes(label = paste(txt, val)),
                        size = 6, parse = TRUE, hjust = 0)

# Let's plot the fitted line and R^2 in the overall model
regout2 <- data.frame(cty = 10, hwy = c(45, 40),
                      txt = c(paste0("hat(y) == ",
                                     betas[1], "+ ", betas[2], "~x"),
                              paste0("R^2 == ", r2)),
                      stringsAsFactors = FALSE)
p + geom_text(data = regout2, aes(label = txt), hjust = 0, size = 6,
                parse = TRUE)

# This is too easy - let's do this by cylinder :)

# Function to grab the coefficients and R^2 from a model object m
# with input data d (a subset of mpg0)
foo <- function(d) 
{
   m <- lm(hwy ~ cty, data = d)
   v <- round(c(coef(m), summary(m)$r.square), 3)
   names(v) <- c("b0", "b1", "r2")
   v
}

# Get fitted model coefficients by cyl from mpg0
mcoefs <- ddply(mpg0, .(cyl), foo)

# Next step: construct a data object that constructs the same
# types of strings as in the last plot

formfun <- function(d)
{
  data.frame(cty = 10, hwy = c(45, 40),
             txt = c(paste0("hat(y) == ",
                            d$b0, "+ ", d$b1, "~x"),
                     paste0("R^2 == ", d$r2)),
             stringsAsFactors = FALSE)
}

formdat <- ddply(mcoefs, .(cyl), formfun)

# Let's party!
p + geom_text(data = regout2, aes(label = txt), hjust = 0, size = 6,
              parse = TRUE) +
    facet_wrap(~ cyl)

# Look carefully at what we've done: the hard work was to create
# the first graphic - then we applied a couple of wrapper functions
# and calls to ddply() to generalize the text strings and then
# used facet_wrap() to apply them to all panels. A key step, which
# you may not have noticed, is to include cyl as a variable in
# formdat - this is why geom_text() can map the parsed strings to
# each panel.


## Some fun with geom_rect() and geom_text()
## This example comes from the ggplot2 book, using the
## unemp and presidential data frames.

## When using geom_rect() as a background layer, it's best to
## do it first so that other layers draw on top of it.

presidents <- presidential[-(1:2), ]
presidents$mid <- with(presidents, start + difftime(end, start)/2)
presidents$name[1] <- "Johnson"


yrng <- range(economics$uempmed) # range of unemployment rates
xrng <- with(presidents, c(min(start), max(end)))     # range of dates


unemp <- ggplot(economics, aes(x = date, y = uempmed)) +
   theme_bw() +
   geom_rect(aes(x = NULL, y = NULL, 
                xmin = start, xmax = end, fill = party), 
             ymin = -Inf, ymax = Inf, 
             data = presidents)  +
   geom_line(size = 1) + 
   geom_vline(data = presidents, aes(xintercept = as.numeric(start)),
              color = "grey50") +
   labs(x = "", y = "No. unemployed (1000s)", fill = "Party") + 
   scale_fill_manual(breaks = unique(presidents$party),
                     values =  alpha(c("blue", "red"), 0.2)) +
   geom_text(aes(x = mid, y = yrng[1], label = name), 
             data = presidents, size = 4, vjust = 0) +
   theme(panel.grid.major = element_blank()) +
   scale_x_date(limits = xrng)

# Add a caption to the graph
caption <- paste(strwrap("Unemployment rates in the US have 
  varied a lot over the years", 40), collapse="\n")
unemp + geom_text(aes(x, y, label = caption), 
                  data = data.frame(x = xrng[2], y = yrng[2]), 
                  hjust = 1, vjust = 1, size = 4)


