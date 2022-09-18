#!/bin/bash
date
source ~/.bashrc


input_vcf=("$1")
echo $input_vcf


echo "Name for this run: "
read run_name

mkdir -p "$run_name"

# use bcftools query to extract genotypes (as biallelic GTs, NN) where there are SNPs
# use chromosome-position for loci names
# output to text file
(bcftools query -l $input_vcf | tr "\n" "\t" && bcftools query -i 'TYPE="snp"' -f '\n%CHROM-%POS [\t%TGT]' $input_vcf) > $run_name/$run_name.txt


num_missingGT=$(grep -o -i '\.\/\.' $run_name/$run_name.txt | wc -l)
echo "Found $num_missingGT './.' genotypes. Replacing with 'NN'... "
echo "Removing '/' from all other genotype fields... "


(sed -e 's/[/]//g' -e 's/[.][.]/NN/g' -e '1s/^/locus\t/' -e 's/\s*$//' $run_name/$run_name.txt ) > $run_name/$run_name.out.txt


num_NN=$(grep -o -i 'NN' $run_name/$run_name.out.txt | wc -l)
echo "Replaced $num_NN instances of './.' with 'NN'."


num_loci=$(awk 'END {print NR-1; exit}' $run_name/$run_name.out.txt)
num_col=$(head -n 1 $run_name/$run_name.out.txt | wc -w)
num_sample=`expr $num_col - 1`
echo "File contains $num_loci loci and $num_sample samples."