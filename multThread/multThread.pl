#!/usr/bin/perl  
use strict;
use warnings;
use threads;
use threads::shared; 

# lon and lat
# Bai Jiatan
#       lon 103E - 103E
#       lat 27N -  27N


my $threadNum=15;

my $share:shared=0;

my ($lon1,$lon2)=(103,103);
my ($lat1,$lat2)=(27,27);
my @dist1 = 1..50;
my @dist2 = 51..150;
my @dist3 = 151..370;
my @dep = 1..30;

my $start = time;

sub consume(){
	my ($lat,$lon)=@_;
	printf("$lat|$lon\n");
	my $r2="lat=$lat|lon=$lon";
	my $glibdir = "N".int($lat)."E".int($lon);
	my $pwd = `pwd`;
	chomp($pwd);
	printf("Current Path: $pwd|Consume:$r2\n");
	#chdir "$glibdir";
	foreach my $dep (@dep) {
		my $dt = 0.05;
		my $nt = 1024;
		#printf("Cmd1: perl ./fk.pl -M$glibdir/$dep -N$nt/$dt -S2 @dist1\n");
		#printf("Cmd2: perl ./fk.pl -M$glibdir/$dep -N$nt/$dt -S0 @dist1\n");
		system("chdir $glibdir;perl ../fk.pl -M$glibdir/$dep -N$nt/$dt -S2 @dist1");
		system("chdir $glibdir;perl ../fk.pl -M$glibdir/$dep -N$nt/$dt -S0 @dist1");

		$dt = 0.05;
		$nt = 2048;
		system("chdir $glibdir;perl ../fk.pl -M$glibdir/$dep -N$nt/$dt -S2 @dist2");
		system("chdir $glibdir;perl ../fk.pl -M$glibdir/$dep -N$nt/$dt -S0 @dist2");

		$dt = 0.05;
		$nt = 4096;
		system("chdir $glibdir;perl ../fk.pl -M$glibdir/$dep -N$nt/$dt -S2 @dist3");
		system("chdir $glibdir;perl ../fk.pl -M$glibdir/$dep -N$nt/$dt -S0 @dist3");
	}
	#chdir $pwd;
}


my @array = ();

#将经纬度转入到数组中
for (my $lat = $lat1; $lat <= $lat2; $lat ++){
	for (my $lon = $lon1; $lon <= $lon2; $lon ++){
		my $r="lat=$lat|lon=$lon";
		my $task="$lat,$lon";
		push @array,$task;

		my $glibdir = "N".int($lat)."E".int($lon);
		my $pwd = `pwd`;
		chomp($pwd);
		mkdir "$glibdir",0755 if !-e $glibdir;
		chdir "$glibdir";
		#$pwd = `pwd`;
		#chomp($pwd);
		#printf ("Path: $pwd------------------------------------------------------\n");
		#lock($share);
		open( CRUST,"| crust1.0");
			print CRUST "$lat  $lon \n";
			print CRUST "q \n";
		close(CRUST);

		#$pwd = `pwd`;
		#chomp($pwd);
		#printf ("Path: $pwd++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
		system ("mv model.dat $glibdir");
		chdir "$pwd";

	}
}
my $length=@array;
printf("CreateTaskNum: $length\n");

my $i=0;

for($i=0;$i < $length; $i+=$threadNum){
#	printf ("$i\n");
	#创建线程
	for (0..$threadNum){  
		if (@array){
			my $var=shift @array;
			my ($lat,$lon) =split(/,/,$var);	
			threads->create(\&consume,$lat, $lon);  
		}
	} 
	#终止线程
	while(threads->list()){  
	    $_->join() for threads->list(threads::joinable); 
	} 
}

my $duratime = time - $start;
printf "duratime is $duratime \n";
