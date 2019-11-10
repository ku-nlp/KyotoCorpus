#!/usr/bin/env perl

# 毎日新聞オリジナルデータと差分データからコーパスデータを再現
# --rel rel_list: 関係コーパス
# --without_self_id: 自文節、自基本句のIDを出力しない (KNPと同じフォーマット)

use utf8;
binmode(STDIN, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');
use strict;
use vars qw(%opt %rel_list);
use Getopt::Long;

&GetOptions(\%opt, 'rel=s', 'without_self_id');

if ($opt{rel}) {
    open(LIST, '< :encoding(utf8)', $opt{rel}) or die "Can't open $opt{rel}\n";
    while (<LIST>) {
	chomp;
	$rel_list{$_}++;
    }
    close(LIST);
}

open(ORG, '< :encoding(utf8)', "$ARGV[0].org") or die "Can't find $ARGV[0].org\n";
open(NUM, '< :encoding(utf8)', "$ARGV[0].num") or die "Can't find $ARGV[0].num\n";
open(KNP, '> :encoding(utf8)', "$ARGV[0].knp") or die "Can't open $ARGV[0].knp\n";

my ($sid, $aid, $sentence, $print_flag);
while (<NUM>) {
    if (/^\# S-ID:((\d+)-\d+)/) {
	$sid = $1;
	$aid = $2;
	if (!$opt{rel} or $rel_list{$aid}) {
	    print KNP;
	    $sentence = undef;
	    while (<ORG>) {
		if (/^\# S-ID:$sid/) {
		    $sentence = <ORG>;
		    last;
		}
	    }
	    # 文がみつからないとき
	    die "Can't find $sid in $ARGV[0].org" if !$sentence or $sentence =~ /^\#/;
	    $print_flag = 1;
	}
	else {
	    $print_flag = 0;
	}
    }
    elsif ($print_flag) {
	if (/^EOS/) {
	    print KNP;
	}
	elsif (/^[\*\+]/) {
	    if (/^([\*\+]) (\d+) (-?\d+[DPIA])\s?(.*)/) {
		my $type_symbol = $1;
		my $id = $2;
		my $dpnd = $3;
		my $feature = $4;
		print KNP "$type_symbol ";
		if ($opt{without_self_id}) {
		    print KNP "$dpnd";
		}
		else {
		    print KNP "$id $dpnd";
		}
		# rel info
		if ($opt{rel}) {
		    print KNP " $feature";
		}
		print KNP "\n";
	    }
	    else {
		die;
	    }
	}
	else {
	    my @list = split;
	    my ($pos, $len) = split('-', $list[0]);
	    $list[0] = substr($sentence, $pos, $len);
	    # 原形が見出しと同じ場合は'*'になっている
	    if ($list[2] eq '*') {
		$list[2] = $list[0];
	    }
	    print KNP join(' ', @list), "\n";
	}
    }
}

END {
    close(ORG);
    close(NUM);
    close(KNP);
}
