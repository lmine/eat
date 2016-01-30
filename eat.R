input = RJSONIO::fromJSON("Eatplaces.json")
a = input[sapply(input, length)>2]

require("geojson")
regions_df = geojson_read("eat/london_borough_boundaries.geojson", what = "sp")

regions_l = list()

for (i in 0:length(regions_df)){
  regions_l[i] = SpatialPolygons(regions_df@polygons[i],proj4string = regions_df@proj4string)
}


contains <-function(regions, point ){
  
  sp <- SpatialPoints(point)
  output = -1
  
  for (region in regions){
    if (gContains(region,sp)==TRUE){
      output = strtoi(region@polygons[[1]]@ID,10L)
      break
    }
  }
  
  output  
  
}

rm(regions_df)



library('plyr')
library('reshape2')

require("ggmap")
library(ggmap)
require("leaflet")
require("stringr")

long = list()
lat = list()
price = list()
rating = list()
name = list()
region = list()

for (i in 1:length(a)){
  #''position = {'lat': 51.517468, 'lng':-0.133681}'
  
  long[i] = a[[i]]$geo_location[2]
  lat[i] = a[[i]]$geo_location[1]  
  price[i] = a[[i]]$price_level
  rating[i] = a[[i]]$rating
  name[i] = a[[i]]$name
  
#  region[i] = contains(regions_l,data.frame(lon=long[[i]], lat=lat[[i]]))
  
}

london_eat = data.frame( "lon" = unlist(long), 
                         "lat" = unlist(lat), 
                         "price" = unlist(price),
                         "rating" = unlist(rating), 
                         "name" = unlist(name)
                         "region" = unlist(region))

names(london_eat) = c('lon','lat','price','rating','name','region')

long_center = -0.1220681
lat_center = 51.520468

london_eat=london_eat[london_eat$lon > long_center - 0.1 & london_eat$lon < long_center + 0.2 & 
                        london_eat$lat > lat_center - 0.2 & london_eat$lat < lat_center + 0.2 
                        ,]



lond = c(lon = long_center, lat =  lat_center)
lond = c(long_center - 0.1,lat_center - 0.05, long_center + 0.1 , lat_center + 0.05)
lond.map = get_map(location = lond,  color = "bw", maptype = "toner")

# qmplot(lon , lat , data = london_eat, color = I("red"), zoom = 14, alpha=0) 


# 

qmplot(lon , lat , data = london_eat, color = I("red"), zoom = 14, alpha=1) 
ggmap(lond.map) %+% london_eat + aes(x = lon, y = lat) +
  geom_density2d() +
  stat_density2d(aes(fill = log(..level..), alpha = log(..level..)),size = 0.05, n=100, geom = 'polygon') +
  scale_fill_gradient(low = "green", high = "red") +
  scale_alpha(range = c(0.00, 0.25), guide = FALSE)


pal <- colorNumeric(
  palette = "Reds",
  domain = london_eat$rating
)


leaflet(data = london_eat) %>% addTiles() %>%
  addCircles(~lon, ~lat, opacity =  0.5, fillOpacity = 0.5, radius = 10,
             fillColor =~pal(rating),  color=~pal(rating))



# wtf coords

51.517468 - 10 *0.00005, 'lng':-0.133681

long = list()
lat = list()
value = list()
long_center = -0.158681 # -0.103681
lat_center = 51.530468 # 51.582468 - 10*0.0005
i=0
for (x in 0:60){
  for (y in 0:40){
    long[i] = long_center + 0.0015/2 * (y %% 2) + x * 0.0015
    lat[i] = lat_center  + y * 0.0010
    0.0005 * (y %% 2) 
    value[i] = 1
    i = i+1
  }
}


london_eat = data.frame( "long" = unlist(long), "lat" = unlist(lat), "value" = unlist(value))
names(london_eat) = c('long','lat','value')

london_eat=london_eat[london_eat$long > long_center - 1 & london_eat$long < long_center + 1 & 
                        london_eat$lat > lat_center - 1 & london_eat$lat < lat_center + 1,]


leaflet(data = london_eat) %>% addTiles() %>%
  addCircles(~long, ~lat,color="red")