#!/bin/bash

#
# runs DESeq on filtered data
#

#PBS -l walltime=#walltimeHours:00:00
#PBS -l ncpus=1
#PBS -l mem=10gb

#PBS -M cgi@imperial.ac.uk
#PBS -m bea
#PBS -j oe

module load R/3.0.1

RESULT_DIR=#resultsDir
R_SCRIPT=#rScript 
export GFF_PATH=#gffPath
export GO_PATH=#goPath

R CMD BATCH --no-save --no-restore $R_SCRIPT ${R_SCRIPT}.log

perl -e 'print "gene_name\tgene_id\tgene_biotype\tfold_change\tadj_pval\tGO_term\n";' > $RESULT_DIR/nbinom.filt.sig.ann.tsv
perl -e 'while(<>){

     chomp();
     s/"//g;
     @data = split(/\t/,$_); 
     $id = $data[1];
     next unless $id =~ /ENSG/;

     $name = `grep $id $ENV{'GFF_PATH'}|head -n 1|cut -f 9|cut -f 4 -d ";"`;
     $name =~ s/ gene_name "(.*)"\n/$1/;

     $biotype = `grep $id $ENV{'GFF_PATH'}|head -n 1|cut -f 9|cut -f 5 -d ";"`;
     $biotype =~ s/ gene_biotype "(.*)"\n/$1/;

     $go = `grep $id $ENV{'GO_PATH'}|cut -f 2,3 |grep -vP "molecular_function|cellular_component|biological_process"|tr -d ":"|tr "\t" ":"|tr "\n" ";"`;

     printf("$name\t$id\t$biotype\t%.2f\t%.2e\t$go\n",$data[5],$data[8]);

}' $RESULT_DIR/nbinom.filt.sig.txt >> $RESULT_DIR/nbinom.filt.sig.ann.tsv

chmod 0660 $RESULT_DIR/*
