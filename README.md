# vcf_SNPgenotypes
Get genotypes of SNP calls from a VCF file using bcftools, adjust formatting using sed/awk/grep


## Dependencies
bcftools

## Description
This script uses *bcftools* to extract biallelic genotypes from a VCF file, uses UNIX function *sed*, *awk*, and *grep* to make formatting changes.

The extracted genotypes are filtered for single nucleotide polymorphisms (SNPs) so that the genotypes in the output file are only those classified as TYP = SNP (or TYPE = SUB) in the VCF file. This means that the resulting output file contains only genotypes for positions where a SNP was identified.