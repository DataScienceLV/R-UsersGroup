## Examples for LVRUG meetup, Nov. 4, 2014
## All examples use either generated or built-in R/ggplot2 data frames


################## Single-layer plots ######################

set.seed(5409)   # for reproducibility
DF <- data.frame(gp = sample(LETTERS[1:3], 1000, replace = TRUE),
                  x = rnorm(1000))

##############################
# Bar chart of gp

ggplot(DF, aes(x = gp)) + geom_bar(fill = "darkorange")


# Other ways to make this plot by modifying base layer
# These are more relevant in multi-layer ggplots

# Pass aesthetic mapping to the geom - makes it local
ggplot(DF) + geom_bar(aes(x = gp), fill = "darkorange")

# Pass both the data and the aesthetic mapping to the geom
# Both the data and mapping are local to geom_bar()
ggplot() + geom_bar(data = DF, aes(x = gp), fill = "darkorange")
##############################

# Histogram of x + plot title
ggplot(DF, aes(x = x)) +
  geom_histogram(binwidth = 0.2, fill = "purple") +
  ggtitle("Standard normal simulated data")

# What happens if we map an aesthetic that should be set?
ggplot(DF, aes(x = x)) +
  geom_histogram(binwidth = 0.2, aes(fill = "purple")) 
 
# Kernel density plot of x
ggplot(DF, aes(x = x)) +
  geom_density(color = "blue", size = 1)


### qplot() is useful for single-layer plots, but 
### set aesthetics have to be protected by I()

qplot(x, data = DF, geom = "histogram", fill = I("purple"),
         binwidth = I(0.2))

qplot(x, data = DF, geom = "density", colour = I("blue"), size = I(1))


#################### Two-layer plots #######################

# Data and aesthetics are common to both layers, so specify
# in ggplot()
# ..density.. is a variable created by stat_bin(), the stat
# associated with geom_histogram()
pp <- ggplot(DF, aes(x = x, y = ..density..)) +
        theme_bw() +
        geom_histogram(binwidth = 0.2, fill = "skyblue") 

#################################################################
# Add density plots in various ways
pp + geom_density(color = "darkorange", size = 1)

# Density plots often look better with fill color
# Add scales package for next example to access alpha() function

library(scales)
ggplot(DF, aes(x = x)) +
   geom_density(color = "darkorange", fill = alpha("orange", 0.4))

# Histogram + density plot without line at bottom
pp1 <- pp + stat_density(geom = "path", color = "darkorange", size = 1)

# Add a standard normal pdf to histogram
pp1 + stat_function(fun = dnorm, size = 1, color = "blue")

## Hmmm...problem. We used ..density.. as the y-aesthetic and 
## stat_function() picked up on that. Let's try again....

ggplot(DF, aes(x = x)) +
  theme_bw() +
  geom_histogram(aes(y = ..density..), binwidth = 0.2, fill = "skyblue") +
  stat_density(geom = "path", color = "darkorange", size = 1) +
  stat_function(fun = dnorm, color = "blue", size = 1)

# Moral: Sometimes mapped aesthetics need to be localized.
###################################################################

# New example: (jittered) stripcharts and boxplots

# Boxplots and jittered points by gp
# First example where a legend guide is produced
# geom_boxplot() 'understands' the fill aesthetic,
# geom_point() does not (with a certain exception)

ggplot(DF, aes(x = gp, y = x, fill = gp)) +
  geom_boxplot(outlier.colour = NA) +  # need 'colour' here
  geom_point(position = position_jitter(width = 0.1))

# How about connecting the group medians with a line?
# Problem 1: gp is a factor.  By default, ggplot2 does not plot
#            lines across factor levels.
#   Solution: Use the group aesthetic.
# Problem 2: The medians are not in the data. 
#   Solution: Use stat_summary() to compute them in ggplot2.

last_plot() + 
  stat_summary(fun.y = median, aes(group = 1), geom = "line",
               colour = "blue", size = 1)



################### Section 3: Faceting #####################
#############################################################

# facet_wrap() facets by levels of one categorical variable,
# but one can optionally 'wrap' plots into multiple rows or columns

