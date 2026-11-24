# Makefile -- the world, for those who would rather be told it was made.
#
# Put this beside world.c and say
#
#   make
#
# and it is made, and says so, and stops. Say it again and you will be told
# that the world is up to date. Nobody else has been willing to put that in
# writing, and make only looked at the time on two files to do it.
#
# The rest are things that people were already saying, taken at their word:
#
#   make world      the world, from source. This is the default, as it should be.
#   make do         a world from whatever is in the house, when there is no compiler
#   make believe    everything that making a world would say, and no world
#   make time       one whole day, forty pictures of it, which is all a day is
#   make way        the world turned to LON degrees:  make way LON=270
#   make certain    the world, made, and then asked what it says
#   make nothing    nothing
#   make amends     the world taken away again, and the directory as it was
#
# There is no rule to make sense. Ask for it and you will be told as much, in
# those words, by make itself, which has been saying so to everybody for years
# and was not written here. The same goes for peace, and for a difference.
#
# The lines below that begin with a tab must go on beginning with a tab. It is
# the one place in all of this where the kind of nothing matters.

.POSIX:

CC  = cc
LON = 0

world: world.c
	$(CC) -o world world.c -lm
	@echo 'made. it is the small file called world. it was not there before.'

do:
	@if [ -f world.sh ]; then sh world.sh still; \
	 else echo '   ~ # ~'; echo 'hello world'; \
	      echo '(three characters were in the house. it will have to do.)'; fi

believe:
	@echo '$(CC) -o world world.c -lm'
	@echo 'made. it is the small file called world. it was not there before.'
	@echo '(none of that happened. it is no less of a world to look at.)'

time: world
	./world 0 40

way: world
	./world $(LON)

certain: world
	@if [ "`./world | tail -n 1`" = 'hello world' ]; \
	 then echo 'it says hello world. it has been checked, and it always did.'; \
	 else echo 'it says something else. somebody has tidied it.'; exit 1; fi

nothing: ;

amends:
	rm -f world
	@echo 'gone. the source is still here, and so the world is, in the sense that counts.'
