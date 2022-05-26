#########################################################################################################
# Script: Take data from PubMLST and create an output with the class/family/b-lactamase that each 
# 	isolate has.
# Version: v1.5
# Date: 26/05/2022
# Author: Julia Moreno-Manjon
#########################################################################################################
# UPDATES
# v1.5: Change script to use two hashes instead of one. Skip files that do not contain the desired amount of lines
# v1.4: Fix table bugs
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
	'db|debug' => \$DEBUG
);

if (!defined $dir){
	$dir = '.';
}
#########################################################################################################

# Output this tab-delimited text in format:
say "Beta-lactamases\nclass\tfamily\tbeta-lactamase";

my %hash_class = (); #Create an empty hash
my %hash_family = ();

# Work with _peptide files - CLASS
my @files_pept = glob("$dir/*") or die "ERROR $!";
foreach my $files_pept (@files_pept) {
	open( my $fh, '<', $files_pept ) or die "ERROR $!"; #Open files in reading mode
	while ( my $line = <$fh> ) {
		chomp($line);
		next if !$line; #Ignore empty lines
		my @fields = split /\t/, $line;
		next if (scalar (@fields) != 6);
		my ( $locus, $allele_id, $sequence, $length, $type_allele, $comments ) =
	  		split /\t/, $line; #Columns in the file are split by tabs
	
		if ( $locus !~ /_peptide/ or $comments eq "" ) { #If there is no $comments value or $locus does not contain _peptide
			next; #go to next line
		}
		else { #If there is a value in $comments
			$hash_class{$comments} = $locus; #create a $comments key with an empty value 
		}
	}
}

# Work with ACIN files - FAMILY
my @files_acin = glob("$dir/*") or die "ERROR $!";
foreach my $files_acin (@files_acin) {
	open( my $fh, '<', $files_acin ) or die "ERROR $!"; #Open files in reading mode
	while ( my $line = <$fh> ) {
		chomp($line);
		next if !$line; #Ignore empty lines
		my @fields = split /\t/, $line;
		next if (scalar (@fields) != 8);
		my ( $locus, $allele_id, $sequence, $length, $type_allele, $comments, $source, $blact ) =
	  		split /\t/, $line; #Columns in the file are split by tabs
	
		if ( $blact eq "" ) { #If there is no $blact value
			next; #go to next line
		}
		else { #If there is a value
			$hash_family{$blact} = $locus; #create a $blact key with an empty value 
		}
	}
}

# Output
foreach my $key (sort keys %hash_class){ #For each key (aka b-lactam) in the 1st hash, sort them from lower to greater
    if (exists $hash_family{$key}){
		# CLASS
		my $class = $hash_class{$key};
		$class =~ s/_peptide//; #Delete "_peptide" and everything after it
		
		#FAMILY
		my $family = $hash_family{$key};
		$family =~ m/\((.*)\)/; #Match anything inside () -> it will be assigned $1
		my $family_ext = $1;
		
		say "$class\t$family_ext\t$key"; #Print the results 
    }
}    