# Facet by gp
pp1 + facet_wrap(~ gp)
pp1 + facet_wrap(~ gp, nrow = 2)
pp1 + facet_wrap(~ gp, ncol = 2)

# Manipulate display of x/y scales
pp1 + facet_wrap(~ gp, ncol = 2, scales = "free_y")
pp1 + facet_wrap(~ gp, ncol = 2, scales = "free")



############# Section 4: Basic use of scales ###############

# (a)  Positional scales: 
#      Need to pay attention to class of x or y variable
#
# Typical arguments in positional scales:
#   * breaks    where to position the axis ticks
#   * labels    how to label the axis tick labels

# Example of use of a log 10 scale

ggplot(ChickWeight, aes(x = Time, y = weight, group = Chick)) +
    geom_line()
last_plot() + scale_y_log10()    # built-in scale type

# Better (ignore the warning)
last_plot() + scale_y_log10(breaks = c(50, 100, 200, 300))

# Example of relabeling a factor in an x-scale

ggplot(InsectSprays, aes(x = spray, y = count)) +
    geom_boxplot(aes(fill = spray)) +
    scale_x_discrete(labels = paste("Spray", levels(InsectSprays$spray))) +
    labs(x = "Treatment", y = "Count", fill = "Spray",
         title = "Box plots of insect spray distributions") 


## Examples of attribute scales

## Standard arguments for legend guides:
#    - breaks: levels/values of mapped variable
#    - values: values of the _aesthetic_ to associate with breaks
#    - labels: legend key labels to associate with breaks

# Color lines by diet and customize legend color

ggplot(ChickWeight, aes(x = Time, y = weight, group = Chick, color = Diet)) +
   geom_line() +
   scale_color_manual(values = c("blue", "orange", "darkgreen", "brown"))

# In this case, it may be better to facet:

ggplot(ChickWeight, aes(x = Time, y = weight, group = Chick)) +
  geom_line() + facet_wrap(~ Diet, ncol = 2)

# Example with two legends

ggplot(mpg, aes(x = displ, y = hwy, shape = factor(year), size = cyl)) +
   geom_point() +
   scale_shape_manual(values = c(1, 16))

# Apply a few tweaks
# Note: the color and shape legends are merged
ggplot(mpg, aes(x = displ, y = hwy, shape = factor(year), size = cyl)) +
  geom_point(position = position_jitter(width = 0.1, height = 0.1)) +
  scale_size(range = c(2, 4)) +
  scale_shape_manual(values = c(1, 16)) +
  labs(x = "Engine displacement", y = "Highway mileage",
       shape = "Year", size = "Cylinders", color = "Year") +
  geom_smooth(aes(group = year, color = factor(year)), se = FALSE, size = 1)

# scale_identity() uses the given values in the data to be 
# values of the aesthetic in the legend

ggplot(mpg, aes(x = displ, y = hwy, shape = factor(year), size = cyl)) +
  geom_point(position = position_jitter(width = 0.1, height = 0.1)) +
  scale_size_identity() +
  scale_shape_manual(values = c(1, 16)) +
  labs(x = "Engine displacement", y = "Highway mileage",
       shape = "Year", size = "Cylinders", color = "Year") 

# By default, scale_identity() does not produce a legend. To get one,
# use guide = "legend"

last_plot() + scale_size_identity(guide = "legend")


# Example of a continuous aesthetic

ggplot(mpg, aes(x = displ, y = hwy)) +
   geom_point(aes(color = displ))

last_plot() + 
  scale_color_gradient2(low = "blue", mid = "darkorange", high = "yellow")

# Problem is that default midpoint is zero, so reset:
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = displ),
             position = position_jitter(width = 0.1, height = 0.1)) +
  scale_color_gradient2(low = "blue", mid = "darkorange", high = "yellow",
                        midpoint = 4.5)


#################################################################

# An example using the theming system

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(position = position_jitter(width = 0.1, height = 0.1)) +
  labs(x = "Engine Displacement", y = "Highway Mileage") +
  ggtitle("Highway mileage vs. displacement") +
  theme(axis.title = element_text(size = rel(1.2)),
        axis.text = element_text(size = rel(1.2)),
        axis.text.y = element_text(face = "bold.italic"),
        plot.title = element_text(size = 20, face = "italic", 
                                  hjust = 0))





