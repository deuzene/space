#!/usr/bin/env perl
use strict ;
use warnings ;
use diagnostics ;

use Time::HiRes qw(sleep) ;
use Term::ReadKey ;
use Term::ANSIColor ;
use Term::Screen ;

# ############################################################################
# prog   : space.pl
# desc.  : petit jeu dans l'espace intersideral
# usage  : space.pl
# ############################################################################
#
# ## INITIALISATIONS #########################################################
#
# pour interrompre le jeu proprement
$SIG{INT} = \&game_over ;

# création/gestion de l'écran
my $scr = Term::Screen->new() ;
$scr->clrscr() ;   # on efface l'ecran
$scr->curinvis() ; # curseur invisible
$scr->noecho() ;   # rendre les frappe invisible

# dimension de la scène
# l'origine étant a 0,0
# la scène fait 1 de moins
my $screenX = 19 ;
my $screenY = 29 ;

# définition des différents objets
# attention à échaper certains caractères
# le vaisseau
my @vaisseau = ( ['/','O','\\'],
                 ['«','-','»'],
                 ['*',' ','*'] ) ;

# position de départ du vaisseau
my ($X_vaisseau, $Y_vaisseau) = (19, 18) ;

# l'obstacle
my @obstacle = ( [' ','*',' '],
                 ['*','*','*'],
                 [' ','*',' '] ) ;

# positions de départ des obstacles
my %X_obstacle ;
my %Y_obstacle ;
($X_obstacle{1}, $Y_obstacle{1}) = (9, 5) ;
($X_obstacle{2}, $Y_obstacle{2}) = (9, 15) ;
($X_obstacle{3}, $Y_obstacle{3}) = (9, 25) ;

# l'ennemi
my @ennemi = ( ['@'],
               ['↓'] ) ;

# positions de départ des ennemeis
my $X_ennemi_1 = 0 ;
my $Y_ennemi_1 = int( rand(40) ) ;

my $X_ennemi_2 = 0 ;
my $Y_ennemi_2 = int( rand(40) ) ;

# bonus
my @bonus = ( [ '[','@',']' ] ) ;
my ($X_bonus, $Y_bonus, @liste_blanche) = creer_bonus() ;

# permet de diluer l'arrivée des ennemis
my $count = 0 ;

my $time ;
my $score    = 0 ;
my $nb_bonus = 0 ;

# liste des coordonnées ou ca fait BOUM
my @liste_noire ;

# variable qui va recevoir la touche pressée
my $key ;
ReadMode 3 ;
# ## fin INITIALISATIONS #####################################################

