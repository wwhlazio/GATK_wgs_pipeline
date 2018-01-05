#!/usr/bin/perl
use strict;
use warnings;

my @chr;
my $nchr=25;
for my $i(1..22){
	$chr[$i-1]="chr".$i;
}
$chr[22]="chrX";
$chr[23]="chrY";
$chr[24]="chrM";

my $workdir="/sc/orga/projects/zhuj05a/Wenhui/QC/GATK_call_variants/KY16K404/bqrc/";
my $datadir="/sc/orga/projects/zhuj05a/Wenhui/QC/GATK_call_variants/KY16K404/";
my $input="alignment_KY16K404.sorted.rmdup.good.realign.";
my $outdir="/hpc/users/wangm08/scratch/QC/KY16K404/";

my $sh_file=$workdir."recalibration_by_chr.sh";
print $sh_file,"\n";
open(my $FILE,">",$sh_file) or die"I can't write to the file!";
for my $i(0..$nchr-1){
	my $lsf_file=$workdir."realibration_".$chr[$i].".lsf";
	open(my $FILEX,">",$lsf_file) or die"I can't write to the file!";
	print $FILEX "#!/bin/bash\n";
	print $FILEX "#BSUB -P acc_GTEX\n";
	print $FILEX "#BSUB -q premium\n";
	print $FILEX "#BSUB -J VF_combine3\n";
	print $FILEX "#BSUB -R \"rusage[mem=8000]\"\n";
	print $FILEX "#BSUB -W 0:30\n";
	print $FILEX "#BSUB -m mothra\n";
	print $FILEX "#BSUB -o $workdir","recali_$chr[$i]",".stdout\n";
	print $FILEX "#BSUB -eo $workdir","recali_$chr[$i]",".stderr\n";
	print $FILEX "#BSUB -L /bin/bash\n";
	print $FILEX "module load java/1.8.0_66\n";
	print $FILEX "module load samtools\n";
	print $FILEX "rm $datadir","$input","$chr[$i].bai\n";
	print $FILEX "samtools index $datadir","$input","$chr[$i].bam\n";
	
	print $FILEX "java -jar -Xmx4g /hpc/packages/minerva-common/gatk/3.6-0/src/GenomeAnalysisTK.jar -T PrintReads -L ",$chr[$i]," -R /sc/orga/projects/zhuj05a/Wenhui/IBD/data/hg38/hg38.fa -BQSR $datadir","recal_new.table -I $datadir","$input","$chr[$i].bam -o $outdir","$input","recal.$chr[$i].bam\n";
	close($FILEX);
	print $FILE "bsub < $lsf_file\n";
}
close($FILE);
