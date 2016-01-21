from googleplaces import GooglePlaces, types, lang
from random import randint, sample

class WhereToEat:

	def __init__(self, api_key):
		self.google_places = GooglePlaces(api_key)
		self.name = None
		self.geo_location = None
		self.user_results = dict()

		pass

	def find_places(self, chat_id, user_id, latitude, longitude, max_results):
		position = {'lat': latitude, 'lng':longitude}
		self.last_query_result = self.google_places.nearby_search(lat_lng = position, radius=500, types=[types.TYPE_FOOD])			

		num_results = len(self.last_query_result.places)

		if num_results < max_results:
			max_results = num_results

		results = []
		
		self.user_results[user_id] = []

		for i in sample(range(num_results),max_results):
			place = self.giveme(i)
			self.user_results[user_id].append(place)
			results.append([place['name'], place['rating'], place['price_level']])				

		print results

		return self._results_layout(results)

	def _results_layout(self, results):
		out = []
		for i, result in enumerate(results):
			text_layout = "%d - %s R: %.1f P: %.1f" % (i+1, result[0], result[1], result[2])
			out.append(text_layout)
		return out

	def giveme(self, position = 0):
		if (position>len(self.last_query_result.places)):
			return None

		selected_place = self.last_query_result.places[position]
		selected_place.get_details()
		print selected_place.details 
		place = dict()

		place['name'] = selected_place.name
		place['geo_location'] = selected_place.geo_location

		if 'rating' in selected_place.details:
			place['rating'] =  selected_place.details['rating']
		else:
			place['rating'] = -1

		if 'price_level' in selected_place.details:
			place['price_level'] = selected_place.details['price_level']
		else:
			place['price_level'] = -1
		
		return place

	def add_place():
		pass

	def rate_place():
		pass

	def remove_place():
		pass

	def select_place(self, chat_id, user_id, is_admin, msg):
		if not msg[0].isdigit():
			return
		
		answer = int(msg[0])-1
		print(self.user_results[user_id][answer])
		return self.user_results[user_id][answer]['geo_location']

	def test():
		pass