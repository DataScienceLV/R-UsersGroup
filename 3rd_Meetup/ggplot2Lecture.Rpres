Introduction to ggplot2 Graphics
========================================================
author: Dennis Murphy, Ph.D.
date: November 4, 2014

R graphics engines
========================================================

R has two primary graphics engines:

- base graphics (package `graphics`)
- grid graphics (package `grid`)

Both provide low-level graphics capabilities. The `grid` package 
is one of the recommended packages, providing more low-level 
features than base graphics.

Two important graphics packages based on `grid`: 

- `lattice` (Sarkar)
- `ggplot2` (Wickham)


What is ggplot2?
========================================================

- An R package that produces static, 2D publication-quality graphics
- An implementation of a theory of graphics developed by 
  Leland Wilkinson in *The Grammar of Graphics*.
- ggplot2 implements a **layered** grammar of graphics
- The concept of a layer is central to ggplot2


Ways to create ggplots
===========================================================

Two ways to produce a ggplot: 
- `qplot()`
- `ggplot()`

We will only be concerned with the latter. For documentation
on `qplot()`, see
http://ggplot2.org/book/qplot.pdf


Components of the grammar of graphics
===========================================================

The next several slides provide a quick definition of the elements that
constitute Wilkinson's grammar of graphics. These are fundamental to the
philosophy behind `ggplot2`, which is to decouple the data from the
way it is presented. The grammar defines how this is done.


Component 1: Data
=========================================================

When using the `ggplot()` function to initiate a ggplot, the input data
must be a **data frame**. `qplot()` is a bit more flexible, but for
our purposes, an input data frame is required.

We want the data to be arranged in advance so that coding a ggplot is easy.
This sometimes requires the use of data manipulation functions or packages.


Component 2: Aesthetics
=========================================================

Aesthetics represent the data-related visual properties of a graphic.
There are two basic types:

- **positional** (x, y)
- **non-positional/attribute**


Aesthetics can be either *mapped* to a variable or *set* to a constant
value. Non-positional mapped aesthetics produce legend or
colorbar guides by default.

Mapped aesthetics are defined inside an `aes()` function call; aesthetics
that are set are defined outside `aes()`.



Component 3: Geoms (geometric objects)
=========================================================

Geoms control how a geometric object is rendered and where
it is rendered in a graphics region. Examples of geoms include 
points, lines, boxplots, histograms and bar charts.

There are over 30 built-in geoms in ggplot2, all of which are listed
in the ggplot2 on-line help pages:
http://docs.ggplot2.org/current/


Component 4: Stats (statistical transformations)
=========================================================

Stats provide the necessary computations required by geoms 
from the raw data---i.e., the mathematical
infrastructure for geoms.

Every geom has a default stat and every stat has a default geom.

A stat requires a data frame as input and outputs a data frame,
sometimes with additional variables output from the stat.

New variables produced by a stat have the form `..variable..`
(e.g., `..density..`, `..count..`).


Component 5: Facets
=========================================================

Facets partition the graphics region into two or more panels associated
with data subsets arising from one or two grouping variables. The same
general type of graphic is produced for each group.

Two types of faceting in ggplot2:

- `facet_wrap(~ var)`: one faceting variable
- `facet_grid(rowvar ~ colvar)`: one or two faceting variables
- `facet_null()`  (default: one graphics panel)



Faceting (cont.)
==========================================================

`facet_wrap()` uses a one-sided formula; `facet_grid()` uses a
two-sided formula.

In `facet_grid()` with one faceting variable, the "missing"
variable in the formula is specified by a period:

- `facet_grid(. ~ x)`
- `facet_grid(x ~ .)`

Additional options: `nrow`, `ncol`, `scales`, 
                    `labeller` (`facet_grid()` only)



Component 6: Scales and Guides
==========================================================

Guides provide a means of interpreting the aesthetics present in a ggplot.

Scales are associated with particular types of guides:

