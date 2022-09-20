#!/bin/bash
date
source ~/.bashrc

###########

# Use bcftools to gather information from a VCF file,
# adjust formatting of file and output results as a new file.
# Prints user-friendly input prompt for output file names
# and prints updates to console after formatting and counting operations.

#########

# Make a variable for the input file
input_vcf=("$1")
echo $input_vcf


# Ask user for a name for the current run; will be used to prepend output file names
echo "Name for this run: "
read run_name


# Make a directory using the name of the run
mkdir -p "$run_name"


# Use bcftools query to extract from the input file
# filtering for sites where there are SNPs, use chromosome-position files for site names,
# output to text file (genoptypes are formatted as 'N/N, where N = A, C, G, or T')
(bcftools query -l $input_vcf \
	| tr "\n" "\t" && bcftools query -i 'TYPE="snp"' -f '\n%CHROM-%POS [\t%TGT]' \
	$input_vcf) > $run_name/$run_name.txt


# Count 'missing' genotype fields (formatted as './.') with 'NN',
# print number of missing genotypes.
num_missingGT=$(grep -o -i '\.\/\.' $run_name/$run_name.txt | wc -l)

echo "Found $num_missingGT './.' genotypes. Replaced with 'NN'."


# Replace instances of './.' with 'NN', replaces reamining '/' with '',
# adds 'locus' as header first column, removes trailing whitespace on each line,
# prints that the '/' characters have been removed, outputs final file
(sed -e 's/[/]//g' -e 's/[.][.]/NN/g' \
	-e '1s/^/locus\t/' -e 's/\s*$//' \
	$run_name/$run_name.txt ) > $run_name/$run_name.out.txt

echo "Removed '/' from all other genotype fields."


# Count number of instances of 'NN', count number of lines - 1 (loci),
# count number of 'columns' - 1 (samples),
# print count values to console.
num_NN=$(grep -o -i 'NN' $run_name/$run_name.out.txt | wc -l)
num_loci=$(awk 'END {print NR-1; exit}' $run_name/$run_name.out.txt)
num_col=$(head -n 1 $run_name/$run_name.out.txt | wc -w)
num_sample=`expr $num_col - 1`

echo "Replaced $num_NN instances of './.' with 'NN'."
echo "File contains $num_loci loci and $num_sample samples."