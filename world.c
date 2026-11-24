/*
 * world.c -- the world, as a program, in the language the greeting was first said in.
 *
 * It was a program before it was a place. The original ran to five lines, printed
 * two words and stopped, and everything since has been added on top of that. This is
 * what the five lines look like now. They have been put back into the shape of the
 * thing they describe, since a program does not mind where its spaces go, and this
 * is the only world of which that can be said.
 *
 *   cc -o world world.c -lm
 *   ./world            one picture, and then what it was always going to say
 *   ./world 270        the same, turned to the longitude given, in degrees
 *   ./world 0 40       forty pictures, each nine degrees on from the last
 *
 * The At is in it, when it is round the front, and so is the Shade when the At
 * stands in the light. The Caret is in it. So is the bottle, and two flags that
 * were here before you. The weather came along this time, a compiler being easier
 * to get cloud through than a pipe.
 *
 * Do not tidy it. A formatter will hand you back the same world as a rectangle,
 * and it will still run, and that is the worst that can be said of rectangles.
 *
 * The three lines above the pole are not part of the world. They are where it gets
 * its sines from, and its square roots, and its ability to say anything at all.
 * The sky has to be held up by something.
 */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
               int main (int
           c,char**v){double t=c>
        1?atof(v[1])/57.2958:2.0944,
      x,y,z,l,a,m,d;int i,j,k,s,n,f,p=
    c>2 ?atoi(v[2 ]):1;for (;p-->0 ;t+=
   .15708){m=t /2.97+1.05;n=sin(m )*29;f=
  cos(m)>0;for(j=-12;j<12;j++,putchar(10))
 for(i=-30;i<30;i++){x=(i+.5)/22.;y=(j+.5)/
11.;z=1-x*x-y*y;s=(i*i*7+j*j*13+i*j*5+900)%
67;if(z<0){putchar(f&&j==-9&&i==n?64:s==3?39
:s==9+p%3?46:s==31?96:32);continue;}z=sqrt(z
);l=z*.6-x*.5-y*.6;d=x-n/22.;d=d*d+y*y;k=f&&
d<.0289?2: l>.5?0:l>.1? 1:2;a=atan2(x, z)+t;
putchar(j==4&&cos(a-t*1.3)>.9998?94:j==-3&&
 cos(a-t *.6+2)>.9995?37 :j==-5&&cos( a-1)>
  .9995?33:j== 6&&cos(a-4)>.9995? 33:k<2&&
   sin(a*5-t+y*7)*cos(y*9+a)>.855?34:(y<0
    ?-y:y)>.935?"*++"[k] :sin(a*2+y*3)+
      cos(a-y*2+4)>.8?"#o:"[k]:"~-."[k
        ] ) ;} } puts ( "" ); puts (
           "hello world") ;return
                    0;}
