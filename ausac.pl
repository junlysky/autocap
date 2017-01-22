#!/use/bin/env perl
use strict;
use warnings;
use Time::Local;
use POSIX qw/strftime/;
use File::Basename qw/basename dirname/;
use List::Util qw/max min/;
use Date::Calc qw/Add_Delta_Days/;


my $usage = "perl $0 catalog_file_name SEED_directory";
@ARGV == 2 or die "$usage\n";
#my $catalog = $ARGV[0];
#my $seed_dir= $ARGV[1];
my ($catalog,$seed_dir) = @ARGV;

open(IN, "< catalog/$catalog");
my @lines = <IN>;
chomp(@lines);
close(IN);

our $sacdir = "sacdata";
mkdir "$sacdir",0755 if !-e $sacdir;
our $rtzdir = "rtzdata";
mkdir  "$rtzdir",0755 if !-e $rtzdir;


our $path1 = $sacdir;
our $path2 = $rtzdir;

our ($i,$j);
our ($path,$seeddir,$seedfile);
our ($year,$mon,$mday,$hour,$min,$sec,$msec,$mmsec,$lat,$lon,$dep,$mag,$magtp);
our ($date,$time);
our $gmt_time;
our ($eventdir,$eventdir2,$eventnm);

our %event_of;
foreach my $line (@lines){
    ($date,$time,$lat,$lon,$dep,$mag,$magtp)=split /\s+/,$line;
    ($year,$mon,$mday) = split /\//,$date;
    ($hour,$min,$msec) = split /\:/,$time;
    ($sec,$mmsec) = split /\./,$msec;
    $mon = $mon-1;
    $gmt_time=timelocal("$sec","$min","$hour","$mday","$mon","$year")-8*3600 ;
    $year = strftime "%Y",localtime($gmt_time);
    $mday = strftime "%d",localtime($gmt_time);
    $hour = strftime "%H",localtime($gmt_time);
    $min=strftime "%M",localtime($gmt_time);
    $sec=strftime "%S",localtime($gmt_time);
    $mon=strftime "%m",localtime($gmt_time);

    my $key = "${year}${mon}${mday}${hour}${min}${sec}";
    $event_of{$key} = $line;
    #    our @sortorder = sort keys %event_of ;  # sort the eqt
    #    foreach my $key (@sortorder) { }

    my $pwd = `pwd`;
    chomp($pwd);
    $path = $pwd;
    $seeddir = "seed/$seed_dir/$year/$year$mon";  
    $eventnm = $key;
    $eventdir = "$sacdir/$eventnm";
    $eventdir2= "$rtzdir/$eventnm";
  #  $msec = sprintf("%03d", int($msec*10+0.5) );
    $msec = sprintf("%03d", int($msec*10) );
    $seedfile = "$year$mon$mday$hour$min$msec.IGP.SEED";
    my $seedfile2 = "$year$mon$mday$hour$min*.IGP.SEED";  # 模糊识别
    print "$line\n$seedfile\n";
    mkdir "$eventdir",0755 if !-e $eventdir;
    mkdir "$eventdir2",0755 if !-e $eventdir2;
    system("cp $seeddir/$seedfile  $eventdir/");
    system("rdseed -Rdf $seeddir/$seedfile -q $eventdir ");
    system("perl presac.pl $eventnm $lat $lon $path1 $path2");
    system("perl rota.pl   $eventnm $path2");

}

