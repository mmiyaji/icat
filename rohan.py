#!/usr/bin/env python
# encoding: utf-8
"""
rohan.py

Created by mmiyaji on 2013-06-03.
Copyright (c) 2013  ruhenheim.org. All rights reserved.
"""
import sys, os, Image, colorsys, curses, argparse
def get_prompt(p):
    """
    Arguments:
    - `p`: image list (int red, int green, int blue)
    value 0-255
    """
    hsv = colorsys.rgb_to_hsv(p[0], p[1], p[2])
    col = 0
    if hsv[0]*360 >= 30 and hsv[0]*360 < 70:
        col = 43 # yellow
    elif hsv[0]*360 >= 70 and hsv[0]*360 < 150:
        col = 42 # green
    elif hsv[0]*360 >= 150 and hsv[0]*360 < 190:
        col = 46 # cyan
    elif hsv[0]*360 >= 190 and hsv[0]*360 < 270:
        col = 44 # blue
    elif hsv[0]*360 >= 270 and hsv[0]*360 < 335:
        col = 45 # purple
    elif hsv[0]*360 >= 335 or hsv[0]*360 < 30:
        col = 41 # red
    if hsv[2] > 220 and hsv[1] < 0.25:
        col = 47 # white
    elif hsv[2] < 100:
        col = 40  # black
    return '\033[%dm \033[0m' % (col)
def get_prompt256(p):
    """
    Arguments:
    - `p`: image list (int red, int green, int blue)
    value 0-255
    """
    return '\x1b[48;5;%dm \x1b[0m' % (16 + 36*(round(5*(p[0]/256.0))) + 6*(round(5*(p[1]/256.0))) + (round(5*(p[2]/256.0))))

def main(args=None):
    path = args.file_path
    color = 256
    (height, width) = (100, 150)
    # set arg values
    if args.file:
        path = args.file
    if args.depth:
        if args.depth == 8:
            color = 8
    if args.size:
        max_width = args.size
    else:
        try:
            # get screen size by curses
            scr = curses.initscr()
            curses.endwin()
            (height, width) = scr.getmaxyx()
        except:
            pass
        max_width = width
    try:
        im = Image.open(path)
    except IOError:
        print "No such file."
        sys.exit(1)
    width, height = im.size
    try:
        # set font and image size ratio
        max_height = int(max_width / 1.5 / (float(width) / height))
        w_step = float(width) / max_width
        h_step = float(height) / max_height
    except ZeroDivisionError:
        max_height = 1
        w_step = 1
        h_step = 1
    out = []
    for i in xrange(0, int(height / h_step)):
        line = []
        import math
        for j in xrange(0, int(width / w_step)):
            rgb = [0.0, 0.0, 0.0]
            count = 0.0
            for hi in xrange(0, int(math.ceil(w_step))):
                for wi in xrange(0, int(math.ceil(h_step))):
                    try:
                        pics = im.getpixel((j*w_step + wi, i*h_step + hi))
                        rgb[0] += pics[0]
                        rgb[1] += pics[1]
                        rgb[2] += pics[2]
                        count += 1
                    except IndexError: # out of index
                        break
            try:
                # calc average
                line.append(map((lambda x: x / count), rgb))
            except ZeroDivisionError:
                pass
        out.append(line)
    for i in out:
        for j in i:
            if color == 256:
                sys.stdout.write(get_prompt256(j))
            else:
                sys.stdout.write(get_prompt(j))
        print
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='image file path.')
    parser.add_argument('file_path', metavar='file',
                    help='image file path.')
    parser.add_argument('-v', '--version', action='version', version='%(prog)s 1.0')
    parser.add_argument('-s', '--size',    type=int, help='image width.')
    parser.add_argument('-d', '--depth',   type=int, help='color depth. support 8(ansi) and 256(xterm-256).')
    parser.add_argument('-f', '--file',    help='image file path.')
    args = parser.parse_args()
    main(args)

