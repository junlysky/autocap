#!/usr/bin/env perl
use diagnostics;
use warnings;
use strict;
use File::Copy;
#require "./fk.pl";
# This program is to generate green fuctions using FK
# make sure having weight.dat file which has the distance information

my $usage = "Usage: perl $0 model depth dp_max dp_delt \n";
@ARGV >=4 or die "$usage";
my $model =$ARGV[0];		#  the model name
my $dep=$ARGV[1];
my $dp_max=$ARGV[2];
my $dp_delt=$ARGV[3];

my $nt =2048;					#  the number of points, must be 2^n 
my $dt =0.05;					#  the sampling interval
my @dist;					#   distances

###  calculate the green fuctions
open(IN, "weight.dat") or die "need the weight.dat file !";
my @lines = <IN>;
chomp(@lines);
close(IN);

my $i=0;
while($i<@lines){
	my ($sta,$dist,$w1,$w2,$w3,$w4,$w5,$tp,$ts) = split /\s+/,$lines[$i++];
	$dist=int($dist);
	push @dist,$dist;
}

while( $dep<$dp_max){
	system("perl /home/junlysky/app/fk3.2/bin/fk.pl -M$model/$dep -N$nt/$dt -S2 @dist");
	system("perl /home/junlysky/app/fk3.2/bin/fk.pl -M$model/$dep -N$nt/$dt -S0 @dist");
	$dep += $dp_delt;
}

