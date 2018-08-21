#!/usr/bin/perl

((system("/bin/rm /d1/lave/GOES13/data/VisOnly/*") >> 8) == 0);
((system("/bin/rm /d1/lave/GOES13/data/LowRes/*") >> 8) == 0);
((system("/bin/mv /d1/lave/GOES13/working1/* /d1/lave/GOES13/data/VisOnly/") >> 8) == 0);
((system("/bin/mv /d1/lave/GOES13/working2/* /d1/lave/GOES13/data/LowRes/") >> 8) == 0);
