# -*- coding: utf-8 -*-
# Copyright (c) 2017-2022 Richard Hull and contributors
# See LICENSE.rst for details.

from PIL import Image, ImageDraw


class partialCanvas(object):
	"""
	A canvas returns a properly-sized :py:mod:`PIL.ImageDraw` object onto
	which the caller can draw upon. As soon as the with-block completes, the
	resultant image is flushed onto the device.

	yStart, yEnd are the beginning and ending y values to draw
	"""
	def __init__(self, device, yStart, yEnd):
		self.draw = None
		self.yStart = yStart
		self.yEnd = yEnd
		self.device = device
		#the image is going to be 128x128 no matter what
		self.image = Image.new(device.mode, (128,128))
	
	def setStartAndEnd(self, yStart, yEnd):
		self.yStart = yStart
		self.yEnd = yEnd

	def __enter__(self):
		self.draw = ImageDraw.Draw(self.image)
		return self.draw

	def __exit__(self, type, value, traceback):
		if type is None:
			# do the drawing onto the device
			self.device.verticalDisplay(self.image, self.yStart, self.yEnd)

		if(hasattr(self,'draw')):
			del self.draw   # Tidy up the resources
		else:
			print("self.draw doesn't exist!")	
		return False    # Never suppress exceptions
