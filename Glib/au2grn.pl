#!/usr/bin/env perl
use strict;
use warnings;

use File::Basename qw/basename dirname/;
use List::Util qw/max min/;
use Time::Local;
use POSIX qw/strftime/;
use File::Copy;

# auto cumpute the weight.dat and model.dat in the EQevent,and rename the model.dat to event name,
# then auto compute the green functions 
# 当选择model模式时，请确保当前目录下准备好速度模型model文件
my $rtzpath = "/home/junlysky/autocap/rtzdata";
my $glibdir = "/home/junlysky/autocap/Glib";
mkdir "$glibdir",0755 if !-e $glibdir;

open(IN, "< /home/junlysky/au2cap/Glib/mulu.eqt");
our @lines = <IN>;
chomp(@lines);
close(IN);
our %event_of;

foreach my $line (@lines){
   my ($date,$time,$lat,$lon,$dep,$mag,$magtp)=split /\s+/,$line;
   my ($year,$mon,$mday) = split /\//,$date;
   my ($hour,$min,$sec) = split /\:/,$time;
   my $msec;
   ($sec,$msec) = split /\./,$sec;
   $mon = $mon-1;
   my $gmt_time = timelocal("$sec","$min", "$hour", "$mday", "$mon","$year") - 8*3600 ;
   $year = strftime "%Y",localtime($gmt_time);
   $mday = strftime "%d",localtime($gmt_time);
   $hour = strftime "%H",localtime($gmt_time);
   $min=strftime "%M",localtime($gmt_time);
   $sec=strftime "%S",localtime($gmt_time);
   $mon=strftime "%m",localtime($gmt_time);

#   print "$mon $mday\n";
   my $key = "${year}${mon}${mday}${hour}${min}${sec}";
   $event_of{$key} = $line;
 #   print $event_of{$key};
 #  print "\n";
}

our @sortorder = sort keys %event_of ;

printf "请选择所使用的速度模型: crust1.0 or model \n";
my $std=<STDIN>;
chomp($std);

##########################  crust1.0 start  ####################
if ( $std eq "crust1.0"){

    foreach my $key (@sortorder) {
    #  print "$key $event_of{$key}\n";
        our ($date,$time,$lat,$lon,$dep,$mag,$magtp)=split /\s+/,$event_of{$key};
        our $event = $key ;
        our $dist_min = 20;
        our $dist_max = 180; #震中距
        our $fname = "weight.dat";
        our $fsta = "stalist.dat";
        our ($ffname,$sta,$net,$dist,$tp,$stla,$stlo);
        our @dists;
        open(STA,">$fsta");
        open(FL,">$fname");  #KNETWK
          my $pwd = `pwd` ;
          chomp($pwd);
        our $path = "$rtzpath/$event";
            foreach our $file ( glob( "$path/*.z") )  {
            our  $sacfile = basename $file ;
            $path = dirname $file ;
            print "$path/$sacfile\n";
            ($ffname,$sta,$net,$dist,$tp,$stla,$stlo) = split /\s+/, `saclst kstnm knetwk dist a stla stlo  f $path/$sacfile`;
            $dist=int($dist);
            #  print  "$dist\n";
            push @dists,$dist;

            if($tp<-1000){
                $tp=0;
            }

            if($dist<=$dist_max and $dist>=$dist_min)
            {
                print FL "$sta.$net  $dist   1 1 1 1 1   $tp  0 \n";
                print STA "$sta.$net $dist $stla $stlo \n";
            }
        }
        system ("sort -k2n $fname -o $fname");
        my $glibevent = "$glibdir/$event";
        mkdir "$glibevent",0755 if !-e $glibevent;
        system ("cp ./grn.pl $glibevent");
        system ("cp $fname $glibevent/");
        system ("sort -k2n $fsta -o $fsta");
        system ("cp $fsta $glibevent/");
        system ("mv $fname $path/ ");
        system ("mv $fsta $path/ ");
        close(FL);
        close(STA);

        open( CRUST,"| crust1.0");
        print CRUST "$lat $lon \n";
        print CRUST "q \n";
        close(CRUST);
        system ("mv model.dat $glibevent/");
        system ("mv $glibevent/model.dat $glibevent/$event");
        chdir $glibevent;
        system ("/home/wqc/au2cap/Glib/grn.pl $event 3 4 1 ");
        chdir $pwd;
        }
    }   
##########################  model start  ####################
elsif ($std eq "model"){

    foreach my $key (@sortorder) {
        #  print "$key $event_of{$key}\n"; 
        our ($date,$time,$lat,$lon,$dep,$mag,$magtp)=split /\s+/,$event_of{$key};
        our $event = $key ;
        our $dist_min = 20;
        our $dist_max = 180; #震中距
        our $fname = "weight.dat";
        our $fsta = "stalist.dat";
        our ($ffname,$sta,$net,$dist,$tp,$stla,$stlo);
        our @dists;
        open(STA,">$fsta");
        open(FL,">$fname");  #KNETWK
        my $pwd = `pwd` ;
        chomp($pwd);
        our $path = "$rtzpath/$event";
        foreach our $file ( glob( "$path/*.z") )  {
        our  $sacfile = basename $file ;
        $path = dirname $file ;
         print "$path/$sacfile\n";
        ($ffname,$sta,$net,$dist,$tp,$stla,$stlo) = split /\s+/, `saclst kstnm knetwk dist a stla stlo  f $path/$sacfile`;
        $dist=int($dist);
        #  print  "$dist\n";
        push @dists,$dist;

        if($tp<-1000){
            $tp=0;
        }

        if($dist<=$dist_max and $dist>=$dist_min)
        {
            print FL "$sta.$net  $dist   1 1 1 1 1   $tp  0 \n";
            print STA "$sta.$net $dist $stla $stlo \n";
        }
    }
    system ("sort -k2n $fname -o $fname");
    my $glibevent = "$glibdir/$event";
    mkdir "$glibevent",0755 if !-e $glibevent;
    system ("cp ./grn.pl $glibevent");
    system ("cp $fname $glibevent/");
    system ("sort -k2n $fsta -o $fsta");
    system ("cp $fsta $glibevent/");
    system ("mv $fname $path/ ");
    system ("mv $fsta $path/ ");
    close(FL);
    close(STA);

    system ("cp model $glibevent/");
    system ("mv $glibevent/model $glibevent/$event");
    chdir $glibevent;
    system ("/home/junlysky/au2cap/Glib/grn.pl $event 5 6 1 ");     
    chdir $pwd;
    }

}

else {
     print "input error \n";
     }



