#!/usr/bin/env python3
# For the portable
# Usage: python3 piMusicTest.py 
# Note: to fiddle around with button sensitivity settings, use ~/.local/lib/python3.9/site_packages/adafruit_mpr121.py
import RPi.GPIO as GPIO
import time
import math
import pygame, sys
import mutagen.oggvorbis as mutogg
import mysql.connector
import signal
import traceback
import os
import sys
from pygame.locals import *
from luma.core.interface.serial import i2c
from luma.core.render import canvas
from luma.oled.device import sh1107
from partialCanvas import partialCanvas
from PIL import Image, ImageDraw, ImageFont
import board
import busio
from digitalio import DigitalInOut
from adafruit_pn532.spi import PN532_SPI
import adafruit_mpr121

##################################################################################
#########  We're using board numbering. 
##################################################################################
GPIO.setmode(GPIO.BCM)
##################################################################################
#########  Hardware settings and initializations that happen only once.  #########
##################################################################################
def handler(signum, frame):
	clearScreen()
	sys.exit()

# Set the signal handler for SIGTERM
signal.signal(signal.SIGTERM, handler)
signal.signal(signal.SIGINT, handler)

#Set variables for the NFC reader
spi = busio.SPI(board.SCK, board.MOSI, board.MISO)
cs_pin = DigitalInOut(board.D8)
pn532 = PN532_SPI(spi, cs_pin, debug=False)
# Configure PN532 to communicate with MiFare cards
pn532.SAM_configuration()
# Start listening for a card
pn532.listen_for_passive_target()


#######################################################################
###################### Variable Setup #################################
#######################################################################
#desiredVolume = 0.05
MAX_VOLUME = 1
CURRENT_VOLUME_PERCENTAGE = 5 #WARNING! This is only for the tiny dac/amp, not the hifiberry one. Hifiberry desired volume should be 0.05
GPIO.setwarnings(False)
#SONG_END = pygame.USEREVENT + 1
SONG_END = pygame.USEREVENT + 2

# Info about the current state of the song
SONG_OFFSET = 0
TOTAL_SONG_LENGTH = 0
CURRENT_SONG_POSITION = 0 #the absolute position within the song, in seconds from the beginning.

# Info about the current mode of the player (what it's set up to do)
SONG_PLAYING_MODE = 0
VOLUME_MODE = 1
TRACK_SELECT_MODE = 2
SEARCH_WITHIN_TRACK_MODE = 3
STARTUP_MODE = 4
SHUTDOWN_MODE = 5
MODENAMES = ["Song-playing", "Volume", "Track Select", "Search In Track", "Startup", "Shutdown"]
MODE_MESSAGES_USER_INPUT = ["", "New Volume:", "New Track:", "Go To Position:", ""]
MODE_MESSAGES_CURRENT_INFO = ["", "Current Volume:", "Current Track:", "Position:", ""]
#currentMode = SONG_PLAYING_MODE
currentMode = STARTUP_MODE
BLANK_SCREEN_X_SECONDS_AFTER = 0 
SHORT_DISPLAY_TIME = 10 
LONG_DISPLAY_TIME = 90
DISPLAY_TIME = 0 #If this is non-zero, the main loop should check and blank the screen if >= that number of seconds have passed since BLANK_SCREEN_X_SECONDS_AFTER

# Database variables
hostVar="localhost"
userVar="myuser"
passwdVar="mypassword"
databaseVar="musicDB"

#Database connection
MYDB = mysql.connector.connect(
  host=hostVar,
  user=userVar,
  passwd=passwdVar,
  database=databaseVar
)
MYCURSOR = MYDB.cursor()

# Playlist stuff
# The folder where the music files are stored (ending in a /)
MUSICFOLDER = '/mnt/A2E6-00F1/MusicFiles/'
SONG_LIST = []
TRACK_NUMS = []
TRACK_NAMES = []
ALBUM_NAME = ""
CURRENT_SONG_INDEX = 0

