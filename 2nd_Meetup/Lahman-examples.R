library(tidyr)
library(dplyr)
library(Lahman)

### Some extended examples re dplyr using the Lahman baseball database


### Problem 1:
###   Get the season batting statistics for the 2013 Los Angeles Dodgers,
###   including slugging percentage, on-base percentage and their sum OPS.
###   Restrict to players with at least 50 official at bats and sort by
###   descending OPS.

batting <- tbl_df(Batting) %>% 
              select(playerID, yearID, teamID, lgID, G, AB:SB, BB:SF)
player_names <- tbl_df(Master) %>% 
                  select(playerID, nameFirst, nameLast, bats, throws)

LAD13 <- batting %>% 
            filter(yearID == 2013, teamID == "LAN", AB > 50) %>%
            mutate(BA = round(H/AB, 3), 
                   TB = H + X2B + 2 * X3B + 3 * HR,
                   SLG = round(TB/AB, 3),
                   OBP = round((H + BB + HBP)/(AB + BB + HBP), 3),
                   OPS = SLG + OBP) %>%
            select(-TB)
LAD13btg <- inner_join(player_names, LAD13) %>%
                select(-throws, -contains("ID")) %>%
                arrange(desc(OPS))


### Problem 2:
###   Get the season pitching statistics for the 2012 Colorado Rockies,
###   sorted by ERA.

pitching <- tbl_df(Pitching) %>%
               select(playerID, yearID, teamID:GS, SV:SO, ERA:HBP)

COL12 <- pitching %>%
            filter(yearID == 2012, teamID == "COL") 
COL12ptch <- inner_join(player_names, COL12) %>%
                select(-bats, -contains("ID")) %>%
                arrange(ERA)


### Problem 3:
###   Season attendance per game by team from 2006-2010, National League,
###   sorted by team abbreviation

teams <- tbl_df(Teams) %>%
            select(teamID, yearID, lgID, Ghome, attendance)

NLattend <- teams %>% 
   filter(yearID %in% 2006:2010, lgID == "NL") %>%
   mutate(teamID = factor(teamID),
          APG = round(attendance/Ghome)) %>%
   select(-lgID, -Ghome, -attendance) 

## Use the spread() function to show the table in 'wide' form
NLattend %>% spread(yearID, APG)

## Plot these over time

library(ggplot2)
ggplot(NLattend, aes(x = yearID, y = APG, color = teamID)) +
#    theme_bw() +
    geom_line(size = 1) +
    scale_color_manual(values = rainbow(16)) +
    theme(panel.background = element_rect(fill = "black"),
          panel.grid.major = element_line(colour = "grey60"),
          panel.grid.minor = element_line(colour = "grey50"),
          plot.background = element_rect(fill = "grey90"),
          legend.key = element_rect(fill = "black")) +
    labs(x = "Year", y = "Average attendance per game",
         color = "Team ID")


###

