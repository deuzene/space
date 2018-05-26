#!/usr/bin/env perl
use strict ;
use warnings ;
use diagnostics ;
use Smart::Comments ;
use Data::Dumper ;
use feature ":5.24" ;

use Time::HiRes qw(sleep) ;
use Term::ReadKey ;

use Term::Screen ;
my $scr = Term::Screen->new() ;

$scr->clrscr() ;   # on efface l'ecran
$scr->curinvis() ; # curseur invisible
$scr->noecho() ;   # rendre les frappe invisible

# dimension de la scène
my $screenX = 19 ;
my $screenY = 39 ;

# le vaisseau
my @vaisseau = ( ['/','O','\\'],
                 ['«','-','»'],
                 ['*',' ','*'] ) ;
my ($X_vaisseau, $Y_vaisseau) = (19, 18) ; # position de depart

# l'obstacle_1
my @obstacle = ( [' ','*',' '],
                 ['*','*','*'],
                 [' ','*',' '] ) ;

my ($X_obstacle_1, $Y_obstacle_1) = (9, 5) ;
my ($X_obstacle_2, $Y_obstacle_2) = (9, 15) ;
my ($X_obstacle_3, $Y_obstacle_3) = (9, 25) ;
my ($X_obstacle_4, $Y_obstacle_4) = (9, 35) ;

# l'ennemi
my @ennemi = ( ['@'],
               ['↓'] ) ;

my $X_ennemi_1 = 0 ;
my $Y_ennemi_1 = int( rand(40) ) ;

my $X_ennemi_2 = 0 ;
my $Y_ennemi_2 = int( rand(40) ) ;

my $count = 0 ;
# liste noire
my @liste_noire ;

my $key ;
ReadMode 3 ;

# ## boucle infinie ########################
# lecture des touches pour deplacer le motif
while (1) {
    my $un_sur_deux = 0 ;
    while ( not defined ($key = ReadKey(-1)) ) {
        if ( $un_sur_deux ) {
            $X_ennemi_1++ ;
            $X_ennemi_1 = $X_ennemi_1 % ($screenX + 1) ;
            $Y_ennemi_1 += int( rand(2) ) -1 ;
            $Y_ennemi_1 = $Y_ennemi_1 % ($screenY + 1) ;

            if ( $count > 10 ) {
                $X_ennemi_2++ ;
                $X_ennemi_2 = $X_ennemi_2 % ($screenX + 1) ;
                $Y_ennemi_2 += int( rand(2) ) -1 ;
                $Y_ennemi_2 = $Y_ennemi_2 % ($screenY + 1) ;
            }

            @liste_noire = liste_noire () ;
            $count++ ;

        }

        if ( $un_sur_deux == 0 ) {
            $un_sur_deux = 1 ;
        } else {
            $un_sur_deux = 0 ;
        }

        $scr->clrscr ;
        affiche_motif($X_ennemi_1, $Y_ennemi_1, @ennemi) ;
        affiche_motif($X_ennemi_2, $Y_ennemi_2, @ennemi) if ( $count > 10 ) ;
        affiche_motif($X_obstacle_1, $Y_obstacle_1, @obstacle) ;
        affiche_motif($X_obstacle_2, $Y_obstacle_2, @obstacle) ;
        affiche_motif($X_obstacle_3, $Y_obstacle_3, @obstacle) ;
        affiche_motif($X_obstacle_4, $Y_obstacle_4, @obstacle) ;
        affiche_motif($X_vaisseau, $Y_vaisseau, @vaisseau) ;

        sleep(0.1) ;
    }

    # pour rester dans les dimensions de la scene
    # x et y pouvant grossir ou etre < 0
    $X_vaisseau = $X_vaisseau % ($screenX + 1) ;
    $Y_vaisseau = $Y_vaisseau % ($screenY + 1) ;

    my $up    = 65 ;
    my $down  = 66;
    my $right = 67 ;
    my $left  = 68 ;

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

    ($row -= ($screenX + 1)) if ( $row > $screenX ) ;
    ($row += ($screenX + 1)) if ( $row < 0 ) ;
    ($col -= ($screenY + 1)) if ( $col > $screenY ) ;
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
    my $x_vaisseau   = shift ;
    my $y_vaisseau   = shift ;
    my @obj = @_ ;

    foreach my $i ( 0 .. 2 ) {
        foreach my $j ( 0 .. 2 ) {
            my $x = $x_vaisseau + $i ;
            my $y = $y_vaisseau + $j ;

            if ( $obj[$i][$j] ne ' ' ) {
                foreach my $a_ref ( @liste_noire ) {
                    if (    ( $a_ref->{'x'} == $x )
                        and ( $a_ref->{'y'} == $y ) )
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
            my $x = $X_obstacle_1 + $i ;
            my $y = $Y_obstacle_1 + $j ;
            push @liste , { 'x' => $x , 'y' => $y } ;
        }
    }

    foreach my $i ( 0 .. 2 ) {
        foreach my $j ( 0 .. 2 ) {
            my $x = $X_obstacle_2 + $i ;
            my $y = $Y_obstacle_2 + $j ;
            push @liste , { 'x' => $x , 'y' => $y } ;
        }
    }

    foreach my $i ( 0 .. 2 ) {
        foreach my $j ( 0 .. 2 ) {
            my $x = $X_obstacle_3 + $i ;
            my $y = $Y_obstacle_3 + $j ;
            push @liste , { 'x' => $x , 'y' => $y } ;
        }
    }

    foreach my $i ( 0 .. 2 ) {
        foreach my $j ( 0 .. 2 ) {
            my $x = $X_obstacle_4 + $i ;
            my $y = $Y_obstacle_4 + $j ;
            push @liste , { 'x' => $x , 'y' => $y } ;
        }
    }

    push @liste , { 'x' => $X_ennemi_1 ,     'y' => $Y_ennemi_1 } ;
    push @liste , { 'x' => $X_ennemi_1 + 1 , 'y' => $Y_ennemi_1 } ;

    push @liste , { 'x' => $X_ennemi_2 ,     'y' => $Y_ennemi_2 } ;
    push @liste , { 'x' => $X_ennemi_2 + 1 , 'y' => $Y_ennemi_2 } ;

    use Storable ;
    store \@liste , 'fichier' ;
    return @liste ;
}
