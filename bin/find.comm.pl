#!/bin/env perl
#
use strict;
use warnings;

$#ARGV<3 and die"$0 keyIndex uniqIndex \@file\n";
my$keyIndex=shift;
my@keyIndex=split /,/,$keyIndex;
my$uniqIndex=shift;
my@uniqIndex=split /,/,$uniqIndex;
my%uniqIndex;
@uniqIndex{@uniqIndex}=0..$#uniqIndex;

my@fileList=@ARGV;

my%hash;
my$count=0;
my$bit=1;

for my$file(@fileList){
	$count|=$bit;
	print STDERR "load $file\n";
	open IN,"zcat -f $file|" or die$!;
	while(<IN>){
		/^#/ 
			and next;
		chomp;
		my@ln=split /\t/,$_;
		$ln[7]eq'ref'and next;
		my$key=join("\t",@ln[@keyIndex]);
		exists$hash{$key}
			and$hash{$key}==$count
			and die"$key\t$hash{$key}\n";
		$hash{$key}|=$bit;
	}
	close IN;
	$bit=$bit<<1;
}
print STDERR "load Done:$count\n";

#my@uniq;
my%uniq;
for my$index(0..$#fileList){
#	$uniq[$index]=(xxx=>0);
	my$file=$fileList[$index];
	print STDERR "load $file\n";
	open IN,"zcat -f $file|" or die$!;
	open OUT,"> $file.comm" or die$!;
	while(<IN>){
		/^#/ 
			and print OUT
			and next;
		chomp;
		my@ln=split /\t/,$_;
		$ln[7]eq'ref'and next;
		my$key=join("\t",@ln[@keyIndex]);
		$hash{$key}==$count or next;
		my$uniq=join("\t",@ln[@uniqIndex]);
		#$uniq[$index]{$key}=$uniq;
		$uniq{$key}{$index}=$uniq;
		print OUT "$_\n";
	}
	close IN;
}
print STDERR "load Done\n";
my$file=$fileList[0];
open IN,"zcat -f $file|" or die$!;
open OUT,"> comm.tsv" or die$!;
for(0..$#fileList){
	print OUT join("\t","##",$_,$fileList[$_]),"\n";
}
while(<IN>){
	#/^##/
	/^#/
		and print OUT
		and next;
	chomp;
	my@line;
=cut
	for(0..$#ln){
		exists$uniqIndex{$_}
			and next;
		push @line,$ln[$_];
	}
	if($ln[0]=~/^#/){
		for(0..$#fileList){
			push@line,"$_-".join("\t$_-",@ln[@uniqIndex]);
		}
		print OUT join("\t",@line),"\n";
		next;
	}
	$ln[7]eq'ref'and next;
	my$key=join("\t",@ln[@keyIndex]);
	$hash{$key}==$count or next;
	for(0..$#fileList){
		#print STDERR join("\t",$_,$key,$uniq{$key}{$_}),"\n";
		push@line,$uniq{$key}{$_};
	}
=cut
	my@ln=split /\t/,$_;
	$ln[7]eq'ref'and next;
	my$key=join("\t",@ln[@keyIndex]);
	$hash{$key}==$count or next;
	my@uniq=split /\t/,$uniq{$key}{0};
	for(1..$#fileList){
		my@tt=split /\t/,$uniq{$key}{$_};
		for(0..$#tt){
			$uniq[$_].=";".$tt[$_];
		}
	}
	for(0..$#ln){
		exists$uniqIndex{$_}
			and push @line,$uniq[$uniqIndex{$_}]
			or push @line,$ln[$_];
	}
	print OUT join("\t",@line),"\n";
}
close IN;
close OUT;




__END__
10	100003784	100003785
10	100011969	100011970
10	100012010	100012011
10	100013243	100013244
10	100016195	100016196
10	100016338	100016339
10	100017452	100017453
10	100018843	100018844
10	100022445	100022446
10	100022917	100022917