# ## BOUCLE PRINCIPALE #######################################################
#
while (1) {
    # pour que les vaisseaux aillent deux fois
    # moins vite que la lecture de touche
    # drapeau qui bascule à chaque tour
    my $un_sur_deux = 0 ;

    # tant qu'une touche n'est pas pressée
    # on déplace les ennemis
    while ( not defined ($key = ReadKey(-1)) ) {
        if ( $un_sur_deux ) {
            $X_ennemi_1++ ;
            $X_ennemi_1 = $X_ennemi_1 % ($screenX + 1) ;
            $Y_ennemi_1 += int( rand(2) ) -1 ;
            $Y_ennemi_1 = $Y_ennemi_1 % ($screenY + 1) ;

            # l'ennemi 2 n'apparait qu'au 10ème tour
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

        # affichage des ennemis, des obstacles et du vaisseau
        $scr->clrscr ;
        $time = $count / 10 ;
        $score -= int($time / 2) ;
        $scr->at(23,5)->puts("Score $score\tBonus $nb_bonus\t\t$time") ;

        # bonus
        print color('GREEN') ;
        affiche_motif($X_bonus, $Y_bonus, @bonus) ;
        print color('reset') ;

        # ennemis
        print color('RED') ;
        affiche_motif($X_ennemi_1, $Y_ennemi_1, @ennemi) ;
        affiche_motif($X_ennemi_2, $Y_ennemi_2, @ennemi) if ( $count > 10 ) ;
        print color('reset') ;

        # obstacles
        foreach my $num ( 1 .. 3 ) {
            affiche_motif($X_obstacle{$num}, $Y_obstacle{$num}, @obstacle) ;
        }

        # vaisseau
        print color('BLUE') ;
        affiche_motif($X_vaisseau, $Y_vaisseau, @vaisseau) ;
        print color('reset') ;

        # délai
        sleep(0.1) ;
    }

    # une touche à été pressée
    #
    # pour rester dans les dimensions de la scène
    # x et y pouvant grossir ou etre < 0
    $X_vaisseau = $X_vaisseau % ($screenX + 1) ;
    $Y_vaisseau = $Y_vaisseau % ($screenY + 1) ;

    # correspondance des touches
    # avec leur code
    my $up    = 65 ;
    my $down  = 66;
    my $right = 67 ;
    my $left  = 68 ;

    # déplacement à droite
    if ( ord($key) == $right ) {
        $Y_vaisseau++ ;
        # on verifie que le vaisseau ne rentre
        # pas en collision avec un autre objet
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
    # déplacement à gauche
    if ( ord($key) == $left ) {
        $Y_vaisseau-- ;
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
    # déplacement vers le haut
    if ( ord($key) == $up ) {
        $X_vaisseau-- ;
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
    # déplacement vers le bas
    if ( ord($key) == $down ) {
        $X_vaisseau++ ;
        verif_impact($X_vaisseau, $Y_vaisseau, @vaisseau) ;
    }
} # fin boucle infinie

# ## fin BOUCLE PRINCIPALE ###################################################

# ## FONCTIONS ###############################################################
#
# ############################################################################
# sub    : affiche_motif
# desc.  : affiche le motif passé en argument
# usage  : affiche_motif($x, $y, @motif)
# arg.   :
# retour :
# ############################################################################
sub affiche_motif {
    my ($row, $col, @motif) = @_ ;

    # pour rester dans la scène
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
# desc.  : vérifie que le vaisseau ne rentre pas en collision avec
#          une des coordonées de @liste_noire
# usage  : verif_impact($X_vaisseau,$Y_vaisseau,@motif)
# arg.   :
# retour :
# ############################################################################
sub verif_impact {
    my $x_vaisseau   = shift ;
    my $y_vaisseau   = shift ;
    my @l_collisions = @_ ;

    # on parcours chaque coordonée
    # du motif du vaisseau
    foreach my $i ( 0 .. 2 ) {
        foreach my $j ( 0 .. 2 ) {
            my $x = $x_vaisseau + $i ;
            my $y = $y_vaisseau + $j ;

            # suivant l'apparence du vaisseau
            # il n'y a que les cases occupées
            # qui provoque la collision
            # comparaison avec la liste_noire
            foreach my $a_ref ( @liste_noire ) {
                if ( ( $a_ref->{'x'} == $x )
                     and ( $a_ref->{'y'} == $y ) )
                {
                    # le joueur a perdu
                    # zolie animation et sortie
                    game_over () ;
                }
            }
            foreach my $a_ref ( @liste_blanche ) {
                if ( ( $a_ref->{'x'} == $x )
                     and ( $a_ref->{'y'} == $y ) )
                {
                    # le joueur a atteint le bonus
                    you_win () ;
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
    # de 100 BOUM aléatoirement sur la scène
    $scr->clrscr() ;

    foreach (1 .. 150) {
        # position aléatoire
        my $x = int( rand(20) ) ;
        my $y = int( rand(40) ) ;

        # on affiche un message parmi une liste
        my @l_msg = qw/BIM BAM BOOM/ ;
        my $msg = $l_msg[ int(rand(3)) ] ;

        # une couleur au hasard
        my @l_colors = qw/RED GREEN BLUE YELLOW MAGENTA/ ;
        my $color = $l_colors[ int(rand($#l_colors)) ] ;

        print color($color) ;

        # affichage
        $scr->at($x,$y)->puts($msg) ;

        # délai
        sleep(0.01) ;
    }

    print color('reset') ;
    # affichage de GAME OVER au centre de la scène
    # avec le score dépendant du temps
    $score -= $time * 10 ;
    # chaines a afficher
    my @game_over_str = (
        '                     ',
        '    *************    ',
        '    * GAME OVER *    ',
        '    *************    ',
        '                     ',
        "    score $score           ",
        '                     ',
    ) ;

    # affichage des chaines
    foreach my $i ( 0 .. $#game_over_str ) {
        $scr->at(7+$i,10) ;
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
# desc.  : construire la liste des coordonées (x => lignes, y => colonnes)
#          des cases qui provoquent l'explosion du vaisseau
# usage  : my @liste = liste_noire () ;
# arg.   :
# retour : une liste (AoH) de coordonnées
# ############################################################################
sub liste_noire {
    # AoH - liste de coordonées x,y
    # avec lesquelles le vaisseau
    # entre en collision
    my @liste ;

    # peuplement de la liste avec les
    # coordonnées des obstacles
    #
    # l'obstacle fait 3 lignes x 3 colonnes
    # on parcours le motif en incrémentant x et y
    # pour remplir un hash anonyme avec les valeurs
    # de x et y. Ce hash est poussé dans @liste

    foreach my $o ( 0 .. 2 ) {
        foreach my $i ( 0 .. 2 ) {
            foreach my $j ( 0 .. 2 ) {
                foreach my $num ( 1 .. 3 ) {
                    my $x = $X_obstacle{$num} + $i ;
                    my $y = $Y_obstacle{$num} + $j ;

                    # la liste est un AoH
                    push @liste , { 'x' => $x , 'y' => $y } ;
                }
            }
        }
    }

    # peuplement de la liste avec les
    # coordonnées des ennemis
    #
    # les ennenmi font 2 lignes x 1 colonne
    # la liste est un AoH
    # ennemi_1
    push @liste , { 'x' => $X_ennemi_1 ,     'y' => $Y_ennemi_1 } ;
    push @liste , { 'x' => $X_ennemi_1 + 1 , 'y' => $Y_ennemi_1 } ;

    # ennemi_2
    push @liste , { 'x' => $X_ennemi_2 ,     'y' => $Y_ennemi_2 } ;
    push @liste , { 'x' => $X_ennemi_2 + 1 , 'y' => $Y_ennemi_2 } ;

    # retour fonction
    return @liste ;
}

sub creer_bonus {
    my $x = int( rand(20) ) ;
    my $y = int( rand(30) ) ;
    my @liste ;

    foreach my $i ( 0 .. 2 ) {
        $y += $i ;
        push @liste , { 'x' => $x , 'y' => $y } ;

        if ( $y == 0 or $y == 1 ) {
            creer_bonus() ;
        } else {
            foreach my $a_ref ( @liste_noire ) {
                if (     ( $a_ref->{'x'} == $x )
                        and ( $a_ref->{'y'} == $y ) )
                {
                    creer_bonus() ;
                }
            }
        }
    }
    return ($x,$y,@liste) ;
}

sub you_win {
    $score += 100 ;
    $nb_bonus++ ;
    ($X_bonus, $Y_bonus, @liste_blanche) = creer_bonus() ;
}

# ## fin FONCTIONS ###########################################################
