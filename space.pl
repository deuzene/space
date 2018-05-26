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

# ## INITIALISATIONS #######################################################
$scr->clrscr() ;   # on efface l'ecran
$scr->curinvis() ; # curseur invisible
$scr->noecho() ;   # rendre les frappe invisible

# dimension de la scène
# l'origine etant a 0,0
# la scene fait 1 de moins
my $screenX = 19 ;
my $screenY = 39 ;

# definition des motifs des elements
# le vaisseau
my @vaisseau = ( ['/','O','\\'],
                 ['«','-','»'],
                 ['*',' ','*'] ) ;
my ($X_vaisseau, $Y_vaisseau) = (19, 18) ; # position de depart

# l'obstacle_1
my @obstacle = ( [' ','*',' '],
                 ['*','*','*'],
                 [' ','*',' '] ) ;

# positions de depart
my ($X_obstacle_1, $Y_obstacle_1) = (9, 5) ;
my ($X_obstacle_2, $Y_obstacle_2) = (9, 15) ;
my ($X_obstacle_3, $Y_obstacle_3) = (9, 25) ;
my ($X_obstacle_4, $Y_obstacle_4) = (9, 35) ;

# l'ennemi
my @ennemi = ( ['@'],
               ['↓'] ) ;

# positions de depart
my $X_ennemi_1 = 0 ;
my $Y_ennemi_1 = int( rand(40) ) ;

my $X_ennemi_2 = 0 ;
my $Y_ennemi_2 = int( rand(40) ) ;

# permet de diluer l'arrivee des ennemis
my $count = 0 ;

# liste des coordonnes ou ca fait BOUM
my @liste_noire ;

# variable qui va recevoir la touche pressee
my $key ;
ReadMode 3 ;
# ## fin INITIALISATIONS ####################################################

