# Comparison of ggplot2 and ggvis code for the same 
# scatterplot smooth graphic

library(ggplot2)
ggplot(mtcars, aes(x = disp, y = mpg)) +
  geom_point(color = "blue") +
  geom_smooth(color = "darkblue", size = 1)

library(dplyr)
library(ggvis)
mtcars %>% ggvis(x = ~ disp, y = ~ mpg) %>%
  layer_points(stroke := "blue", size := 50) %>%
  layer_smooths(stroke := "darkblue", strokeWidth := 3, se = TRUE)


### Fun with the compute functions

mpg %>% compute_tabulate(~ factor(cyl))  # cyl coerced to factor

mtcars %>% compute_model_prediction(mpg ~ bs(disp, 5), model = "lm")

mpg %>% compute_count(~ cyl)   # cyl is numeric

hec <- as.data.frame(xtabs(Freq ~ Hair + Eye, HairEyeColor))
hec %>% compute_stack(stack_var = ~ Freq, group_var = ~ Hair)

# Extra example
InsectSprays %>% group_by(spray) %>%
  compute_boxplot(~ count)




# Examples using different layer functions


### Simple layers

# Points
# Remove 5 cylinder cars
filter(mpg, cyl != 5) %>% 
  ggvis(x = ~ displ, y = ~ hwy, fill = ~ factor(cyl)) %>%
  layer_points(stroke := "black", strokeWidth := 1,
               size := 100)

# Paths and polygons
DF0 <- data.frame(x = c(2, 5, 6, 8, 7, 4),
                 y = c(3, 6, 9, 11, 7, 2))
p <- DF0 %>% ggvis(x = ~ x, y = ~ y)
p %>% layer_paths()     # path 
p %>% layer_paths(fill := "blue", fillOpacity := 0.5)  # polygon

# Text
# Add state names as a variable to USArrests
# Note that the text property is always unscaled
usarrests <- data.frame(state = rownames(USArrests), USArrests,
                        stringsAsFactors = FALSE)
usarrests %>% ggvis(x = ~ UrbanPop, y = ~ Assault) %>%
              layer_text(text := ~ state)

### Compound layers

# Histogram
mpg %>% ggvis(x = ~ hwy) %>% 
        layer_histograms(fill := "blue", width = 2.5)

# Bar chart
diamonds %>% ggvis(x = ~ cut) %>%
             layer_bars(fill := "firebrick")

# Density estimates
mpg %>% ggvis(x = ~ displ) %>%
        layer_densities(stroke := "blue", strokeWidth := 2)

filter(mpg, cyl != 5) %>% 
    group_by(factor(cyl)) %>%   # groupwise density estimates
    ggvis(x = ~ displ, fill = ~ factor(cyl)) %>%
    layer_densities()

# Box plots
InsectSprays %>% ggvis(x = ~ spray, y = ~ count) %>%
                 layer_boxplots(fill = ~ spray) 

# Notice how width can be set and the whiskers are aligned
# with x-value. Try this with the previous example.
mpg %>% ggvis(x = ~ cyl, y = ~ hwy) %>%
        layer_boxplots(width = 0.5, fill = ~ factor(cyl))

# Lines
# compare to layer_paths above - same data!
DF0 %>% ggvis(~ x, ~ y) %>% layer_lines()  

# layer_model_predictions
# Useful for plotting several model predictions on same graph
library(splines)
filter(mpg, cyl != 5) %>%
   ggvis(x = ~ displ, y = ~ hwy) %>%
   layer_points(fillOpacity := 0.3) %>%
   layer_smooths(se = FALSE, stroke := "blue") %>%
   layer_model_predictions(model = "lm", stroke := "black") %>%
   layer_model_predictions(model = "MASS::rlm", stroke := "red")


### Data pipelining during visualization

# Example: Adding groupwise smooths to overall smooth
filter(mpg, cyl != 5) %>%
    ggvis(x = ~ displ, y = ~ hwy) %>%
    layer_smooths(strokeWidth := 3, se = TRUE) %>%  # average smooth
    group_by(factor(cyl)) %>%    # set up grouping for points/smooths
    layer_points(fill = ~ factor(cyl), stroke = ~ factor(cyl),
                   fillOpacity := 0.4, strokeOpacity := 0.7) %>%
    layer_smooths(stroke = ~ factor(cyl))



### Interactivity


### Histogram with variable binwidths

slider_box <- input_slider(0.5, 10, value = 3, 
                           step = 0.5, label = "Bin width")

mpg %>% ggvis(x = ~ hwy) %>%
        layer_histograms(width = slider_box, fill := "darkorange")


### Loess smooth with variable span

slider_box <- input_slider(0.2, 1, value = 0.5, label = "Span")
mpg %>% ggvis(x = ~ displ, y = ~ hwy) %>%
        layer_points(fillOpacity := 0.3) %>%
        layer_smooths(stroke := "blue", strokeWidth := 2,
                      span = slider_box)


### kernel density estimates with variable bandwidth

# Define a slider and a select box
sliderBox <- input_slider(0.1, 2, value = 1, step = 0.1,
                          label = "Bandwidth")
# First argument is a vector of name-value pairs
selectKernel <- input_select(c("Gaussian" = "gaussian",
                               "Epanechnikov" = "epanechnikov",
                               "Rectangular" = "rectangular",
                               "Biweight" = "biweight",
                               "Cosine" = "cosine",
                               "Optcosine" = "optcosine"),
                             label = "Kernel function")
filter(mpg, cyl != 5) %>% 
  ggvis(x = ~ hwy) %>%
  layer_densities(adjust = sliderBox, kernel = selectKernel)


## Adding tooltips

# Function to specify what is to be visualized when a
# point is hovered over
all_values <- function(x)
{
    if(is.null(x)) return(NULL)
    paste0(names(x), ": ", format(x), collapse = "<br />")
}

mtcars %>% ggvis(x = ~ wt, y = ~ mpg) %>%
           layer_points(fill.hover := "red") %>%
           add_tooltip(all_values, "hover")



# Integration with Shiny

library(shiny)

        
df <- data.frame(x = runif(20), y = runif(20))
# Basic dynamic example
mtc1 <- reactive({
  invalidateLater(200, NULL);
  
  df$x <<- df$x + runif(20, -0.05, 0.05)
  df$y <<- df$y + runif(20, -0.05, 0.05)
  df
})
ggvis(mtc1, props(x = ~x, y = ~y)) +
  layer_points() +
  scale_numeric("x",  domain = c(0, 1))


## reactive ggvis

library(shiny)   # for the reactive() function

dat <- data.frame(time = 1:10, value = runif(10))

# Create a reactive that returns a data frame, adding a new
# row every 0.5 seconds
ddat <- reactive({
  invalidateLater(500, NULL)
  dat$time <<- c(dat$time[-1], dat$time[length(dat$time)] + 1)
  dat$value <<- c(dat$value[-1], runif(1))
  dat
})
ddat %>% ggvis(x = ~time, y = ~value, key := ~time) %>%
  layer_points() %>%
  layer_paths()

#########################################################
### Hands-on exercises

# 1. Add points with blue color and a loess smoother
mtcars %>% ggvis(x = ~ wt, y = ~ mpg) %>%

  
# 2. Compute predicted values by level of cyl for a linear
#    model and then plot it.
mtcars %>% group_by() %>%
           compute_model_prediction()



