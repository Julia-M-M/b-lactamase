#########################################################################################################
# Script: Take data from PubMLST and create an output with the class/family/b-lactamase that each 
# 	isolate has.
# Version: v1.1
# Date: 24/05/2022
# Author: Julia Moreno-Manjon
#########################################################################################################

#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use 5.010;

# Input file
my ( $dir, $DEBUG, $filename );
GetOptions(
	'd|dir|directory=s'  => \$dir,
	'i|input=s' => \$filename,
	'db|debug' => \$DEBUG
);
#if ( !defined $filename ) {
#	say "No filename passed. Use -i to pass input file.";
#	exit;
#
if (!defined $dir){
	$dir = '.';
}
#########################################################################################################

# Output this tab-delimited text in format:
say "Beta-lactamases\nclass\tfamily\tbeta-lactamase";

my %hash = (); #Create an empty hash

my @files = glob("$dir/*") or die "ERROR $!";
foreach my $files (@files) {
	open( my $fh, '<', $files ) or die "ERROR $!"; #Open files in reading mode
	while ( my $line = <$fh> ) {
		chomp($line);
		next if !$line; #Ignore empty lines

		my ( $locus, $allele_id, $sequence, $length, $type_allele, $comments ) =
	  		split /\t/, $line; #Columns in the file are split by tabs
	
		if ( $locus !~ /_peptide/ or $comments eq "" ) { #If there is no $comments value or $locus does not contain _peptide
			next; #go to next line
		}
		else { #If there is a value in $comments
			$hash{$comments} = (); #create a $comments key with an empty value 
			push @{$hash{$comments}}, $locus; #and add the value $locus
		}
	
	}
}

# Output
foreach my $key (sort keys %hash){ #For each key (aka b-lactam) in the hash, sort them from lower to greater
	my $loci_all = ""; #create an empty list
	foreach my $loci (@{$hash{$key}}){ #and for each b-lactam in the array
		$loci_all .= sprintf "$loci;"; #print the values of the locus inside
	}
	$loci_all =~ s/_peptide//; #Delete "_peptide:" from "xxx_peptide"
	$loci_all =~ s/;$//; #Delete the ";" at the end od the string
	say "$loci_all\tfamily\t$key"; #Print the results
	
}