# set up the screen
serial = i2c(port=0, address=0x3C)
device=sh1107(serial_interface=serial, width=128, height=128, rotate=1)
#piScreen = canvas(device)
piScreen = partialCanvas(device, 0, 128)
#font details: font, charsPerLine, lineHeight
allFonts = {
	"smallFont" : {"font": ImageFont.truetype("/usr/local/share/fonts/PTMono-Regular.ttf", 12), 
							"charsPerLine": 18,
							"lineHeight":  14},
	"medFont" : {"font": ImageFont.truetype("/usr/local/share/fonts/PTMono-Regular.ttf", 13),
							"charsPerLine": 16,
							"lineHeight":  16},
	"bigFont" : {"font": ImageFont.truetype("/usr/local/share/fonts/PTMono-Regular.ttf", 20),
							"charsPerLine": 10,
							"lineHeight":  23},
	"hugeFont" : {"font": ImageFont.truetype("/usr/local/share/fonts/PTMono-Regular.ttf", 25),
							"charsPerLine": 8,
							"lineHeight":  29}						
							
}

PERCENTAGE_CLEAR_BOXES = [[5,51,123,69], [42,74,87,103]] #the area of the screen to clear for a percentage box
PERCENTAGE_CLEAR_YMIN = 31
PERCENTAGE_CLEAR_YMAX = 78

