###   GETTING STARTED WITH LEAFLET

# To install Leaflet package
install.packages("leaflet")
install.packages("htmlwidgets")

# Activate the library
library(leaflet)
library(htmlwidgets) # not essential, only needed for saving the map as .html
library(tidyverse)
library(googlesheets4)

########################################  TASK NUMBER ONE


# Task 1: Create a Danish equivalent of AUSmap with Esri layers, 
# but call it DANmap. You will need it layer as a background for Danish data points.



l_dan <- leaflet() %>%
  setView(10.85089,55.2339084, zoom = 13)%>%
  addTiles()

for (provider in esri) {
  l_dan <- l_dan %>% addProviderTiles(provider, group = provider)
}
l_dan

DANmap <- l_dan %>%
  addLayersControl(baseGroups = names(esri),
                   options = layersControlOptions(collapsed = FALSE)) %>%
  addMiniMap(tiles = esri[[1]], toggleDisplay = TRUE,
             position = "bottomright") %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  htmlwidgets::onRender("
                        function(el, x) {
                        var myMap = this;
                        myMap.on('baselayerchange',
                        function (e) {
                        myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                        })
                        }") %>% 
  addControl("", position = "topright")

DANmap

######################################## ADD DATA TO LEAFLET

# Before you can proceed to Task 2, you need to learn about coordinate creation. 
# In this section you will manually create machine-readable spatial
# data from GoogleMaps, load these into R, and display them in Leaflet with addMarkers(): 
### Second, read the sheet into R. You will need gmail login information. 
# gs4_deauth()  # to deauthorize to load the spreadsheet into R

gs4_deauth()

# Read in the Google sheet you've edited
places <- read_sheet("https://docs.google.com/spreadsheets/d/1PlxsPElZML8LZKyXbqdAYeQCDIvDps2McZx1cTVWSzI/edit#gid=124710918",
                     col_types = "cccnncnc",  
                     range = "DAM2026")  

glimpse(places)  

# Question 3: are the Latitude and Longitude columns present? Do they contain numeric decimal degrees?
  # Yes they are, and they do contain deciman degrees. 


# If your coordinates look good, see how you can use addMarkers() function to
# load them in a basic map. 
studentmap <-leaflet() %>% 
  addTiles() %>% 
  addMarkers(lng = places$Longitude, 
             lat = places$Latitude,
             popup = paste(places$Description, "<br>", places$Type))

saveWidget(DANmap, "studentmap.html", selfcontained = TRUE)


########################################
######################################## TASK TWO & THREE


# Task 2: Read in the googlesheet data you and your colleagues created
# into your DANmap object (with 11 background layers you created in Task 1).

#&

# Task 3: Can you cluster the points in Leaflet?

# Solution


DANmap%>%
  addMarkers(lng = places$Longitude, 
             lat = places$Latitude,
             popup = paste(places$Description, "<br>", places$Type), clusterOptions = markerClusterOptions()
  )


#TASK 2
#DANmap%>%
    #addMarkers(lng = places$Longitude, 
    #           lat = places$Latitude,
    #           popup = paste(places$Description, "<br>", places$Type),
    #This is reading the dataset into my DANmap object
#TASK 3
    #clusterOptions = markerClusterOptions()
    #This tells leaflet to group nearby markers into clusters

######################################## TASK FOUR

# Task 4: Look at the two maps (with and without clustering) and consider what
# each is good for and what not.

# Your brief answer

#Without cluster 
  #This effect is good for a great overview of the points of places around Denmark. 
#With cluster 
  #It combines the points in clusters on the map when zoomed out
  #This shows were many locations are concentrated around Denmark
  #It is therefore also greater for singling out points in a specific area of Denmark

######################################## TASK FIVE

# Task 5: Find out how to display the notes and classifications column in the map. 

# Solution

DANmap_final <- DANmap%>%
  addMarkers(lng = places$Longitude, 
             lat = places$Latitude,
             popup = paste(
               "<b>Placename:</b>", places$Placename, "<br>",
               "<b>Type:</b>" , places$Type, "<br>",
               "<b>Description:</b>", places$Description, "<br>",
               "<b>Notes:</b>", ifelse(is.na(places$Notes), "None", places$Notes)
             ),
             clusterOptions = markerClusterOptions()
  )


saveWidget(DANmap_final, "DANmap_final.html", selfcontained = TRUE)

######################################## 