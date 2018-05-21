#!/usr/bin/env perl
use strict ;
use warnings ;
use diagnostics ;
use Smart::Comments ;
use Data::Dumper ;
use feature ":5.24" ;

use Term::Screen ;

my $scr = Term::Screen->new() ;

# dimension de la scene
my $screenX = 20 ;
my $screenY = 40 ;

# le vaisseau
my @pattern = ( [' ','*',' '],
                [' ','*',' '],
                ['*','*','*'] ) ;

$scr->clrscr() ;   # on efface l'ecran
$scr->curinvis() ; # curseur invisible
$scr->noecho() ;   # rendre les frappe invisible

my ($x, $y) = (10, 10) ; # position de depart

# ## boucle infinie ########################
# lecture des touches pour deplacer le motif
while (1) {
    affiche_motif($x, $y, @pattern) ;

    # lecture de la touche
    my $char = $scr->getch() ;

    # pour rester dans les dimensions de la scene
    # x et y pouvant grossir ou etre < 0
    $x = $x % ($screenX + 1) ;
    $y = $y % ($screenY + 1) ;

    # droite
    if ( $char eq "kr" ) {
        $scr->clrscr() ;
        $y++ ;
        affiche_motif($x, $y, @pattern) ;
    }
    # gauche
    if ( $char eq "kl" ) {
        $scr->clrscr() ;
        $y-- ;
        affiche_motif($x, $y, @pattern) ;
    }
    # haut
    if ( $char eq "ku" ) {
        $scr->clrscr() ;
        $x-- ;
        affiche_motif($x, $y, @pattern) ;
    }
    # bas
    if ( $char eq "kd" ) {
        $scr->clrscr() ;
        $x++ ;
        affiche_motif($x, $y, @pattern) ;
    }
} # fin boucle infinie

$scr->curvis() ; # curseur visible
$scr->echo() ;   # rendre les frappe visible

#############################################################################

sub affiche_motif {
    my ($row, $col, @motif) = @_ ;

    ($row -= ($screenX + 1)) if ( $row > 20 ) ;
    ($row += ($screenX + 1)) if ( $row < 0 ) ;
    ($col -= ($screenY + 1)) if ( $col > 40 ) ;
    ($col += ($screenY + 1)) if ( $col < 0 ) ;

    foreach my $i ( 0 .. 2 ) {
        foreach my $j ( 0 .. 2 ) {
            my $x = $row + $i ;
            my $y = $col + $j ;
            my $str = $motif[$i][$j] ;

            $scr->at($x,$y)->puts("$str") ;
        }
    }
}

