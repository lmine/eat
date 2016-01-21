import json
from shapely.geometry import Point, shape

with open('london_borough_boundaries.json', 'r') as fp:
	    js = json.load(fp)

# construct point based on lat/long returned by geocoder
point = Point( -0.158681, 51.530468)

i = 0
for feature in js['features']:
    polygon = shape(feature['geometry'])
    if polygon.contains(point):

        print 'Found containing polygon:', feature['properties']['name']
  