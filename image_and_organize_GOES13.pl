#!/usr/bin/perl

use Time::JulianDay;                      #...For day-of-year conversion

$source = "/var/autofs/mnt/yar_d1/lave/GOES13/data";
$out_dir = "/d1/lave/GOES13/netcdf";

$scrpt1 = '"g13_conus_mercator.pl -d -c lave\@yar:${out_dir}/${yyyy}/${mmdd} -i ${source}/${res}"';
$scrpt2 = '"g13_regional_images.pl -d -c lave\@yar:${out_dir}/${yyyy}/${mmdd}"';

$sshrename1 = '"ssh yar /bin/mv ${out_dir}/${yyyy}/${mmdd}/${file}_US_vis.jpg ${out_dir}/${yyyy}/${mmdd}/${file}_US_vis_hiRes.jpg"';
$sshrename2 = '"ssh yar /bin/mv ${out_dir}/${yyyy}/${mmdd}/${file}_smUS_vis.jpg ${out_dir}/${yyyy}/${mmdd}/${file}_smUS_vis_hiRes.jpg"';
$sshrename3 = '"ssh yar /bin/mv ${out_dir}/${yyyy}/${mmdd}/${file}.nc ${out_dir}/${yyyy}/${mmdd}/${file}_vis.nc"'; 
$sshmv = '"ssh yar /bin/mv ${out_dir}/${yyyy}/${mmdd}/*.jpg /d1/lave/GOES13/images/${yyyy}/${mmdd}/"';

$matchString = "(g[01][0-9])\.([12][0-9]{3})([0-3][0-9][0-9])";

$clean = "rm \./g13\.\*";

#-----------------------------------------------

opendir(VISONLY, "$source/VisOnly/") || die "Cannot open directory (VisOnly)\n";
opendir(LOWRES, "$source/LowRes/") || die "Cannot open directory (LowRes)\n";

@visonly = grep(/$matchString/, readdir(VISONLY));
@lowres = grep(/$matchString/, readdir(LOWRES));
$visonlyref = \@visonly;
$lowresref = \@lowres;

@directories = ($visonlyref,$lowresref);

foreach $directory (@directories) {
    
    foreach $file (@$directory) {
        chomp $file;
        ($satellite, $yyyy, $ddd) = $file =~ /$matchString/;

        $Jan_1_this_year = &julian_day($yyyy, 1, 1);
        ($year,$mo,$day) = &inverse_julian_day($Jan_1_this_year + $ddd - 1);
        $mmdd = sprintf("%02d%02d", $mo, $day);
        
        if ($directory eq $visonlyref) {
            $res = "VisOnly";
        } else {
            $res = "LowRes";
        }
        grep($_=eval, $scrpt1exe=$scrpt1);
        
        ((system("$scrpt1exe $file") >> 8) == 0) || warn "Cannot process data (${file})\n";

        if ($res eq "VisOnly") {

            grep($_=eval, $sshrename1exe=$sshrename1);
            ((system("$sshrename1exe") >> 8) == 0) || warn "Cannot rename file (${file}_US_vis)\n";
            grep($_=eval, $sshrename2exe=$sshrename2);
            ((system("$sshrename2exe") >> 8) == 0) || warn "Cannot rename file (${file}_smUS_vis)\n";
            grep($_=eval, $sshrename3exe=$sshrename3);
            ((system("$sshrename3exe") >> 8) == 0) || warn "Cannot rename file (${file}\.nc)\n";

            grep($_=eval, $scrpt2exe=$scrpt2);
            ((system("$scrpt2exe $file") >> 8) == 0) || warn "Cannot process data (${file})\n";

        }
        
        ((system("$clean") >> 8) == 0) || warn "Cannot clean current directory\n";

        grep($_=eval, $sshmove=$sshmv);
        ((system("$sshmove") >> 8) == 0) || warn "Cannot move image files\n";
    }
}
closedir(VISONLY);
closedir(LOWRES);
