PBsnp2fa.pl
===========

Convert [POPBAM](https://github.com/dgarriga/POPBAM) SNP output to fasta sequence


Introduction
============

This perl script creates a multi sequence fasta file that incorporates SNP calls made by the software package [POPBAM](https://github.com/dgarriga/POPBAM).



User Inputs
===========

At the command line, the user must specify the file paths for the following inputs:

1. snp file created by [POPBAM](https://github.com/dgarriga/POPBAM) SNP. File must be compressed with [bgzip](http://samtools.sourceforge.net/tabix.shtml) and indexed with [tabix](http://samtools.sourceforge.net/tabix.shtml).
2. reference sequence in fasta format. Must be the same reference sequence used in the BAM file for [POPBAM](https://github.com/dgarriga/POPBAM) runs. You must have write permissions to the directory containing your reference sequence.
3. region of interest. Format is: chrom:start-end.
4. optional text file containing sample names, one sample per line. The order of samples must match that of the BAM header.


