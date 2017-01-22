#!/usr/bin/env perl
use warnings;
use strict;

my $usage="perl $0 model_depth/mag event dep_max dep_delt";
@ARGV == 4 or die "$usage \n";
my($model,$dep,$mag);
$model=$ARGV[0];
($model,$dep)=split /\_/,$model;
($dep,$mag) =split /\//,$dep;
my $event =$ARGV[1];
my $dp_max=$ARGV[2];
my $dp_delt=$ARGV[3];

my $w = 1;					# -W
my $pscle =0.75e-6/42; 		# -P
my ($f1_pnl,$f2_pnl,$f1_sw,$f2_sw) = (0.05,0.2,0.05,0.12); 		# -C
my $L = 0.5;          		# -L
my $dt = 0.05; 				# -H
my $repeat = 0;				# -N
my ($deg,$dm) = (10,0.1); 	# -I
my ($m1,$m2) = (30,70);		# -T
my $wnm ="weight.dat";		# -Z

my $J="-J0/0/0.1/0.1";

my $Glib="/media/junlysky/00028BD3000AFE03/研究区域/广西5级地震/newglib";# -G
my ($max_shft1,$max_shift2,$tie) = (5,5,0);  	# -S
my ($weight_of_pnl,$power_of_body,$power_of_surf) = (1.2,0.8,0.2);  # -D

###Don`t change ################################################################
while( $dep <=$dp_max ){
	system("perl gcap.pl  -C$f1_pnl/$f2_pnl/$f1_sw/$f2_sw ".
		   "-D$weight_of_pnl/$power_of_body/$power_of_surf -F -L$L -G$Glib ".
		   "-H$dt -I$deg/$dm  -M$model\_$dep/$mag -P0.1e-7/42 -R0/360/0/90/-180/180 ".
		   "-S$max_shft1/$max_shift2/$tie -T$m1/$m2 -X0 -Z$wnm $event");
	$dep += $dp_delt;
}
#################################################################################
