#!/bin/env perl
#
use strict;
use warnings;
use File::Basename;
use Data::Dumper;

$#ARGV < 1 and die "$0 proband \@Family\n";

my @keyIndex = (0, 1, 2, 6, 7, 8, 43);
my @uniqIndex = (4, 5, 10, 11, 12, 13, 14, 16, 101);

my @fileList = @ARGV;
my %uniqData;
my %allData;
for my $fileIndex (0 .. $#fileList) {
	open IN, "zcat -f $fileList[$fileIndex]|" or die $!;
	while (<IN>) {
		/^#/ and next;
		chomp;
		my@ln=split /\t/,$_;
		my$key=join("\t",@ln[@keyIndex]);
		if($fileIndex){
			if(exists$uniqData{$key}){
				for(@uniqIndex){
					$uniqData{$key}{$_}[$fileIndex]=$ln[$_];
				}
			}
			#print STDERR Dumper($uniqData{$key});
		}else{
			for(@uniqIndex){
				$uniqData{$key}{$_}[$fileIndex]=$ln[$_];
			}
			#print STDERR Dumper($uniqData{$key});
		}
		exists$allData{$key}
			or $allData{$key}=$_;
	}
	close IN;
}

print STDERR "load Done\n";
my $keyFile   = $fileList[0];
my $keySample = basename($keyFile);
open OUT, ">$keySample.family.tsv" or die $!;
for (0 .. $#fileList) {
	print OUT join("\t","##familyInfo",$_,$fileList[$_]),"\n";
}
open IN,"zcat -f $fileList[0]|" or die$!;
while (<IN>) {
	if(/^#/){
		print OUT;
		break
	}
}
close IN;
for my$key(sort{$a cmp$b}keys%allData){
	my$ln=$allData{$key};
	my @ln = split /\t/, $ln;
	exists $uniqData{$key} or die "$key not found\n";
	for my $uniqIndex (@uniqIndex) {
		for my $fileIndex (0 .. $#fileList) {
			defined $uniqData{$key}{$uniqIndex}[$fileIndex]
			  or $uniqData{$key}{$uniqIndex}[$fileIndex] = "NA";
		}
		$ln[$uniqIndex] = join(";", @{$uniqData{$key}{$uniqIndex}});
	}
	print OUT join("\t", @ln), "\n";
}
close OUT;
