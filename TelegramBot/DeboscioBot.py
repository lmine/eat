from datetime import datetime
from DeboscioBotClass import DeboscioBot

import re
import logging
import npyscreen
import curses
import signal




class DeboForm(npyscreen.Form):
	def create(self, *args, **keywords):
		# super(DeboForm, self).create(*args, **keywords)

		self.w1 = self.add(npyscreen.BoxTitle, name="Active Chats", max_width=20, max_height=16, relx=2, rely=2)  
		self.w1.entry_widget.scroll_exit = True
		self.w1.values = []      
		self.w2 = self.add(npyscreen.BoxTitle, name="Chat Details", editable = False, max_width=58, max_height=16, relx=24, rely=2)
		self.w2.entry_widget.scroll_exit = True
		self.w2.values = []  
		self.w3 = self.add(npyscreen.BoxTitle, name="Msgs" , max_width=80, max_height=20)
		self.w3.entry_widget.scroll_exit = True
		self.w3.values = []  
		self.t  = self.add(npyscreen.Autocomplete, name = "Text:", max_width=80)

		self.add_handlers({"^S": self.chatinputenter})

		self.edit()
		#self.keypress_timeout = 10


	def chatinputenter(self, *args):
		if self._get_selected_chat_id(self.w1) <> None:
			self.parentApp.debot.manualbot.sendMessage(self._get_selected_chat_id(self.w1), text=self.t.value)
		self.t.value=''


	def on_ok(self):
		raise ValueError('Killing myself...')


	def on_cancel(self):
		raise ValueError('Killing myself...')

	
	def _get_selected_chat_id(self, obj):
		if obj.entry_widget.value == None:
			return None
		elif isinstance(obj.entry_widget.value, list):
			return obj.entry_widget.values[obj.entry_widget.value[0]]
		elif isinstance(obj.entry_widget.value, int):
			return obj.entry_widget.values[obj.entry_widget.value]
		else:
			return None


	def while_waiting(self):
		self.w1.values = [chat_id for chat_id in self.parentApp.debot.chats]

		current_chat_id = self._get_selected_chat_id(self.w1)
		self.w1.display()
		
		if (current_chat_id <> None):
			# self.w3.values = [self.debot.chats[current_chat_id].message_count]		
			tmp = []
			for user_id in self.parentApp.debot.chats[chat_id].users:
				user = 	self.parentApp.debot.users[user_id]
				if user.enabled:
					enabled_flag = '(*)'
				else:
					enabled_flag = '( )'
				tmp.append(enabled_flag + ' ' + str(user.id) + " " + user.first_name)
			self.w2.values = tmp
			self.w2.display()

			self.w3.values = self._get_messages(current_chat_id)
			self.w3.display()

	def _get_messages(self, chat_id):
		tmp = [str(msg.message_id) + " " + str(msg.date) + " (" + msg.from_user.first_name +") : " + msg.text for msg in self.parentApp.debot.chats[chat_id].messages]
		return tmp[::-1]


class TestApp(npyscreen.NPSAppManaged):

	def __init__(self, debot):
		self.debot = debot				

		self.F = None
		self.w1 = None
		self.w2 = None

	def main(self):

		self.keypress_timeout_default = 10

		#self.F = DeboForm(parentApp=self, name = "Welcome to DeboscioBot Master Console", )
		self.addForm("MAIN", DeboForm, name="Welcome to DeboscioBot Master Console", color="IMPORTANT",)
		#self.F = npyscreen.Form.create(name = "Welcome to DeboscioBot Master Console", )



def signal_handler(signum, frame):
	print("exit")
	debot.bot.stop()
	raise ValueError('11111Parameter should...')


signal.signal(signal.SIGINT, signal_handler)

debot = DeboscioBot('156902885:AAHBx4JrD1q35xMHrHjH_tsAe760j2f2Uz4')

# Start the Bot
debot.bot.start_polling()

	# Run the bot until the you presses Ctrl-C or the process receives SIGINT,
	# SIGTERM or SIGABRT. This should be used most of the time, since
	# start_polling() is non-blocking and will stop the bot gracefully.


# App = TestApp(debot)
# App.run()

debot.bot.idle()
