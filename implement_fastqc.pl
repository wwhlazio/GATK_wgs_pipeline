#!/usr/bin/perl
use strict;
use warnings;

my $Dir_input=$ARGV[0];
my $Dir_output=$ARGV[1];
my $workdir="/sc/orga/projects/zhuj05a/Wenhui/QC/workdir/fastqc/";
my $label=$ARGV[2];

my $cmd="ls -l $Dir_input*";
my @a=split(/\n/,`$cmd`);
my @fl;
my $nfl=0;
for my $i(0..$#a){
	my @b=split(/ /,$a[$i]);
	$fl[$nfl]=$b[$#b];
	$nfl=$nfl+1;
}
print "number of fq files:$nfl\n";

my $sh_file=$workdir.$label."_fastqc.sh";
print $sh_file,"\n";
open(my $FILE,">",$sh_file) or die"I can't write to the file!";
for my $i(0..$nfl-1){
	my $lsf_file=$workdir.$label."_fastqc_$i.lsf";
	open(my $FILE1,">",$lsf_file) or die"I can't write to the file!";
	print $FILE1 "#!/bin/bash\n";
        print $FILE1 "#BSUB -P acc_GTEX\n";
        print $FILE1 "#BSUB -q premium\n";
        print $FILE1 "#BSUB -J VF_unmap\n";
        print $FILE1 "#BSUB -R \"rusage[mem=10000]\"\n";
        print $FILE1 "#BSUB -W 12:00\n";
        print $FILE1 "#BSUB -m mothra\n";
        print $FILE1 "#BSUB -o $workdir","$label","_$i","fastq.stdout\n";
        print $FILE1 "#BSUB -eo $workdir","$label","_$i","fastq.stderr\n";
        print $FILE1 "#BSUB -L /bin/bash\n";
	print $FILE1 "module load fastqc\n";
	print $FILE1 "fastqc -t 8 -o $Dir_output -f fastq -noextract $fl[$i]\n";
	close($FILE1);
	print $FILE "bsub < $lsf_file\n";
}
close($FILE);
