#!/usr/bin/env perl
use strict ;
use warnings ;
use diagnostics ;
use Smart::Comments ;
use Data::Dumper ;
use feature ":5.24" ;

use Term::Screen ;

my $scr = Term::Screen->new() ;

$scr->clrscr() ;
$scr->curinvis() ;

my @pattern = ( [' ','*',' '],
                [' ','*',' '],
                ['*','*','*'] ) ;

my ($x, $y) = (10, 10) ;

while (1) {
    aff($x, $y, @pattern) ;

    my $char = $scr->getch() ;

    $x = $x % 21 ;
    $y = $y % 41 ;

    if ( $char eq "kr" ) {
        $scr->clrscr() ;
        $y++ ;
        aff($x, $y, @pattern) ;
    }
    if ( $char eq "kl" ) {
        $scr->clrscr() ;
        $y-- ;
        aff($x, $y, @pattern) ;
    }
    if ( $char eq "ku" ) {
        $scr->clrscr() ;
        $x-- ;
        aff($x, $y, @pattern) ;
    }
    if ( $char eq "kd" ) {
        $scr->clrscr() ;
        $x++ ;
        aff($x, $y, @pattern) ;
    }
}

$scr->curvis() ;

sub aff {
    my ($row, $col, @motif) = @_ ;

    ($row -= 21) if ( $row > 20 ) ;
    ($row += 21) if ( $row < 0 ) ;
    ($col -= 41) if ( $col > 40 ) ;
    ($col += 41) if ( $col < 0 ) ;

    foreach my $i ( 0 .. 2 ) {
        foreach my $j ( 0 .. 2 ) {
            my $x = $row + $i ;
            my $y = $col + $j ;
            my $str = $motif[$i][$j] ;

            $scr->at($x,$y)->puts("$str") ;
        }
    }
}

