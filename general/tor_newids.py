#!/usr/bin/python3
"""
Created on Thu Apr  5 13:06:02 2018
# -*- coding: utf-8 -*-
@author: koenig
"""

import getpass
import pycurl
import io
import time
import sys
import re

from stem import Signal
import stem
import stem.connection
import stem.process
from stem.control import Controller
from stem.util import term

SOCKS_PORT = 9050
CONTROL_PORT = 9051
CAN_CONNECT = True
HAS_OPENED_CUSTOM = False

def query(url):
	"""
	Uses pycurl to fetch a site using the proxy on the SOCKS_PORT.
	"""

	output = io.BytesIO()
	
	query = pycurl.Curl()
	query.setopt(pycurl.URL, url)
	query.setopt(pycurl.PROXY, 'localhost')
	query.setopt(pycurl.PROXYPORT, SOCKS_PORT)
	query.setopt(pycurl.PROXYTYPE, pycurl.PROXYTYPE_SOCKS5_HOSTNAME)
	query.setopt(pycurl.WRITEFUNCTION, output.write)
	try:
		query.perform()
		return output.getvalue()
	except pycurl.error as exc:
		return "Unable to reach %s (%s)" % (url, exc)

def checkExit():
	print(term.format("Checking our endpoint:", term.Attr.BOLD))
	#print(term.format(query("https://www.atagar.com/echo.php"), term.Color.BLUE))
	print(term.format(query("https://oneric.de/echoIP.php"), term.Color.BLUE))
	

def connectAndAuthenticate():
	try:
		controller = Controller.from_port(port = CONTROL_PORT)
	except stem.SocketError as exc:
		print("Unable to connect. Is TOR running ?\n")
		sys.exit(1)
	
	try:
		controller.authenticate()
	except stem.connection.MissingPassword:
		pw = getpass.getpass("Controller password: ")
		try:
			controller.authenticate(password = pw)
		except stem.connection.PasswordAuthFailed:
			print("Unable to authenticate, password is incorrect!\n")
			sys.exit(1)
	except stem.connection.AuthenticationFailure as exc:
		print("Unable to authenticate: %s\n" % exc)
		sys.exit(1)
	
	print(term.format("TOR version: %s\n" % controller.get_version(), term.Attr.BOLD))
	return controller


def bootstrapLog(line):
	if "Bootstrapped " in line:
		print(term.format(line, term.Color.GREEN))
	if "Done" in line:
		global CAN_CONNECT
		CAN_CONNECT = True


def launchNewWithExit(exit):
	global controller
	global HAS_OPENED_CUSTOM
	global CAN_CONNECT
	controller.signal(Signal.SHUTDOWN)
	CAN_CONNECT = False
	print("Wait for current tor process to shutdown.")
	time.sleep(3)
	tor_process = stem.process.launch_tor_with_config(
		config = {
			'SocksPort': str(SOCKS_PORT),
			'ExitNodes': str(exit),
			'ControlPort': str(CONTROL_PORT)
		},
		init_msg_handler = bootstrapLog,
	)
	HAS_OPENED_CUSTOM = True
	while not CAN_CONNECT:
		print('.', end='', flush=True)
		time.sleep(1.5)
	controller = connectAndAuthenticate()
	

if __name__ == '__main__':
	controller = connectAndAuthenticate()
	print(term.format("WARNING: Using this script to change exit country may disregard settings from your original torcc file !", term.Color.RED))
	
	inp = "g"
	while inp != "q":
		print("...")
		if inp.startswith("{") and inp.endswith("}"):
			launchNewWithExit(inp)
		elif re.match('^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(,\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})*)', inp) != None:
			launchNewWithExit(inp)
		else:
			if not controller.is_newnym_available():
				print("Wait for NEWNYM to be available ...\n")
				time.sleep(controller.get_newnym_wait())
			controller.signal(Signal.NEWNYM)
			time.sleep(1)
			
		checkExit()
		inp = input("[ENTER: NEWNYM / {..}: for new exit country / q: quit]:")
		
	if HAS_OPENED_CUSTOM:
		controller.signal(Signal.SHUTDOWN)
	controller.close()
	print("Exit.\n")
