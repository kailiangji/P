@echo off

REM clean all intermediate files, and files produced during execution

del *.4ml 2> nul
del *.cs  2> nul
del *.pdb 2> nul

del concretes*      2> nul
del abstracts*      2> nul
del abstract_succs* 2> nul
del a.txt           2> nul
del unreached.txt   2> nul
del reached*.txt    2> nul
