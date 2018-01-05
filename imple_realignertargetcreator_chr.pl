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

my $workdir="/sc/orga/projects/zhuj05a/Wenhui/QC/GATK_call_variants/KY16K404/indel_realign/";
my $datadir="/sc/orga/projects/zhuj05a/Wenhui/QC/GATK_call_variants/KY16K404/";
my $input="alignment_KY16K404.sorted.rmdup.good.bam";

my $sh_file=$workdir."realignertargetcreator_by_chr.sh";
print $sh_file,"\n";
open(my $FILE,">",$sh_file) or die"I can't write to the file!";
for my $i(0..$nchr-1){
	my $lsf_file=$workdir."realignertargetcreator_".$chr[$i].".lsf";
	open(my $FILEX,">",$lsf_file) or die"I can't write to the file!";
	print $FILEX "#!/bin/bash\n";
	print $FILEX "#BSUB -P acc_GTEX\n";
	print $FILEX "#BSUB -q premium\n";
	print $FILEX "#BSUB -J VF_combine3\n";
	print $FILEX "#BSUB -R \"rusage[mem=8000]\"\n";
	print $FILEX "#BSUB -W 0:30\n";
	print $FILEX "#BSUB -m mothra\n";
	print $FILEX "#BSUB -o $workdir","realignertargetcreator_$chr[$i]",".stdout\n";
	print $FILEX "#BSUB -eo $workdir","realignertargetcreator_$chr[$i]",".stderr\n";
	print $FILEX "#BSUB -L /bin/bash\n";
	print $FILEX "module load java/1.8.0_66\n";
	print $FILEX "java -jar -Xmx4g /hpc/packages/minerva-common/gatk/3.6-0/src/GenomeAnalysisTK.jar -T RealignerTargetCreator -L ",$chr[$i]," -R /sc/orga/projects/zhuj05a/Wenhui/IBD/data/hg38/hg38.fa -I $datadir","$input --known /sc/orga/projects/zhuj05a/Wenhui/IBD/data/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz -o $datadir","Reads_1.$chr[$i].realigner.intervals\n";
	close($FILEX);
	print $FILE "bsub < $lsf_file\n";
}
close($FILE);