# ## BOUCLE PRINCIPALE ######################################################
while (1) {
    # pour que les vaisseaux aillent deux fois
    # moins vite que la lecture de touche
    # drapeau qui bascule a chaque tour
    my $un_sur_deux = 0 ;

    # tant qu'une touche n'est pas appuyee
    # on deplace les ennemis
    while ( not defined ($key = ReadKey(-1)) ) {
        if ( $un_sur_deux ) {
            $X_ennemi_1++ ;
            $X_ennemi_1 = $X_ennemi_1 % ($screenX + 1) ;
            $Y_ennemi_1 += int( rand(2) ) -1 ;
            $Y_ennemi_1 = $Y_ennemi_1 % ($screenY + 1) ;

            # l'ennemi 2 n'apparait qu'au 10eme tour
            if ( $count > 10 ) {
                $X_ennemi_2++ ;
                $X_ennemi_2 = $X_ennemi_2 % ($screenX + 1) ;
                $Y_ennemi_2 += int( rand(2) ) -1 ;
                $Y_ennemi_2 = $Y_ennemi_2 % ($screenY + 1) ;
            }

            # peuplement de @liste_noire
            @liste_noire = liste_noire () ;
            # on compte les tours
            $count++ ;

        }

        # basculement du drapeu a chaque tour
        if ( $un_sur_deux == 0 ) {
            $un_sur_deux = 1 ;
        } else {
            $un_sur_deux = 0 ;
        }

        # affichage ddes ennemis, des obstacles et du vaisseau
        $scr->clrscr ;
        affiche_motif($X_ennemi_1, $Y_ennemi_1, @ennemi) ;
        affiche_motif($X_ennemi_2, $Y_ennemi_2, @ennemi) if ( $count > 10 ) ;
        affiche_motif($X_obstacle_1, $Y_obstacle_1, @obstacle) ;
        affiche_motif($X_obstacle_2, $Y_obstacle_2, @obstacle) ;
        affiche_motif($X_obstacle_3, $Y_obstacle_3, @obstacle) ;
        affiche_motif($X_obstacle_4, $Y_obstacle_4, @obstacle) ;
        affiche_motif($X_vaisseau, $Y_vaisseau, @vaisseau) ;

        # delai
        sleep(0.1) ;
    }

    # une touche a ete pressee
    #
    # pour rester dans les dimensions de la scene
    # x et y pouvant grossir ou etre < 0
    $X_vaisseau = $X_vaisseau % ($screenX + 1) ;
    $Y_vaisseau = $Y_vaisseau % ($screenY + 1) ;

    # correspondance des touches
    # avec leur code
    my $up    = 65 ;
    my $down  = 66;
    my $right = 67 ;
    my $left  = 68 ;

    # deplacement a droite
    if ( ord($key) == $right ) {
        $Y_vaisseau++ ;
        # on verifie que le vaisseau ne rentre
        # pas en collision avec un autre objet
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
    # deplacement a gauche
    if ( ord($key) == $left ) {
        $Y_vaisseau-- ;
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
    # deplacement a haut
    if ( ord($key) == $up ) {
        $X_vaisseau-- ;
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
    # deplacement a bas
    if ( ord($key) == $down ) {
        $X_vaisseau++ ;
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
} # fin boucle infinie

# # sortie : pour l'instant jamais atteint
# $scr->curvis() ; # curseur visible
# $scr->echo() ;   # rendre les frappe visible
# ReadMode 0 ;
# ## fin BOUCLE PRINCIPALE ##################################################

# ############################################################################
# sub    : affiche_motif
# desc.  : affiche le motif passe en argument
# usage  : affiche_motif($x, $y, @motif)
# arg.   :
# retour :
# ############################################################################
sub affiche_motif {
    my ($row, $col, @motif) = @_ ;

    # pour rester dans la scene
    ($row -= ($screenX + 1)) if ( $row > $screenX ) ;
    ($row += ($screenX + 1)) if ( $row < 0 ) ;
    ($col -= ($screenY + 1)) if ( $col > $screenY ) ;
    ($col += ($screenY + 1)) if ( $col < 0 ) ;

    # affichage du motif
    # le motif fait max. 3x3
    foreach my $offset_x ( 0 .. 2 ) {
        foreach my $offset_y ( 0 .. 2 ) {
            my $x = $row + $offset_x ;
            my $y = $col + $offset_y ;
            if ( defined $motif[$offset_x][$offset_y] ) { ;
                # affichage du caractere aux coordonnees $x,$y
                my $char = $motif[$offset_x][$offset_y] ;
                $scr->at($x,$y)->puts("$char") ;
            }
        }
    }
    return ;
}

# ############################################################################
# sub    : verif_impact
# desc.  : verifie que le vaisseau ne rentre pas en colision avec
# une des coordonees de @liste_noire
# usage  : verif_impact($X_vaisseau,$Y_vaisseau,@motif)
# arg.   :
# retour :
# ############################################################################
sub verif_impact {
    my $x_vaisseau   = shift ;
    my $y_vaisseau   = shift ;
    my @l_collisions = @_ ;

    # on parcours chaque coordonee
    # du motif du vaisseau
    foreach my $i ( 0 .. 2 ) {
        foreach my $j ( 0 .. 2 ) {
            my $x = $x_vaisseau + $i ;
            my $y = $y_vaisseau + $j ;

            # suivant l'apparence du vaisseau
            # il n'y a que les cases occupees
            # qui provoque la collision
            if ( $l_collisions[$i][$j] ne ' ' ) {
                # comparaison avec la liste_noire
                foreach my $a_ref ( @liste_noire ) {
                    if (    ( $a_ref->{'x'} == $x )
                        and ( $a_ref->{'y'} == $y ) )
                    {
                        # le joueur a perdu
                        # zolie animation et sortie
                        game_over () ;
                    }
                }
            }
        }
    }
    return ;
}

# ############################################################################
# sub    : game_over
# desc.  : simule une explosion, affiche le message GAME OVER et quitte
# usage  : game_over ()
# arg.   :
# retour :
# ############################################################################
sub game_over {
    # simulation de l'explosion par affichage
    # de BOUM aleatoirement sur la scene
    foreach (1 .. 100) {
        my $x = int( rand(20) ) ;
        my $y = int( rand(40) ) ;

        $scr->at($x,$y)->puts("BOUM") ;
        sleep(0.01) ;
    }

    # affichage de GAME OVER au centre de la scene
    # chaines a afficher
    my @game_over_str = (
        '                 ',
        '  *************  ',
        '  * GAME OVER *  ',
        '  *************  ',
        '                 ',
    ) ;

    # affichage des chaines
    foreach my $i ( 0 .. 4 ) {
        $scr->at(7+$i,13) ;
        $scr->puts($game_over_str[$i]) ;
    }

    # sortie du programme
    $scr->at(25,0) ;
    $scr->curvis() ; # curseur visible
    $scr->echo() ;   # rendre les frappe visible
    ReadMode 0 ;
    exit ;
}

# ############################################################################
# sub    : liste_noire
# desc.  : construire la liste des coordonees (x => lignes, y => colonnes)
#          des cases qui provoquent l'explosion du vaisseau
# usage  : my @liste = liste_noire () ;
# arg.   :
# retour : une liste (AoA) de coordonnes
# ############################################################################
sub liste_noire {
    my @liste ;

    # coordonnees des obstacles
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

    # coordonnees des ennemis
    push @liste , { 'x' => $X_ennemi_1 ,     'y' => $Y_ennemi_1 } ;
    push @liste , { 'x' => $X_ennemi_1 + 1 , 'y' => $Y_ennemi_1 } ;

    push @liste , { 'x' => $X_ennemi_2 ,     'y' => $Y_ennemi_2 } ;
    push @liste , { 'x' => $X_ennemi_2 + 1 , 'y' => $Y_ennemi_2 } ;

    return @liste ;
}
