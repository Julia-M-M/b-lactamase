#########################################################################################################
# Script: Take data from PubMLST and create an output with the class/family/b-lactamase that each 
# 	isolate has.
# Version: v1.4
# Updates: Fix table bugs
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
	'db|debug' => \$DEBUG
);

if (!defined $dir){
	$dir = '.';
}
#########################################################################################################

# Output this tab-delimited text in format:
say "Beta-lactamases\nclass\tfamily\tbeta-lactamase";

my %hash = (); #Create an empty hash

# Work with _peptide files
my @files_pept = glob("$dir/*") or die "ERROR $!";
foreach my $files_pept (@files_pept) {
	open( my $fh, '<', $files_pept ) or die "ERROR $!"; #Open files in reading mode
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

# Work with ACIN files
my @files_acin = glob("$dir/*") or die "ERROR $!";
foreach my $files_acin (@files_acin) {
	open( my $fh, '<', $files_acin ) or die "ERROR $!"; #Open files in reading mode
	while ( my $line = <$fh> ) {
		chomp($line);
		next if !$line; #Ignore empty lines

		my ( $locus, $allele_id, $sequence, $length, $type_allele, $comments, $source, $blact ) =
	  		split /\t/, $line; #Columns in the file are split by tabs
	
		if ( $blact eq "" ) { #If there is no $blact value
			next; #go to next line
		}
		else { #If there is a value
			if (exists $hash{$blact} ){ #If the key exists (aka blact)
				
			
				if (scalar(@{$hash{$blact}}) == 1){ #If the key only has one value
					push @{$hash{$blact}}, $locus; #add the value $locus at the end of the value list
				}
			}
		}
	}
}

# Output
foreach my $key (sort keys %hash){ #For each key (aka b-lactam) in the hash, sort them from lower to greater
	
	# CLASS
	my $class_all = ""; #create an empty list
	foreach my $class (@{$hash{$key}}){ #and for each b-lactam in the array
		$class_all .= sprintf "$class;"; #print the values of the locus inside
	}
	$class_all =~ s/_peptide;.*;//; #Delete "_peptide" and everything after it
	
	#FAMILY
	my $family_all = "";
	foreach my $family (@{$hash{$key}}){ #and for each b-lactam in the array
		$family_all .= sprintf "$family;"; #print the values of the locus inside
	}
	$family_all =~ m/\((.*)\)/; #Match anything inside () -> it will be assigned $1
	my $family_all_ext = $1;
	
	say "$class_all\t$family_all_ext\t$key"; #Print the results
	
}