- positional guides (axes)
- legend guides  (discrete-valued attributes)
- colorbar guides  (continuous-valued attributes)


Scale functions provide control over data-related aspects of
the presentation of a guide.


Component 7: Coordinate systems
=========================================================

A coordinate system describes how (x, y) pairs are mapped to the 
plane of the graphic. 

Functions that start with `coord_` produce coordinate system 
transformations. The default is `coord_cartesian()`, but other
options include `coord_equal()`, `coord_flip()` and `coord_polar()`.

You can also define your own transformation function (advanced).



Component 8: Annotation 
=========================================================

Annotation refers to the addition of text, graphics and other
"one-off" geometric objects to a ggplot. The standard functions used
for annotation are:

- `annotate()`  (adds a single grob to a ggplot)
- `annotation_custom()`  (adds images or other files as grobs)
- `annotation_raster()`  (adds a raster file)
- `annotation_logticks()`  (modifies ticks of a log scale)
- `geom_text()`


Component 9: Positional adjustment
=========================================================

The supported types of positional adjustment of grobs are:

* `position_jitter()`
* `position_stack()`
* `position_dodge()`
* `position_fill()`
* `position_identity()`   (maintains original position)


Component 10: Theming system
=========================================================

The theming system controls the non-data aspects of a ggplot,
such as axis ticks/labels, legend keys or text, the borders of 
graphics panels or the entire graphics region. 

`ggplot2` uses theme functions to control the default appearance 
of a ggplot. You can modify existing themes with the `theme()` 
function (easy) or write your own theme functions (harder).


ggplot2 syntax: general form
=========================================================

The primary functions in `ggplot2` have the general form
`component_type()`. Some examples:

- `geom_point()`
- `stat_contour()`
- `coord_polar()`
- `position_jitter()`
- `annotation_raster()`
- `facet_wrap()`
- `scale_y_continuous()`


Layers
=========================================================

The **layer** is the central concept in ggplot2. It consists of
the following components of the grammar:

- data
- mapping (of variables to aesthetics)
- stat
- geom
- position adjustment

Sometimes, a component is implicit; for example, the typical default
position adjustment is `identity`, which means no adjustment to the
computed position. New plot layers are defined by `stat_xxx()` or
`geom_xxx()` calls.


General syntax of a layer
==========================================================

`layer(geom, geom_params, stat, stat_params, data, mapping, position)`

It is possible to declare `ggplot2` layers explicitly, but this is
rarely done in practice. The `stat`, `geom` and `aes` functions do all
of the work that `layer` could with fewer keystrokes.

A ggplot is typically generated by "adding" layers with the `+` operator.
Layers are conventional R objects and can be saved as such.


Base layer
======================================================


Defined by invoking `ggplot()`:

- establishes the primary data frame
- establishes the mapped aesthetics that are common to
             **all** subsequent layers

Examples:

- `ggplot(data = DF, 
          mapping = aes(x, y, color = grp))`
- `ggplot(data = DF)`
- `ggplot()`


Group aesthetic
=====================================================

Geoms can roughly be categorized as *individual* or *collective* in
character:

- individual geoms render a distinct graphical object for each row
  of the input data frame (e.g., `geom_point()`)
- collective geoms represent multiple observations (e.g., `geom_line()`
  or `geom_polygon()`)
  
  
Group aesthetic (cont.)
=====================================================

The `group` aesthetic is a way to control how geoms interact with
discrete variables. By default, the groups represent the interaction
of all discrete variables in the plot. To provide the user with more
control over the default behavior, the `group` aesthetic was devised.

Typical usage:

- `group = 1`         (a single geometric object)
- `group = variable`  (a geom for each unique value of `variable`)


Transformations in ggplot2
=======================================================

Several types of transformations take place when constructing a ggplot,
in the following order:

- scale transformation (data units to physical units)
- statistical transformation  (`stat` functions)
- coordinate transformation   (`coord` functions)

