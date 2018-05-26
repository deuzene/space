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

### $r_list

