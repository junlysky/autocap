#!/use/bin/env perl
use strict;
use warnings;
$ENV{SAC_DISPLAY_COPYRIGHT}=0;
    
my $usage="perl $0 eventdir fp1 fp2 fp3 fp4";
@ARGV == 5 or die "Usage: $usage \n";

our $eventdir = $ARGV[0];
our $fp1=$ARGV[1];
our $fp2=$ARGV[2];
our $fp3=$ARGV[3];
our $fp4=$ARGV[4];

$eventdir = "rtzdata/$eventdir";
system ("cp ./rdsta.pl  $eventdir/");
chdir $eventdir;
my $pwd = `pwd`;
chomp($pwd);
print "$pwd\n";

open(IN,"< weight.dat");
our @lines = <IN>;
chomp(@lines);
close(IN);

my $i=0;
our @sta ;
our @star ;
our @stat ;
our @staz ;

while($i<@lines){
	$lines[$i]=~s/^\s+//;
	$lines[$i]=~//g;

	our @ddd = split /\s+/,$lines[$i];
        push @sta,$ddd[0];
	$star[$i] = "$sta[$i].r";
	$stat[$i] = "$sta[$i].t";
	$staz[$i] = "$sta[$i].z";
	$i++;
}

open(SAC,"|sac") or die "Error opening sac ";
print SAC "r ./@staz \n";
print SAC "color red incre  \n";
print SAC "rmean \n";
print SAC "taper \n";
print SAC "bp c $fp1 $fp2 \n";
print SAC "dif two \n";
print SAC "p1 \n";
print SAC "save Pv.ps \n";

print SAC "r ./@staz \n";
print SAC "rmean \n";
print SAC "taper \n";
print SAC "bp c $fp3 $fp4 \n";
print SAC "dif two \n";
print SAC "p1 \n";
print SAC "save Sv.ps \n";

print SAC "r ./@stat \n";
print SAC "rmean \n";
print SAC "taper \n";
print SAC "bp c $fp3 $fp4 \n";
print SAC "dif two \n";
print SAC "p1 \n";
print SAC "save SH.ps \n";

print SAC "r ./@star \n";
print SAC "rmean \n";
print SAC "taper \n";
print SAC "bp c $fp1 $fp2 \n";
print SAC "dif two \n";
print SAC "p1 \n";
print SAC "save PR.ps \n";

print SAC "r ./@star \n";
print SAC "rmean \n";
print SAC "taper \n";
print SAC "bp c $fp3 $fp4 \n";
print SAC "dif two \n";
print SAC "p1 \n";
print SAC "save SR.ps \n";

print SAC "quit \n";
close(SAC);


