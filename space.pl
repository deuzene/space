#!/usr/bin/env perl
use strict ;
use warnings ;
use diagnostics ;
use Smart::Comments ;
use Data::Dumper ;
use feature ":5.24" ;

use Term::Screen ;
use Time::HiRes qw(sleep) ;

my $scr = Term::Screen->new() ;

# dimension de la scène
my $screenX = 19 ;
my $screenY = 39 ;

$scr->clrscr() ;   # on efface l'ecran
$scr->curinvis() ; # curseur invisible
$scr->noecho() ;   # rendre les frappe invisible

# le vaisseau
my @vaisseau = ( ['/','O','\\'],
                 ['«','-','»'],
                 ['*',' ','*'] ) ;
my ($Vx, $Vy) = (19, 18) ; # position de depart
affiche_motif($Vx, $Vy, @vaisseau) ;

# l'obstacle
my @obstacle = ( ['*','*','*'],
                 ['*','*','*'],
                 ['*','*','*']) ;

my ($Ox, $Oy) = (9, 18) ;
affiche_motif($Ox, $Oy, @obstacle) ;

# liste noire
my @liste_noire ;

foreach my $i ( 0 .. 2 ) {
    foreach my $j ( 0 .. 2 ) {
        my $x = $Ox + $i ;
        my $y = $Oy + $j ;
        push @liste_noire , [ $x, $y ] ;
    }
}


# ## boucle infinie ########################
# lecture des touches pour deplacer le motif
while (1) {

    # lecture de la touche
    my $char = $scr->getch() ;

    # pour rester dans les dimensions de la scene
    # x et y pouvant grossir ou etre < 0
    $Vx = $Vx % ($screenX + 1) ;
    $Vy = $Vy % ($screenY + 1) ;

    # droite
    if ( $char eq "kr" ) {
        $scr->clrscr() ;
        $Vy++ ;
        verif_impact($Vx, $Vy, @vaisseau) ;
        affiche_motif($Vx, $Vy, @vaisseau) ;
    }
    # gauche
    if ( $char eq "kl" ) {
        $scr->clrscr() ;
        $Vy-- ;
        verif_impact($Vx, $Vy, @vaisseau) ;
        affiche_motif($Vx, $Vy, @vaisseau) ;
    }
    # haut
    if ( $char eq "ku" ) {
        $scr->clrscr() ;
        $Vx-- ;
        verif_impact($Vx, $Vy, @vaisseau) ;
        affiche_motif($Vx, $Vy, @vaisseau) ;
    }
    # bas
    if ( $char eq "kd" ) {
        $scr->clrscr() ;
        $Vx++ ;
        verif_impact($Vx, $Vy, @vaisseau) ;
        affiche_motif($Vx, $Vy, @vaisseau) ;
    }
    affiche_motif($Ox, $Oy, @obstacle) ;
} # fin boucle infinie

$scr->curvis() ; # curseur visible
$scr->echo() ;   # rendre les frappe visible

#############################################################################

sub affiche_motif {
    my ($row, $col, @motif) = @_ ;

    ($row -= ($screenX + 1)) if ( $row > 19 ) ;
    ($row += ($screenX + 1)) if ( $row < 0 ) ;
    ($col -= ($screenY + 1)) if ( $col > 39 ) ;
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

sub verif_impact {
    my $x   = shift ;
    my $y   = shift ;
    my @obj = @_ ;

    foreach my $i ( 0 .. 2 ) {
        foreach my $j ( 0 .. 2 ) {
            $x += $i ;
            $y += $j ;

            if ( $obj[$i][$j] ne ' ' ) {
                foreach my $a_ref ( @liste_noire ) {
                    if (    ( $a_ref->[0] == $x )
                        and ( $a_ref->[1] == $y ) )
                    {
                        game_over () ;
                    }

                }
            }
        }
    }
}

sub game_over {
    foreach (1 .. 100) {
        my $x = int( rand(20) ) ;
        my $y = int( rand(40) ) ;

        $scr->at($x,$y)->puts("BOUM") ;
        sleep(0.01) ;
    }

    my @game_over_str = (
        '                 ',
        '  *************  ',
        '  * GAME OVER *  ',
        '  *************  ',
        '                 ',
    ) ;

    foreach my $i ( 0 .. 4 ) {
        $scr->at(7+$i,13) ;
        $scr->puts($game_over_str[$i]) ;
    }

    $scr->at(25,0) ;
    exit ;
}

