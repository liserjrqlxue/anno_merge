#!/bin/env perl
#
use strict;
use warnings;
use File::Basename;
use Data::Dumper;

$#ARGV < 1 and die "$0 proband \@Family\n";

my $debug = 0;

my %index;
my @header;
my @loc = qw/Chr Start Stop/;
my @locIndex;     # = (0, 1, 2);
my @key = qw/Chr Start Stop Ref VarType MType Call MutationName cHGVS/;
my @keyIndex;     # = (0, 1, 2, 6, 7, 8, 43);
my @uniq = qw/InExcel NbGID Zygosity A.Depth A.Ratio PhasedGID A.Index Filter AutoInterpStatus AD PL GType Ratio Genotype Sex SampleID/;
my @uniqIndex;    # = (4, 5, 10, 11, 12, 13, 14, 16, 101);

my @fileList = @ARGV;
my %uniqData;
my %allData;
for my $fileIndex (0 .. $#fileList) {
	open IN, "zcat -f $fileList[$fileIndex]|" or die $!;
	while (<IN>) {
		/^##/ and next;
		chomp;
		if (s/^#//) {
			if ($#header == -1 and $fileIndex == 0) {
				@header = split /\t/, $_;
				@index{@header} = 0 .. $#header;
				for my $key (@loc) {
					exists $index{$key}
					  and push @locIndex, $index{$key};
				}
				for my $key (@key) {
					exists $index{$key}
					  and push @keyIndex, $index{$key};
				}
				for my $key (@uniq) {
					exists $index{$key}
					  and push @uniqIndex, $index{$key};
				}
			} elsif ($#header == -1 or $#locIndex == -1 or $#keyIndex == -1 or $#uniqIndex == -1) {
				die "anno result format error!\n";
			} else {
				my@ln=split /\t/,$_;
				unless(@ln~~@header){
					for(0..$#ln){
						$ln[$_]eq$header[$_]
					or 	print STDERR join("\t",$_,$ln[$_],$header[$_]),"\n";
					}
					die"anno heder not match!\n";
				}
			}
			if ($debug and $fileIndex == 0) {
				print STDERR join("\t", "locIndex:",  @locIndex),  "\n";
				print STDERR join("\t", "keyIndex:",  @keyIndex),  "\n";
				print STDERR join("\t", "uniqIndex:", @uniqIndex), "\n";
			}
			next;
		}
		my @ln = split /\t/, $_;
		my $key = join("\t", @ln[@keyIndex]);
		exists$allData{$key}
			or $allData{$key}=$_;
		for (@uniqIndex) {
			$uniqData{$key}{$_}[$fileIndex] = $ln[$_];
		}
	}
	close IN;
}

print STDERR "load Done\n";
my $keyFile   = $fileList[0];
my $keySample = basename($keyFile);
open OUT, ">$keySample.family.tsv" or die $!;
for (0 .. $#fileList) {
	print OUT join("\t","##familyInfo",(split /\./,basename($fileList[$_]))[0]),"\n";
}

print OUT "#",join("\t",@header),"\n";
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
