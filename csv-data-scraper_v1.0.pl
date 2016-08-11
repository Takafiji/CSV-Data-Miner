#!/usr/bin/perl

use strict;
use warnings;
use Modern::Perl;
use Text::CSV;

my $csv = Text::CSV->new({ 
	binary => 1,
	auto_diag => 1,
	eol => "\r\n",	
	sep_char => ','
});

if(@ARGV != 2){	
	print "Argument 1: CSV file to scrape data from\nArgument 2: keyword being looked for in CSV file\n";
}else{

	my $sum = 0;
	my $elements = 0;
	my $i = 0;
	my ($file_scraped, $scrape_value) = @ARGV;
	my $output = lc($scrape_value) . "-output.csv";
	my @alphabet = ('A' .. 'Z');

	open(my $data, '<:encoding(utf8)', $file_scraped) or die "Could not open '$file_scraped' $!\n";
	open(my $out, ">:encoding(utf8)", "$output") or die "Could not create $output $!\n";

	#populate output files columns
	print "Generating column headers...\n";
	$csv->print($out, $csv->getline($data));
	
	#get user input and convert alpha column to numeric value
	print "Enter alpha-column to scrape for keyword \"$scrape_value\" >> ";
	chomp(my $input_column = <STDIN>);
	$input_column = uc($input_column);
	for($i = 0; $alphabet[$i] ne $input_column; $i++){}

	#scrape CSV file for keyword, if keyword found print row to output file
	print "Scraping column \"$input_column\" from \"$file_scraped\" for keyword \"$scrape_value\"\n";
	$input_column = $i;
	while(my $fields = $csv->getline($data)){
		++$sum;
		if($fields->[$input_column] =~ /(\")(\S+)(\")/g){
			if(lc($fields->[$input_column]) =~ /$scrape_value/i){
				$csv->print($out, $fields);
				$elements++;
			}
		}
	}
	if(not $csv->eof){
		$csv->error_diag();
	}
	
	#close files and print results
	print "Done scraping file.\nSuccessfully generated $output file...\nClosing files...\n";
	close $data;
	close $out;

	print "Complete.\n\nSuccessfully found $elements keywords in \"$file_scraped\" from $sum rows scraped.\n";
}
