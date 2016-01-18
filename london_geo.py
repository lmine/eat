import json
from shapely.geometry import Point, shape

with open('london_boundaries.json', 'r') as fp:
	    js = json.load(fp)

# construct point based on lat/long returned by geocoder
point = Point( -0.158681, 51.530468)


for feature in js['features']:
    polygon = shape(feature['geometry'])
    if polygon.contains(point):
        feature['name'] = 'AAA'
        print 'Found containing polygon:', feature
        



