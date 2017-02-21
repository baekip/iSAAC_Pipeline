#!/bin/bash
#https://github.com/Illumina/Isaac3
isaac_path=/TBI/Tools/Isaac3/iSSAC-build/
project_path=/TBI/Share/HumanTeam/BioPipeline/Isaac_Pipeline_v1/example/PhiX_test


#Prepare reference genome
##This step can take long time on bigger genomes. Normally it is done once per reference and the output is reused in further data analyses.
##$ <isaac>/bin/isaac-sort-reference -g <isaac>/share/*/data/examples/PhiX/iGenomes/PhiX/NCBI/1993-04-28/Sequence/Chromosomes/phix.fa -o ./PhiX

#$isaac_path/
#$isaac_path/bin/isaac-sort-reference \
#    -g $project_path/PhiX/iGenomes/PhiX/NCBI/1993-04-28/Sequence/Chromosomes/phix.fa \
#    -o ./PhiX_ref


#Process fastq data
##Analyze a pair of fastq files and produce bam output.
##$ <isaac>/bin/isaac-align -r ./PhiX/sorted-reference.xml -b <isaac>/share/*/data/examples/PhiX/Fastq -f fastq --use-bases-mask y150,y150 -m40
$isaac_path/bin/isaac-align \
    -r $project_path/PhiX_ref/sorted-reference.xml \
    -b $project_path/input/Fastq/ \
    -o $project_path/output/02_isaac_run \
    -t $project_path/output/02_isaac_run/tmp \
    -f fastq \
    --use-bases-mask y150,y150 \
    -j 4 \
    -m 40