Coordinate transformations are capable of changing the shape of geoms
as well as the shape of positional axes.


Scales
=======================================================

Scale functions give a user more control over the appearance of guides
(positional axes, legends and colorbars) associated with mapped
aesthetics. They have the general form

```
scale_aesthetic_type()
```

The (long) list of `scale` functions is shown in the on-line help pages.
Some examples:

- `scale_y_continuous()`
- `scale_fill_manual()`
- `scale_x_date()`
- `scale_size_area()`


Standard arguments of a scale function
========================================================

- `breaks`: the values at which tick marks and labels are to be drawn
- `values`: the set of aesthetic values to be used, one per break,
            in a legend guide
- `labels`: the labels to be used at each value of `breaks` in the guide

The foundational scale functions are

- `scale_continuous()`
- `scale_discrete()`

The other scale functions derive from one of these.


Modifying a positional scale
=======================================================

Sometimes it is necessary to transform data but the
transformation is not supported natively in `ggplot2`. This can be done,
but it is an advanced topic that will not be covered here.

Usually, this feature is desired when one wants to make a custom
coordinate transformation. 


Merging legend guides
=======================================================

When two discrete aesthetics have:

- the same set of breaks
- the same labels
- the same legend title

`ggplot2` will merge them into one legend guide. This can be very
convenient in practice.


Theming system
=======================================================

The theming system in `ggplot2` controls the **non-data** aspects of a 
ggplot. There are several built-in *theme functions*:

- `theme_grey()`     (default)
- `theme_bw()`
- `theme_classic()`  (mimics a base graphics plot)
- `theme_minimal()`

One can write a theme function oneself, but it is more often the case that
one wants to modify certain properties of a built-in theme function. 
This can be done with `theme()`.


Theme element functions
=======================================================

Each (complete) theme function defines about 35 properties, each of
which is controlled by one of the following *theme element* functions:

- `element_text()`
- `element_line()`
- `element_rect()`

The *properties* of a theme element can be set or redefined by one of
the above `element_*()` functions. To erase the properties of a theme
element, use the special function `element_blank()`.


Inheritance and relative sizing
=======================================================

The theming system was overhauled in version 0.9.2. Two important new
features were introduced in the revised system:

- inheritance of theme properties
- relative sizing of theme elements

Both of these features simplify code writing when defining a new theme
function or modifying an existing theme function. 



Upsides of ggplot2
=======================================================

- it provides a simple yet powerful system for producing high-quality 
  graphics in R
- the system is based on an established theory of graphics
- it can produce graphics of arbitrary complexity in the confines of 
  the grammar
- the package is well tested and mature
  
  
Downsides of ggplot2
======================================================

- does not do (pseudo) 3-dimensional graphics
- does not produce multiple x- or y-scales (by design!)
- produces only static plots
- feature frozen in March 2014 - new functionality will come from
  user developers
  
  
Next generation: ggvis
=====================================================
  
- web-based graphics system
- a hybrid of concepts from `ggplot2` and the Vega visualization system
- supports shiny graphics
- in active development, not yet full-featured


Resources: Books
========================================================

- Wickham, H. (2009). *ggplot2: Elegant graphics for data analysis*
- Chang, W. (2013). *R Graphics Cookbook.*
- Murrell, P. (2011) *R Graphics (2nd ed.)*
- Wilkinson, L. (2005) *The Grammar of Graphics*


Resources: URLs
=======================================================

- [on-line help pages](http://docs.ggplot2.org/current)
- [ggplot2 short course](http://jofrhwld.github.io/avml2012)
- [Ito and Murphy, 2013](http://www.nature.com/psp/journal/v2/n10/full/psp201356a.html)
- [Version 0.9.0 transition guide](http://cloud.github.com/downloads/hadley/ggplot2/guide-col.pdf)
- Google for more!!


Resources: help groups
=======================================================

- StackOverflow (ggplot2 tag)
- [ggplot2 group](https://groups.google.com/d/forum/ggplot2)

