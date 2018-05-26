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

use Storable ;

my $r_list = retrieve 'fichier' ;

# ### $r_list

my $x = 10 ;
my $y = 20 ;
my @liste ;

foreach my $i ( 0 .. 2 ) {
    foreach my $j ( 0 .. 2 ) {
        my $X = $x + $i ;
        my $Y = $x + $j ;
        push @liste , "$X$Y" ;
    }
}

### liste: @liste
