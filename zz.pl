#!/usr/bin/env perl
use strict ;
use warnings ;
use diagnostics ;
use Smart::Comments ;
use Data::Dumper ;
use feature ":5.24" ;

use Term::Screen ;

sub verif_impact {
    my $x   = shift ;
    my $y   = shift ;
    my @obj = @_ ;

    foreach my $i ( 0 .. 2 ) {
        foreach my $j ( 0 .. 2 ) {
            $x += $i ;
            $y += $j ;
            my $ind = $i + $j ;
            if ( $obj[$i][$j] ne ' ' ) {
                if (    ( $liste_noire[$ind][0] == $x )
                    and ( $liste_noire[$ind][1] == $y ) )
                {
                    game_over () ;
                }
            }
        }
    }
}
