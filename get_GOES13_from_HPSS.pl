#!/usr/bin/perl

use Time::JulianDay;

open (DAYIN, "./daycounter.txt") || die "Cannot open daycounter for input\n";

$HPSS_prefix = "/FS/EOL/operational/satellite/goes";
$sat_name = "g13";
@data_res = ("1km","4km");

$HPSS_dir = '"${HPSS_prefix}/${sat_name}/${data_res}/${yyyy}/day${day_of_year}"';
$HPSS_file = '"${sat_name}.${yyyy}${day_of_year}.${hh}${mn}.gz"';

$tmp_file = ".$$.stdout.txt";

$yyyy = 2017;
$start_day = 7;
$end_day = 7;
#$start_day = <DAYIN>;
#$end_day = $start_day + 6;

close (DAYIN);

foreach $data_res (@data_res) {
    if ($data_res eq "1km") {
        $res_type = "VisOnly";
    } else {
        $res_type = "LowRes";
    }

    foreach $day ($start_day..$end_day) {
        $day_of_year = sprintf("%03d", $day);

        $Jan_1_this_year = &julian_day($yyyy,1,1);
        ($year,$mo,$dd) = &inverse_julian_day($Jan_1_this_year + $day_of_year - 1);
        $mmdd = sprintf("%02d%02d", $mo, $dd);

        mkdir ("/d1/lave/GOES13/images/$yyyy/$mmdd", 0755) unless (-d "/d1/lave/GOES13/images/$yyyy/$mmdd");
        mkdir ("/d1/lave/GOES13/netcdf/$yyyy/$mmdd", 0755) unless (-d "/d1/lave/GOES13/netcdf/$yyyy/$mmdd");
#        rename ("$file1", "$file2");
#        rename ("$file1", "$target_directory");

        grep($_=eval, $list_this_dir=$HPSS_dir);

        $cmd1 = "hsi -O $tmp_file ls -1 $list_this_dir";

        $cmd2 = "hsi get";

        ((system("$cmd1") >> 8) == 0) || warn "Sys command failed ($cmd1) ...\n$!\n\n";

        open (FILE_LIST, "$tmp_file") || warn "Cannot open file ($tmp_file)\n$!\n\n";

        while (<FILE_LIST>) {

            next if /^Username/;

            next unless ($_ =~ /15\.gz$/ || $_ =~ /45\.gz$/ || $_ =~ /16\.gz$/ || $_ =~ /46\.gz$/);

            ((system("$cmd2 $_") >> 8) == 0) || warn "Sys command failed ($cmd2) ...\n$!\n\n";

            $filegz = (split '/', $_)[-1];

            ((system("gunzip $filegz") >> 8) == 0) || warn "Sys command failed (gunzip) ...\n!\n\n";

            $file = substr($filegz, 0, -4);

            if ($data_res eq "1km") {
                ((system("mv ./$file /d1/lave/GOES13/working1/$file") >> 8) == 0) || warn "Sys command failed (mv VisOnly) ...\n$!\n\n";
            } elsif ($data_res eq "4km") {
                ((system("mv ./$file /d1/lave/GOES13/working2/$file") >> 8) == 0) || warn "Sys command failed (mv LowRes) ...\n$!\n\n";
            }
        }

    close(FILE_LIST);

    unlink("$tmp_file");
    }
}

#$end_day++;
#open (DAYOUT, ">./daycounter.txt") || warn "Cannot open daycounter as output\n";

#print DAYOUT "$end_day";

close (DAYOUT);
