# uses py2exe to convert Assembler.py to an executable format

from distutils.core import setup
import py2exe

setup(console=['Assembler.py'])