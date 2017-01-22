#!/usr/bin/env perl
use warnings;
use strict;

use File::Basename qw/basename dirname/; 
# make the weight.dat and the station list file

my $usage="Usage:perl $0 event";
@ARGV == 1 or die ("$usage \n");
our $event = $ARGV[0];

our $dist_min = 0;
our $dist_max = 500;
our $fname = "weight.dat";
our $fsta = "stalist.dat";

our ($ffname,$sta,$net,$dist,$a,$tp,$ts,$stla,$stlo,$azi);
our @dists;
open(STA,">$fsta");
open(FL,">$fname");  #KNETWK

my $pwd = `pwd` ;
chomp($pwd);

our $path = "rtzdata/$event";
#print "$path\n";

foreach our $file ( glob( "$path/*.z") )  {
    our  $sacfile = basename $file ;
    $path = dirname $file ;
  #  print "$path/$sacfile\n";
    ($ffname,$sta,$net,$dist,$a,$tp,$ts,$stla,$stlo,$azi) = split /\s+/, `saclst kstnm knetwk dist a t0 t1 stla stlo az f $path/$sacfile`;
    $dist=int($dist);
  #  print  "$dist\n";
    push @dists,$dist;

    if($tp<-1000){
    	$tp=0;
    }

    if($dist<=$dist_max and $dist>=$dist_min)
    {
      print FL "$sta.$net  $dist   1 1 1 1 1   $tp  0 \n";
      print STA "$sta.$net $dist $stla $stlo $azi\n";
    }
}
system ("sort -k2n $fname -o $fname");
system ("mv $fname $path/ ");
system ("sort -k2n $fsta -o $fsta");
system ("mv $fsta $path/ ");
close(FL);
close(STA);
