PBsnp2fa.pl
===========

Convert [POPBAM](https://github.com/dgarriga/POPBAM) SNP output to fasta sequence


Introduction
============

This perl script creates a multi sequence fasta file that incorporates SNP calls made by the software package [POPBAM](https://github.com/dgarriga/POPBAM).



User Inputs
===========

At the command line, the user must specify the file paths for the following inputs:

1. snp file created by [POPBAM](https://github.com/dgarriga/POPBAM) SNP. File must be compressed with [BGZIP](http://samtools.sourceforge.net/tabix.shtml) and indexed with [TABIX](http://samtools.sourceforge.net/tabix.shtml). See below for step-by-step instructions.
2. reference sequence in fasta format. Must be the same reference sequence used in the BAM file for [POPBAM](https://github.com/dgarriga/POPBAM) runs. You must have write permissions to the directory containing your reference sequence because the script creates index files for your fasta file.
3. region of interest. Format is: chrom:start-end.
4. optional text file containing sample names, one sample per line. The order of samples must match that of the BAM header.

Preparation of SNP file
=======================
1. Run popbam snp for each chromosome or contig:

```unix
popbam snp -v -o 0 -f my_ref_file.fa my_file.bam chrom2 > chrom2.snp
```

2. Concatenate snp files:

```unix
cat chrom1.snp chrom2.snp chrom3.snp > allChrom.snp
```

3. Compress snp file with BGZIP:

```unix
bgzip -c allChrom.snp > allChrom.snp.bgz
```

4. Index compressed file with TABIX:

```unix
tabix -b 2 -e 2 -s 1 allChrom.snp.bgz
```





