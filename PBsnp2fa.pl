#!/usr/bin/perl -w

####################################################################################################
#
#		Sarah B. Kingan
#		University of Rochester
#		1 October 2014
#
#		Title: PBsnp2fa.pl
#
#
#		This program generates fasta alignments of samples
#		from user-defined coordinates.
#	
#		Input: 
#			1. popbam snp outfile, bgz compressed and tabix indexed
#			2. reference sequence in fastA format
#			3. coordinates given at command line (e.g. 2L:1000-2000)
#			4. optional text file with list of sample IDs, one ID per line. Sample order 
#				should be the same as in the BAM file header. If omitted, ID's are 
#				"sample_1", "sample_2" etc.
#
#		Output: 
#			fasta file of region for all samples.
#			
#
####################################################################################################

use strict;
use Bio::Seq;
use Bio::DB::Fasta;
use Tabix; 

my $usage = "PBsnp2fa.pl <snp.bgz> <ref.fa> <chrom:start-end> <OPT:sample_list.txt>\n";


# Setup tabix-index snp file
my $SNP_infile = $ARGV[0] or die $usage;
my $SNP_tabix = Tabix->new(-data => $SNP_infile);


# Setup reference fasta database
my $ref_fasta_file = $ARGV[1] or die $usage;
my $ref_fastaDB = Bio::DB::Fasta->new($ref_fasta_file);


# Get region coordinates
my $coordinates = $ARGV[2] or die $usage;
my $chrom;
my $start;
my $end;
if ($coordinates =~ /([0-9]{0,1}[A-Z]):([0-9]+)-([0-9]+)/) {
	$chrom = $1;
	$start = $2;
	$end = $3; 
}
else {
	print "wrong coordinates format!\n";
	print $usage;
	exit;
}


# Fetch reference sequence for interval
my $ref_seq = $ref_fastaDB->seq("$chrom:$start,$end");


# load SNP data for interval into hash
# key = position
# value = array of consensus bases for each sample
my %interval_SNP_hash;
my $SNP_interval = $SNP_tabix->query($chrom, $start, $end);
my $ncolumns;
while (my $SNP_line = $SNP_tabix->read($SNP_interval)) {
	my @SNP_line_array = split("\t", $SNP_line);
	$ncolumns = scalar(@SNP_line_array);
	my $position = $SNP_line_array[1];
	my @consensus_base_array = makeSNParray(@SNP_line_array);
	@{$interval_SNP_hash{$position}} = @consensus_base_array;
}
my $nsam = ($ncolumns - 3)/4;


# create sample name array from user input file
my @sample_array;
if ($ARGV[3]) {
	my $sample_list = $ARGV[3];
	@sample_array = makeSampleArray($sample_list);
# check that number of samples provided matches snp file dimensions
	if (scalar@sample_array != $nsam) {
		print "sample list contains incorrect number of samples!\n";
		die;
	}
}
# create generic sample name array
else {
	for (my $n = 1; $n<=$nsam; $n++) {
		push(@sample_array, 'sample_'.$n);
	}
}


# print sequence for each sample
for (my $i = 0; $i<scalar@sample_array; $i++) {
	my $seq = $ref_seq;
	foreach my $position (sort {$a<=>$b} keys %interval_SNP_hash) {
		substr($seq, ($position-$start), 1, ${$interval_SNP_hash{$position}}[$i]);
	}
	print ">$sample_array[$i]|$chrom:$start-$end\n";
	print $seq, "\n";
}


#### SUBROUTINES ####

# create hash of SNP data
##########################
sub makeSNParray {
##########################
	my (@SNP_array) = @_;
	my @consensus_base_array;
	for (my $i = 3; $i<scalar(@SNP_array); $i+=4) {
		my $sample_index = ($i-3)/4;
		if (($SNP_array[$i+1] > 25) # snp quality
			&& ($SNP_array[$i+2] > 25) # RMS quality
			&& ($SNP_array[$i+3] > 3)) { # read depth
			$consensus_base_array[$sample_index] = $SNP_array[$i];
		}
		else {
			$consensus_base_array[$sample_index] = 'N';
		}
	}
	return @consensus_base_array;
}

# create array of sample names
##########################
sub makeSampleArray {
##########################
	my ($sample_list) = @_; # text_file
	my @sample_array;
	open (LIST, $sample_list);
	while (my $line = <LIST>) {
		chomp$line;
		unless ($line =~ /^\s*$/) {
			push(@sample_array, $line)
		}
	}
	return @sample_array;
}


exit;



