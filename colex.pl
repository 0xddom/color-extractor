#!/usr/bin/env perl

use warnings;
use strict;
use Image::Magick;
use HTML::Template;

#Receives a Magick pixel and returns it hex color code.
sub pixelToHex {
	my ($r, $g, $b) = @_;
	return sprintf "%X%X%X", $r * 255.0, $g * 255.0, $b * 255.0;
}

#Receives an image filename and returns all the colors it has.
sub getColors {
	my %colors = ();
	my $image = Image::Magick->new;
	$image->Read($_[0]);
	(my $width, my $height) = $image->Get('width', 'height');
	#print $width.'x'.$height."\n";
	my $i = 0;
	for(0 ... $width) {
		$i = $_;
		for (0 ... $height) {
			my @pixel =  $image->GetPixel(x => $i, y => $_);
			my $hexstr = pixelToHex @pixel;
			$colors{$hexstr}++;
		}
	}
	return %colors;
}

#Generates an HTML file with the program output.
sub generateHTMLReport {
	my $filename = $_[0];
	my $colorsref = $_[1];
	my $template = HTML::Template->new(filename => "template.html") or die "Could not find a template file.\nAborting...\n";
	$template->param(ImageName => $filename);
	my @loop_data = ();
	my $i = 0;
	foreach (keys %{$colorsref}) {
		my %row_data;
		$row_data{ColorCode} = $_;
		push @loop_data, \%row_data;
		$i++;
	}
	$template->param(ColorCount => $i);
	$template->param(ColorTable => \@loop_data);
	return $template->output;
}

if(@ARGV == 0) {
	print "[USAGE] colex <filename> [-o out.html]\n";
	exit;
}

my %colors = getColors $ARGV[0];
print generateHTMLReport($ARGV[0], \%colors);