#Set up the capacitive touch sensor
SCL_GPIO = 1
SDA_GPIO = 0
i2cSetup = busio.I2C(SCL_GPIO, SDA_GPIO)
mpr121 = adafruit_mpr121.MPR121(i2cSetup)
CAP_TOUCH_PIN = 4
GPIO.setup(CAP_TOUCH_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
LAST_INTERRUPT_TIME = time.time() #use this to ignore interrupts that arrive too close together
DEBOUNCE_TIME = 0.1 #time in seconds to ignore future touches
CAP_NUMBER_STRING = "" #to store the most recent digits

#######################################################################
######################## Pygame Setup #################################
#######################################################################
pygame.init()
pygame.mixer.music.set_endevent(SONG_END)

if pygame.mixer.get_init():
	pygame.mixer.music.set_volume(MAX_VOLUME)
	
#######################################################################
######################## Interrupt Functions ##########################
#######################################################################
def numberButton(digit):
	global LAST_INTERRUPT_TIME
	global CAP_NUMBER_STRING
	currentTime = time.time()
	#Ignore this touch if it comes less than DEBOUNCE_TIME ms after the previous touch.
	#Either way, update most recent touch.
	if(currentTime - LAST_INTERRUPT_TIME > DEBOUNCE_TIME):
		print("Button ", digit)
		CAP_NUMBER_STRING = CAP_NUMBER_STRING + str(digit)
		
		#If we're in search_within_track or volume mode,  do a partial update of the screen, just enough to update the percentage boxes
		if(currentMode == SEARCH_WITHIN_TRACK_MODE or currentMode == VOLUME_MODE):
			updatePercentageBoxes(int(CAP_NUMBER_STRING), PERCENTAGE_CLEAR_BOXES, PERCENTAGE_CLEAR_YMIN, PERCENTAGE_CLEAR_YMAX)
		elif(currentMode == TRACK_SELECT_MODE):
			updateTrackChoice()
			
	LAST_INTERRUPT_TIME = currentTime

def playpauseButton(event):
	global LAST_INTERRUPT_TIME
	global currentMode
	global CAP_NUMBER_STRING
	global CURRENT_SONG_INDEX
	global CURRENT_SONG_POSITION
	global SONG_OFFSET
	currentTime = time.time()
	#Ignore this touch if it comes less than DEBOUNCE_TIME ms after the previous touch.
	#Either way, update most recent touch.
	if(currentTime - LAST_INTERRUPT_TIME > DEBOUNCE_TIME):
		print("Playpause Button! Current mode is ", MODENAMES[currentMode],"\n")
		
		#If we're currently in song-playing mode, we should pause, 
		# enter track-select mode, clear the CAP_NUMBER_STRING variable, and await a number.
		if(currentMode == SONG_PLAYING_MODE):
			CAP_NUMBER_STRING = ""
			currentMode = TRACK_SELECT_MODE
			print("Changed mode to ", MODENAMES[currentMode])
			if(pygame.mixer.get_init()):
				pygame.mixer.music.pause()  
			showModeScreen()
				
		# If we're currently in track-select mode, enter song-playing mode and decide which song to play.
		# If CAP_NUMBER_STRING has a valid index, set current_song_index and start playing. 
		# Otherwise, clear CAP_NUMBER_STRING and resume previously-paused song, displaying track info for a short time.
		elif(currentMode == TRACK_SELECT_MODE):
			currentMode = SONG_PLAYING_MODE
			print("Changed mode to ", MODENAMES[currentMode])
			if(len(CAP_NUMBER_STRING) > 0 and int(CAP_NUMBER_STRING)<=len(SONG_LIST) and int(CAP_NUMBER_STRING) > 0):
				CURRENT_SONG_INDEX = int(CAP_NUMBER_STRING) - 1
				playNewTrack(CURRENT_SONG_INDEX)
			else:
				pygame.mixer.music.unpause()
			CAP_NUMBER_STRING = ""
			showTrackNumAndName(ALBUM_NAME, TRACK_NUMS[CURRENT_SONG_INDEX], TRACK_NAMES[CURRENT_SONG_INDEX])
			
		# If we're currently in search-within-track mode, calculate the offset, then re-enter song-playing mode. 
		# If cap_number_string is valid, play current song starting from that offset.
		# If not, resume current song
		# Either way, clear cap_number_string
		elif(currentMode == SEARCH_WITHIN_TRACK_MODE):
			currentMode = SONG_PLAYING_MODE
			print("Changed mode to ", MODENAMES[currentMode])
			if(len(CAP_NUMBER_STRING) > 0 and 0 <= int(CAP_NUMBER_STRING) < 100):
				offsetSecs = int(TOTAL_SONG_LENGTH * int(CAP_NUMBER_STRING) / 100)
				SONG_OFFSET = offsetSecs
				CURRENT_SONG_POSITION = offsetSecs
				playTrackWithOffset(offsetSecs)
			else:
				pygame.mixer.music.unpause()
				
			CAP_NUMBER_STRING = ""
			showTrackNumAndName(ALBUM_NAME, TRACK_NUMS[CURRENT_SONG_INDEX], TRACK_NAMES[CURRENT_SONG_INDEX])
	LAST_INTERRUPT_TIME = currentTime

def volumeButton(event):
	global LAST_INTERRUPT_TIME
	global currentMode
	global CAP_NUMBER_STRING
	global CURRENT_VOLUME_PERCENTAGE
	global CURRENT_SONG_POSITION
	currentTime = time.time()
	#Ignore this touch if it comes less than DEBOUNCE_TIME ms after the previous touch.
	#Either way, update most recent touch.
	if(currentTime - LAST_INTERRUPT_TIME > DEBOUNCE_TIME):
		print("Volume Button! Current mode is " + MODENAMES[currentMode] + "\n")
		#If we're currently in song-playing mode, pause song,
		#switch to VOLUME_MODE, clear CAP_NUMBER_STRING, and await a number.
		if(currentMode == SONG_PLAYING_MODE):
			print("Entering volume mode")
			CAP_NUMBER_STRING = ""
			currentMode = VOLUME_MODE
			showModeScreen()
			if(pygame.mixer.get_init()):
				pygame.mixer.music.pause() 
				
				
		#If we're already in track-select mode, clear CAP_NUMBER_STRING just in case,
		#update CURRENT_SONG_POSITION,
		#enter SEARCH_WITHIN_TRACK mode, and await a number.   
		elif(currentMode == TRACK_SELECT_MODE):
			print("Entering search_within_track mode")
			CAP_NUMBER_STRING = ""
			currentMode = SEARCH_WITHIN_TRACK_MODE
			#get the current position in the track.
			#getpos only returns number of ms the song has been playing, doesn't count any offset.
			CURRENT_SONG_POSITION = int(pygame.mixer.music.get_pos() / 1000 + SONG_OFFSET)
			showModeScreen()
		
		#If we're already in volume mode, we've finished entering a new volume.
		#If CAP_NUMBER_STRING is between 0 and 100, set a new volume, else ignore
		#Either way, clear CAP_NUMBER_STRING, re-enter song-playing mode, and unpause the current track.
		elif(currentMode == VOLUME_MODE):
			if(len(CAP_NUMBER_STRING) > 0 and 0 <= int(CAP_NUMBER_STRING) <= 100):
				CURRENT_VOLUME_PERCENTAGE = int(CAP_NUMBER_STRING)
				if(pygame.mixer.get_init()):
					pygame.mixer.music.set_volume(MAX_VOLUME * CURRENT_VOLUME_PERCENTAGE / 100)
			CAP_NUMBER_STRING = ""
			currentMode = SONG_PLAYING_MODE
			pygame.mixer.music.unpause()
			showTrackNumAndName(ALBUM_NAME, TRACK_NUMS[CURRENT_SONG_INDEX], TRACK_NAMES[CURRENT_SONG_INDEX])
	LAST_INTERRUPT_TIME = currentTime

#decide which of the 12 capacitive buttons has been pressed
def whichButton(event):
	touchedPins = mpr121.touched_pins
	#print(touchedPins)
	#print("************\n")
  
	#only grab the first pin that we find.
	if(touchedPins[0]): 
		numberButton(5)
	elif(touchedPins[1]):
		numberButton(0)
	elif(touchedPins[2]):
		numberButton(4)
	elif(touchedPins[3]):
		numberButton(9)
	elif(touchedPins[4]):
		numberButton(3)
	elif(touchedPins[5]):
		numberButton(8)
	elif(touchedPins[6]):
		playpauseButton(event)
	elif(touchedPins[7]):
		numberButton(2)
	elif(touchedPins[8]):
		numberButton(7)
	elif(touchedPins[9]):
		volumeButton(event) 
	elif(touchedPins[10]):
		numberButton(6)
	elif(touchedPins[11]):
		numberButton(1)
	
	
#GPIO.add_event_detect(CAP_TOUCH_PIN, GPIO.RISING,callback=whichButton)
#Warning: can't add a bouncetime, or else interrupts might be ignored and then the sensor will wait forever to be read.
GPIO.add_event_detect(CAP_TOUCH_PIN, GPIO.FALLING,callback=whichButton)
#######################################################################
######################## Ordinary Functions ###########################
#######################################################################

#Just play the current song with the given offset.
def playTrackWithOffset(offset):
	try:
		global SONG_OFFSET
		pygame.mixer.music.play(0,offset)
		SONG_OFFSET = offset
		updateSqlAlbumInfo(CURRENT_SONG_INDEX, offset)
	except Exception as e:
		print("playTrackWithOffset Exception: ", e)
		raise


#Show a general screen with the mode at the top and the current value (current track, current volume, etc) below.
def showModeScreen():
	try:
		global DISPLAY_TIME
		global BLANK_SCREEN_X_SECONDS_AFTER
		DISPLAY_TIME = LONG_DISPLAY_TIME
		BLANK_SCREEN_X_SECONDS_AFTER = time.time()   
		
		#print("Clearing screen!")
		clearScreen()
		#print("Cleared screen.")
		with piScreen as draw:
				#print("Entering with piScreen as draw")
				#medFont can display up to 8 lines of text, 16 characters per line, no offset.
				draw.text((0, 0), MODENAMES[currentMode], font=allFonts["medFont"]["font"], fill="white")
				draw.rectangle([0,16,128,18], outline="white", fill="white")
				
				#If the current mode is TRACK_SELECT_MODE, show the current track and total number of tracks.
				if(currentMode == TRACK_SELECT_MODE):
					draw.text((15,30), "Current Track:", font=allFonts["smallFont"]["font"], fill="white")
					#characters needed to display the current track
					numChars = 4 +  len(str(CURRENT_SONG_INDEX+1)) + len(str(len(TRACK_NUMS)))
					currentTrackXVal = (127-13*numChars)/2 #huge characters are 13px wide.
					currentTrackString = str(CURRENT_SONG_INDEX+1) + " of " + str(len(TRACK_NUMS))
					print("currentTrackString is " + currentTrackString)
					draw.text((currentTrackXVal, 42), currentTrackString, font=allFonts["bigFont"]["font"], fill="white")
					draw.text((22,75), "Go to track:", font=allFonts["smallFont"]["font"], fill="white")
					
				#Draw a percentage box if the current mode is SEARCH_WITHIN_TRACK or VOLUME
				if(currentMode == VOLUME_MODE or currentMode == SEARCH_WITHIN_TRACK_MODE):
					barXVal = 0
					numstringToShow = ""
					if(currentMode == VOLUME_MODE):
						barXVal = 5+ int(118*CURRENT_VOLUME_PERCENTAGE/100)
						numstringToShow = str(CURRENT_VOLUME_PERCENTAGE)
					elif(currentMode == SEARCH_WITHIN_TRACK_MODE):
						barXVal = 5+ int(118*CURRENT_SONG_POSITION/TOTAL_SONG_LENGTH)
						numstringToShow = str(int(CURRENT_SONG_POSITION/TOTAL_SONG_LENGTH*100))
					#Outline of the progress box
					draw.rectangle([4,50,124,70], outline="white", fill="black")
					draw.rectangle([5, 51, barXVal, 69], outline="white", fill="white")
				
					#Percentage number
					draw.text((42, 74), numstringToShow+"%", font=allFonts["hugeFont"]["font"], fill="white")
					

	except Exception as e:
		print("showModeScreen Exception: ", e)
		raise
		
# Show the current track info before user inputs a new value.
# Format: Track Select \n Current Track \n 16 of 39 \n Position: bargraph
# Show the information for displayTime seconds 
def showTrackNumAndName(albumName, trackNum, trackName):
	try:
		global DISPLAY_TIME
		global BLANK_SCREEN_X_SECONDS_AFTER
		DISPLAY_TIME = SHORT_DISPLAY_TIME
		BLANK_SCREEN_X_SECONDS_AFTER = time.time()   
		
		scrollAlbumName = False
		clearScreen()
		with piScreen as draw:
			#album name
			albumFont = allFonts["medFont"]["font"]
			albumPadding = 0
			lineYVal = allFonts["medFont"]["lineHeight"]
			if len(albumName) > allFonts["medFont"]["charsPerLine"]:		
				albumFont = allFonts["smallFont"]["font"]
				if(len(albumName) > allFonts["smallFont"]["charsPerLine"]): #if the album name is too long for the space, write the truncated version first, then scroll.
					scrollAlbumName = True
					#albumName = albumName[0:18]
				albumPadding = (128-len(albumName)*7)//2
				lineYVal = allFonts["smallFont"]["lineHeight"]
			else:
				albumPadding = (128-len(albumName)*8)/2
			#Draw album name
			draw.rectangle([0,lineYVal, 128, lineYVal+2], outline="white", fill="white")
			if(scrollAlbumName == False):
				draw.text((albumPadding,0), albumName, font=albumFont, fill="white")
			else:
				draw.text((0,0), albumName[0:18], font=albumFont, fill="white")
			#draw album number in huge font
			#trackNumPadding = (128-len(str(trackNum))*15)//2	
			#draw.text((trackNumPadding, 40), str(trackNum), font=allFonts["hugeFont"]["font"], fill="white")
			
			#draw track name in big font, max 3 lines. Process a bit so that we break lines at a space if possible.
			trackNameLines = []
			for x in range(3):
				currentLine = trackName[0:allFonts["bigFont"]["charsPerLine"]]
				if len(currentLine) > 0:
					spaceFind = currentLine.rfind(" ")
					if(spaceFind != -1):
						currentLine = currentLine[0:spaceFind]
					
					trackNameLines.append(currentLine)
					trackName = trackName[len(currentLine)+1:]	
			trackNameY = 45
			for line in trackNameLines:
				linePadding = (128-len(line)*12)/2
				draw.text((linePadding, trackNameY), line, font=allFonts["bigFont"]["font"], fill="white")
				trackNameY += allFonts["bigFont"]["lineHeight"]
				
		
		if(scrollAlbumName == True): #If we need to scroll, do a partial clear of just the top 15 lines, then scroll.
				pixelLength = (4+len(albumName))*7 #the 4 is an arbitrary amount of extra space at the end.
				#partialClear([[0,0,127,15]], 112, 127)
				tempImage = Image.new("1", (pixelLength,15))
				tempDraw = ImageDraw.Draw(tempImage)
				tempDraw.text((0,0), albumName, font=albumFont, fill="white")
				
				#Will generating the images ahead of time help us scroll faster?
				imageList = []
				for x in range(0, pixelLength-128, 10):
					imageList.append(tempImage.crop((0+x,0,128+x, 14)))
				
				
				for x in range(0, pixelLength-128, 10):
					with piScreen as draw:
						draw._image.paste(imageList[x//10])

	except Exception as e:
		print("showTrackNumAndName Exception: ", e)
		raise


#update the 'albums' table for the current album with the current track number (not index) and percentage.
def updateSqlAlbumInfo(trackIndex, trackOffsetSecs):
	global MYCURSOR
	global MYDB
	
	sqlCommand = f"UPDATE albums SET currentTrackIndex = {trackIndex}, currentTrackOffsetSecs =  {trackOffsetSecs} WHERE albumRFID = '{currentAlbumID}'"
	sqlShowRowsCommand = f""
	print("sqlCommand is ", sqlCommand)
	try:
		print("Executing the update command...")
		MYCURSOR.execute(sqlCommand)
		MYDB.commit()
		print("Number of rows affected by update command: ", str(MYCURSOR.rowcount))
	except Exception as e:
		print("updateSqlAlbumInfo Exception: ", e)
		#Database connection
		MYDB = mysql.connector.connect(
			host=hostVar,
			user=userVar,
			passwd=passwdVar,
			database=databaseVar
			)   
		MYCURSOR = MYDB.cursor()
		MYCURSOR.execute(sqlCommand) 
		MYDB.commit()

#Partial screen update - show the user's selected track choice.
#Once user starts entering track, keep the screen on until they finished.
def updateTrackChoice():
	try:
			#put this in here so that we don't display random numbers forever if they trigger accidentally while a song is paused.
			global DISPLAY_TIME
			global BLANK_SCREEN_X_SECONDS_AFTER
			DISPLAY_TIME = SHORT_DISPLAY_TIME
			BLANK_SCREEN_X_SECONDS_AFTER = time.time()   
			
			partialClear([[0,87,127,107]], 127-107,127-87)	
			with piScreen as draw:
				xOffset = (127-len(CAP_NUMBER_STRING)*13)/2
				draw.text((xOffset, 87), CAP_NUMBER_STRING, font=allFonts["bigFont"]["font"], fill="white")
	except Exception as e:
		print("updateTrackChoice Exception: ", e)
		raise
		
#Show a percentage box in the middle of the screen, with the given percentage written underneath.		
#Once user starts entering track, keep the screen on until they finished.
def updatePercentageBoxes(percentage, clearBoxes, yMin, yMax):
	try:
		#global DISPLAY_TIME
		#DISPLAY_TIME = 0
		
		barXVal = 5+ int(118*percentage/100)
		
		partialClear(clearBoxes, yMin, yMax)
		with piScreen as draw:
				#medFont can display up to 8 lines of text, 16 characters per line, no offset.
				draw.text((0, 0), "Jump to Position", font=allFonts["medFont"]["font"], fill="white")
				draw.rectangle([0,16,128,18], outline="white", fill="white")
				
				#Outline of the progress box
				draw.rectangle([4,50,124,70], outline="white", fill="black")
				draw.rectangle([5, 51, barXVal, 69], outline="white", fill="white")
				
				#Percentage number
				draw.text((42, 74), str(percentage)+"%", font=allFonts["hugeFont"]["font"], fill="white")

	except Exception as e:
		print("updatePercentageBoxes Exception: ", e)
		raise	

# Blank the screen if no songs are playing.
def clearScreen():
	try:
		piScreen.setStartAndEnd(0, 128)
		with piScreen as draw:
			draw.rectangle(device.bounding_box, outline="black", fill="black")
	except Exception as e:
		print("clearScreen Exception: ", e)
		raise
		
#Blank all of the boxes in the list. Each list entry is in the form [x1,y1,x2,y2]
#NOTE: yMin and yMax are measured from the bottom up (so should be 127-y2, 127-y1)
def partialClear(clearBoxes, yMin, yMax):	
	try:
		piScreen.setStartAndEnd(yMin, yMax)
		with piScreen as draw:
			for box in clearBoxes:
				draw.rectangle([box[0], box[1], box[2], box[3]], outline="black", fill="black")
	except Exception as e:
		print("partialClear Exception: ", e)
		raise		

#Grab initial settings (volume, screen timeout, idle time before shutdown) from the database
"""
def getSettings():
	try:
		sqlCommand = 
	except Exception as e:
		print("getSettings Exception: ", e)
		raise
"""               
#Get the list of songs associated with the given albumID
def updateSongList(albumID):
	try:
		global SONG_LIST
		SONG_LIST = []
		global TRACK_NUMS
		TRACK_NUMS = []
		global TRACK_NAMES
		TRACK_NAMES = [] 
		global ALBUM_NAME
		ALBUM_NAME = ""
		global MYCURSOR
		global MYDB
		
		sqlCommand = "SELECT trackNum, trackName, fileName FROM tracks WHERE albumRFID = '%s' ORDER BY trackNum" % albumID
						
		#sql will time out if left alone overnight.  Reopen sql if that happens.
		try:
			MYCURSOR.execute(sqlCommand)
		except Exception as e:
			print("updateSongList Exception: ", e)
			#Database connection
			MYDB = mysql.connector.connect(
				host=hostVar,
				user=userVar,
				passwd=passwdVar,
				database=databaseVar
				)   
			MYCURSOR = MYDB.cursor()
			MYCURSOR.execute(sqlCommand)  
		rows = MYCURSOR.fetchall()
		# if the RFID sticker isn't associated with any playlists, print the sticker ID to the screen instead.
		if(len(rows) == 0):
			TRACK_NAMES.append(albumID)
			SONG_LIST.append(MUSICFOLDER + "sesame1WouldYouLikeToBuyAnO.ogg")
			TRACK_NUMS.append(1.0)
		for row in rows:
			TRACK_NAMES.append(row[1])
			SONG_LIST.append(MUSICFOLDER + row[2])
			TRACK_NUMS.append(row[0])
			
		sqlCommand = "SELECT albumName FROM albums WHERE albumRFID = '%s' " %albumID	
		#sql will time out if left alone overnight.  Reopen sql if that happens.
		try:
			MYCURSOR.execute(sqlCommand)
		except Exception as e:
			print("updateSongList Exception: ", e)
			#Database connection
			MYDB = mysql.connector.connect(
				host=hostVar,
				user=userVar,
				passwd=passwdVar,
				database=databaseVar
				)   
			MYCURSOR = MYDB.cursor()
			MYCURSOR.execute(sqlCommand)  
		rows = MYCURSOR.fetchall()
		# if the RFID sticker isn't associated with any playlists, print the sticker ID to the screen instead.
		if(len(rows) > 0):
			ALBUM_NAME = rows[0][0]
		return
	except Exception as e:
		print("updateSongList Exception: ", e)
		raise
#Reset all of the toggle vars to their original values    
def resetToggleValues():
	try:
		global TOGGLE_SEARCH_WITHIN_TRACK
		global SONG_OFFSET
		global TOTAL_SONG_LENGTH 
		global CURRENT_SONG_POSITION 
		global NUMCLICKS 
		global TIMEJUMP 
		TOGGLE_SEARCH_WITHIN_TRACK = -1
		SONG_OFFSET = 0
		TOTAL_SONG_LENGTH = 0
		CURRENT_SONG_POSITION = 0 #the absolute position within the song, in seconds from the beginning.
		NUMCLICKS = 0
		TIMEJUMP = 0 #the number of seconds to jump forwards (or backwards) from the current position
	except Exception as e:
		print("resetToggleValues Exception: ", e)
		raise
	 
# Scans for an RFID tag and returns its id if found, "" if not.
def scanForRFID():
	try:
		cardID = ""
		#tries to read for up to 1 second. Returns None if not found, uid if found.
		uid = pn532.read_passive_target()
		if (uid != None):
			cardID = str(uid[0]) + str(uid[1]) + str(uid[2]) + str(uid[3])
		return(cardID)
	except Exception as e:
		print("scanForRFID Exception: ", e)
		raise

# Play the track with the given index. Calling function should check first that index is valid.
def playNewTrack(trackIndex):
	try:
		global CURRENT_SONG_INDEX
		
		CURRENT_SONG_INDEX = trackIndex
		#stop the previous song, if applicable, before starting the new one.
		if(pygame.mixer.get_init()):
			#print("Stopping the previous song.")
			pygame.mixer.music.stop()
			#get rid of the MUSIC_STOPPED signal in the queue - we don't need to go on to the next song right now.
			pygame.event.get()
					
		#reset the sampling so that pygame plays the music at the right speed
		if(pygame.mixer.get_init()):
			presentSong = SONG_LIST[CURRENT_SONG_INDEX]
			presentSongName = TRACK_NAMES[CURRENT_SONG_INDEX]
			presentSongNum = TRACK_NUMS[CURRENT_SONG_INDEX]
					
			resetSampling(presentSong)
			pygame.mixer.music.load(presentSong)
			showTrackNumAndName(ALBUM_NAME, TRACK_NUMS[CURRENT_SONG_INDEX], TRACK_NAMES[CURRENT_SONG_INDEX])
			
			pygame.mixer.music.play()
		
		#Update the 'albums' table with the current track index and 0% progress
		updateSqlAlbumInfo(CURRENT_SONG_INDEX, 0)
		return
	except Exception as e:
		print("playNewTrack Exception: ", e)
		raise

#reset the sampling so that pygame plays the music at the right speed
def resetSampling(trackName):
	try:
		global TOTAL_SONG_LENGTH
		global SONG_OFFSET
		global NUMCLICKS
		global CURRENT_SONG_POSITION 
		SONG_OFFSET = 0
		#NUMCLICKS = 0
		CURRENT_SONG_POSITION = 0
		pygame.mixer.quit()
		
		oggFile = mutogg.OggVorbis(trackName)
		pygame.mixer.init(frequency=oggFile.info.sample_rate)
		#Set the length of the song in seconds
		TOTAL_SONG_LENGTH = oggFile.info.length
		#reset the volume to its current desired value
		pygame.mixer.music.set_volume(MAX_VOLUME*CURRENT_VOLUME_PERCENTAGE/100)
	except Exception as e:
		print("resetSampling Exception: ", e)
		raise
#######################################################################
######################## Main Loop ####################################
#######################################################################
try:
	currentAlbumID = ""
	
	
	
	while True:
		
		# Check for an album number with length >0 that's different than the current album number.
		# If we find a new album number, reset mode, update the track lists, and start playing from the beginning.
		albumNumber = scanForRFID()
		if(albumNumber!=currentAlbumID and len(albumNumber) > 0):
			currentMode = SONG_PLAYING_MODE
			print("scanned albumNumber is {} but currentAlbumID is {}, so we're updating the song list.".format(albumNumber, currentAlbumID))
			currentAlbumID = albumNumber

			CURRENT_SONG_INDEX = 0
			updateSongList(currentAlbumID)
			
			#Were we on a different song the last time this album was played?
			sqlCommand = f"SELECT currentTrackIndex, currentTrackOffsetSecs FROM albums WHERE albumRFID = '{currentAlbumID}'"
			try:
				MYCURSOR.execute(sqlCommand)
				results = MYCURSOR.fetchall()
				currentTrackIndex = results[0][0]
				currentTrackOffsetSecs = results[0][1]
				if(currentTrackIndex != None):
					playNewTrack(currentTrackIndex)
					if(currentTrackOffsetSecs != None):
						playTrackWithOffset(currentTrackOffsetSecs)
				else:
					playNewTrack(0)		
			except Exception as e:
				print("main Exception: ", e)
				#Database connection
				MYDB = mysql.connector.connect(
					host=hostVar,
					user=userVar,
					passwd=passwdVar,
					database=databaseVar
					)   
				MYCURSOR = MYDB.cursor()
				MYCURSOR.execute(sqlCommand) 
			print(f"Albums table results: {MYCURSOR.fetchall()}") 
			
			#playNewTrack(0)

		for event in pygame.event.get():
			if event.type == pygame.QUIT:
				pygame.quit()
				sys.exit()
			elif event.type == SONG_END:
				print("Song has ended! On to the next.")
				#Go on to the next track when the previous one finishes, looping to zero if we're at the end.
				if(len(SONG_LIST) > CURRENT_SONG_INDEX + 1):
					CURRENT_SONG_INDEX += 1
					playNewTrack(CURRENT_SONG_INDEX)
				else:
					CURRENT_SONG_INDEX = 0
					playNewTrack(CURRENT_SONG_INDEX)
				
		
		# If something's requested a screen blanking and current time is >= BLANK_SCREEN_AFTER + screen blanking time,
		# blank the screen and reset DISPLAY_TIME to zero.        
		if(DISPLAY_TIME != 0):
			if(time.time() - BLANK_SCREEN_X_SECONDS_AFTER >= DISPLAY_TIME):
				clearScreen()
				DISPLAY_TIME = 0
except Exception as e:
	print("main Exception: ", e)
	traceback.print_exc()
	raise
finally:
	#If we close unexpectedly, try to save the current track and position first.
	updateSqlAlbumInfo(CURRENT_SONG_INDEX, CURRENT_SONG_POSITION)
	MYCURSOR.close()
	MYDB.close()
	GPIO.cleanup() #try to ensure a clean exit
			
