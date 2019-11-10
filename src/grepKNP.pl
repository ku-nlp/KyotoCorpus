#!/usr/bin/env perl

# 京都テキストコーパスに対する grep
#
# Usage: grepKNP.pl <pattern>

use strict;
use Encode qw(decode);
use utf8;
binmode(STDIN, ':encoding(euc-jp)');
binmode(STDOUT, ':encoding(euc-jp)');

exit 1 unless $ARGV[0];

my $CORPUS_DIR = '../dat/syn';
my $pattern = decode('euc-jp', $ARGV[0]);
my ($sentence, $raw_sentence);

for my $f (glob("$CORPUS_DIR/*.KNP")) {
    open(DAT, '< :encoding(euc-jp)', $f) or die;
    while (<DAT>) {
	if (/^EOS/) {
	    $sentence .= $_;
	    if ($sentence =~ /$pattern/ or $raw_sentence =~ /$pattern/) {
		print $sentence;
	    }
	    $sentence = '';
	    $raw_sentence = '';
	}
	else {
	    $sentence .= $_;
	    if ($_ !~ /^(\#|\*)/) {
		$raw_sentence .= (split)[0];
	    }
	}
    }
    close(DAT);
}
