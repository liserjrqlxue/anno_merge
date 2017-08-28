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
my %hash;
for my$fileIndex(0..$#fileList){
	open IN,"zcat -f $fileList[$fileIndex]|" or die$!;
	while(<IN>){
		/^#/ and next;
		chomp;
		my@ln=split /\t/,$_;
		my$key=join("\t",@ln[@keyIndex]);
		if($fileIndex){
			if(exists$hash{$key}){
				for(@uniqIndex){
					$hash{$key}{$_}[$fileIndex]=$ln[$_];
				}
			}
			#print STDERR Dumper($hash{$key});
		}else{
			for(@uniqIndex){
				$hash{$key}{$_}[$fileIndex]=$ln[$_];
			}
			#print STDERR Dumper($hash{$key});
		}
	}
	close IN;
}

print STDERR "load Done\n";
my$keyFile=$fileList[0];
my$keySample=basename($keyFile);
open IN,"zcat -f $fileList[0]|" or die$!;
open OUT, ">$keySample.family.tsv" or die $!;
for (0 .. $#fileList) {
	print OUT join("\t", "##", $_, $fileList[$_]), "\n";
}
while (<IN>) {
	if(/^#/){
	  print OUT;
		next;
	}
	chomp;
	my @ln = split /\t/, $_;
	my $key = join("\t", @ln[@keyIndex]);
	exists$hash{$key} or print STDERR "$key\n";
	for my$uniqIndex(@uniqIndex){
		for my$fileIndex(0..$#fileList){
			defined$hash{$key}{$uniqIndex}[$fileIndex]
				or $hash{$key}{$uniqIndex}[$fileIndex]="NA";
		}
		$ln[$uniqIndex]=join(";",@{$hash{$key}{$uniqIndex}});
	}
	print OUT join("\t", @ln), "\n";
}
close IN;
close OUT;
