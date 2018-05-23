#!/usr/bin/env perl
use strict ;
use warnings ;
use diagnostics ;
use Smart::Comments ;
use Data::Dumper ;
use feature ":5.24" ;

use Term::Screen ;
use Term::ReadKey ;
use Time::HiRes ;

ReadMode 3 ;

my $key ;

while (1) {
    while ( not defined ($key = ReadKey(-1)) ) {
        sleep(0.5) ;
    }
    say "up" if ( ord($key) == 65 ) ;
}

ReadMode 0 ;
