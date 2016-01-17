# Place gathering and visualize
from googleplaces import GooglePlaces, types, lang
import cPickle as pickle
import json
import time


# AIzaSyB18YNnS59cL8dVFpOoIGXfATCyvITSbFU
# AIzaSyAyUHMfzObyhHxRGRzsIq80fcUDvAg4RvE
# AIzaSyBwZJYoDRuzSBPKvydsIaI9gectJ8vPCyk
# AIzaSyBuX6A63KMI63EgnDcS5He5AfPgltE1Lz4
# AIzaSyBTZG5t73rg_6q0XOsRv9pPOUoRsb7nbOo
# AIzaSyBVe6JKhw13H2uGgV2kcaEmfOj0Xx05qhU

results = dict()
google_places = GooglePlaces('AIzaSyBTZG5t73rg_6q0XOsRv9pPOUoRsb7nbOo')

lat_start = 51.463468 #51.517468 - 10*0.0004
lng_start =  -0.043681  # -0.133681


# long_center = -0.153681 # -0.103681
# lat_center = 51.493468

position = {'lat': lat_start , 'lng': lng_start}

# last point 51.514333 - -0.143041


#position = {'lat': 51.514333 , 'lng':-0.133681}

try:
	with open('Eatplaces_greenwich.json', 'r') as fp:
	    results = json.load(fp)
except Exception as inst:
	print "New File	" , inst
	pass

if 'start_position' in results:
	print("resuming start corner")
	lat_start = results['start_position']['lat']
	lng_start = results['start_position']['lng']

if 'current_position' in results:
	print("resuming start position")
	lat_inc_start = results['current_position']['lat']
	lng_inc_start = results['current_position']['lng']
else:
	lat_inc_start = 0
	lng_inc_start = 0

results['start_position'] = {'lat': lat_start , 'lng': lng_start}

print("Start step %d - %d" % (lat_inc_start ,lng_inc_start))

try:

	for lat_inc in range(0,40):

		position['lat'] = lat_start + lat_inc*0.0014

		for lng_inc in range(0, 30):
			
			if (lat_inc < lat_inc_start) | ((lat_inc <= lat_inc_start) & (lng_inc < lng_inc_start)) :
				# Already scanned area
				continue		
			
			position['lng'] = lng_start + (lat_inc % 2)*0.002/2  + lng_inc*0.002
			
			last_query_result = google_places.nearby_search(lat_lng = position, radius=120, types=[types.TYPE_FOOD])			

			num_results = len(last_query_result.places)
			print ("Current step %d - %d %f - %f: Found %d results" % (lat_inc, lng_inc, position['lat'], position['lng'], num_results))

			for place in last_query_result.places:
				if not place.place_id in results:
					place.get_details()
					
					rating = -1
					price_level = -1

					if 'rating' in place.details:
						rating =  float(place.details['rating'])

					if 'price_level' in place.details:
						price_level = float(place.details['price_level'])

					geo_location = {'lat': float(place.geo_location['lat']), 'lng': float(place.geo_location['lng'])}

					details = {'name':place.name, 'geo_location': geo_location, 'rating': rating, 'price_level': price_level}
					
					results[place.place_id] = details

					print("Found new places: %s." % details['name'])

			results['current_position'] = {'lat': lat_inc , 'lng': lng_inc}



except Exception as inst:
	print "some Error" , inst
	pass

with open('Eatplaces_greenwich.p', 'wb') as fp:
    pickle.dump(results, fp)

with open('Eatplaces_greenwich.json', 'w') as fp:
	json.dump(results,fp)