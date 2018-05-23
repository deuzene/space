#!/usr/bin/env perl
use strict ;
use warnings ;
use diagnostics ;
use Smart::Comments ;
use Data::Dumper ;
use feature ":5.24" ;

use Term::Screen ;
use Time::HiRes qw(sleep) ;
use Term::ReadKey ;

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
my ($X_vaisseau, $Y_vaisseau) = (19, 18) ; # position de depart
affiche_motif($X_vaisseau, $Y_vaisseau, @vaisseau) ;

# l'obstacle
my @obstacle = ( ['*','*','*'],
                 ['*','*','*'],
                 ['*','*','*'] ) ;

my ($X_obstacle, $Y_obstacle) = (9, 18) ;

# l'ennemi
my @ennemi = ( ['@'],
               ['↓'] ) ;
# my @ennemi = ( ['/','\\'],
               # ['\\','/'] ) ;

my $X_ennemi = 0 ;
my $Y_ennemi = int( rand(40) ) ;

# liste noire
my @liste_noire ;

my $key ;
ReadMode 3 ;

# ## boucle infinie ########################
# lecture des touches pour deplacer le motif
while (1) {
    while ( not defined ($key = ReadKey(-1)) ) {
        $X_ennemi++ ;
        $X_ennemi = $X_ennemi % ($screenX + 1) ;

        $Y_ennemi += int( rand(2) ) -1 ;
        $Y_ennemi = $Y_ennemi % ($screenY + 1) ;

        @liste_noire = liste_noire () ;

        $scr->clrscr ;
        affiche_motif($X_ennemi, $Y_ennemi, @ennemi) ;
        affiche_motif($X_obstacle, $Y_obstacle, @obstacle) ;
        affiche_motif($X_vaisseau, $Y_vaisseau, @vaisseau) ;

        sleep(0.2) ;
    }

    # lecture de la touche
    my $up    = 65 ;
    my $down  = 66;
    my $right = 67 ;
    my $left  = 68 ;
    # pour rester dans les dimensions de la scene
    # x et y pouvant grossir ou etre < 0
    $X_vaisseau = $X_vaisseau % ($screenX + 1) ;
    $Y_vaisseau = $Y_vaisseau % ($screenY + 1) ;

    # droite
    if ( ord($key) == $right ) {
        $Y_vaisseau++ ;
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
    # gauche
    if ( ord($key) == $left ) {
        $Y_vaisseau-- ;
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
    # haut
    if ( ord($key) == $up ) {
        $X_vaisseau-- ;
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
    # bas
    if ( ord($key) == $down ) {
        $X_vaisseau++ ;
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
} # fin boucle infinie

$scr->curvis() ; # curseur visible
$scr->echo() ;   # rendre les frappe visible
ReadMode 0 ;
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
            if ( defined $motif[$i][$j] ) { ;
                my $str = $motif[$i][$j] ;
                $scr->at($x,$y)->puts("$str") ;
            }
        }
    }
    return ;
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
    return ;
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

sub liste_noire {
    my @liste ;

    foreach my $i ( 0 .. 2 ) {
        foreach my $j ( 0 .. 2 ) {
            my $x = $X_obstacle + $i ;
            my $y = $Y_obstacle + $j ;
            push @liste , [ $x, $y ] ;
        }
    }

    foreach my $i ( 0 .. 1 ) {
        foreach my $j ( 0 .. 1 ) {
            my $x = $X_ennemi + $i ;
            my $y = $X_ennemi + $j ;
            push @liste , [ $x, $y ] ;
        }
    }
    return @liste ;
}
