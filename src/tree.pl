#!/usr/bin/env perl

# 構文解析結果の木構造表示
#
# Usage: tree.pl < input

use Encode qw(encode);
use utf8;
binmode(STDIN, ':encoding(euc-jp)');
binmode(STDOUT, ':encoding(euc-jp)');

$pos_mark{"特殊"} =  '*';
$pos_mark{"動詞"} =  'v';
$pos_mark{"形容詞"} =  'j';
$pos_mark{"判定詞"} =  'c';
$pos_mark{"助動詞"} =  'x';
$pos_mark{"名詞"} =  'n';
$pos_mark{"固有名詞"} =  'N';	# 特別
$pos_mark{"人名"} =  'J';	# 特別
$pos_mark{"地名"} =  'C';	# 特別
$pos_mark{"組織名"} =  'A';	# 特別
$pos_mark{"指示詞"} =  'd';
$pos_mark{"副詞"} =  'a';
$pos_mark{"助詞"} =  'p';
$pos_mark{"接続詞"} =  'c';
$pos_mark{"連体詞"} =  'm';
$pos_mark{"感動詞"} =  '!';
$pos_mark{"接頭辞"} =  'p';
$pos_mark{"接尾辞"} =  's';
$pos_mark{"未定義語"} =  '?';

######################################################################
# 入力
######################################################################

sub read_sentence {

    my ($i);

    $bnst_num = 0;
    $mrph_num = 0;

    $_ = <STDIN>;
    if (/BM: (.*)\n/) {
	@mark = split(/ /, $1);
    } else {
	@mark = ();
    }
    print;	# 文IDの出力

    while ( <STDIN> ) {
	chop;
	if (/^\*/) {
	    $mrph_data_start[$mrph_num] = 1;
	    $bnst_data_start[$bnst_num] = $mrph_num;
	    /^\* [\-0-9]+ ([\-0-9]+)([DPIA])/;	# 変更点
	    $bnst_data_dpnd[$bnst_num] = $1;
	    $bnst_data_type[$bnst_num] = $2;
	    $bnst_num++;
	}
	elsif (/^EOS/) {
	    $bnst_data_start[$bnst_num] = $mrph_num; # 末尾の印
	    last;
	}
	else {
	    @{$mrph_data_all[$mrph_num]} = split;
	    $mrph_num++;
	}
    }

    if ($mrph_num) {
	return 1;
    } else {
	return 0;
    }
}

######################################################################
# 行列に表示する文節作成
######################################################################

sub draw_all {

    my (@error_bnst) = @_;
    my ($i, $j);
    my ($length, $diff);
    my $max_length = 0;

    for ($i = 0; $i < $bnst_num; $i++) {
	$line[$i] = &make_bnst_string($i);
    }

    foreach $i (@error_bnst) {
	$line[$i] = "★" . $line[$i];
    }

    for ($i = 0; $i < $bnst_num; $i++) {
	for ($j = $i + 1; $j < $bnst_num; $j++) {
	    $line[$i] .= $item[$i][$j];
	}

	$length = do { use bytes; length(encode('euc-jp', $line[$i])) };
	if ($max_length <= $length) {
	    $max_length = $length;
	}
    }

    for ($i = 0; $i < $bnst_num; $i++) {
	$diff = $max_length - do { use bytes; length(encode('euc-jp', $line[$i])) };
	print ' ' x $diff;
# 	for ($j = 0; $j < $diff; $j++) {
# 	    print " ";
# 	}
	print "$line[$i]\n";
    }
}

######################################################################
# 行列に表示する文節作成
######################################################################

sub make_bnst_string {

    my ($b_num) = @_;
    my ($string, $i);

    for ($i = $bnst_data_start[$b_num]; 
	 $i < $bnst_data_start[$b_num+1]; $i++) {
	$string .= $mrph_data_all[$i][0];
	# next; 品詞マークを入れない場合
	if ($mrph_data_all[$i][4] eq "固有名詞" ||	# 変更点
	    $mrph_data_all[$i][4] eq "人名" ||		# 変更点
	    $mrph_data_all[$i][4] eq "地名" ||		# 変更点
	    $mrph_data_all[$i][4] eq "組織名") { 	# 変更点
	    $string .= $pos_mark{$mrph_data_all[$i][4]};# 変更点
	} else {
	    $string .= $pos_mark{$mrph_data_all[$i][3]};
	}
    }

    $string;
}

######################################################################
# 行列の各項表示
######################################################################

sub draw_matrix {

    my $i, $j, $para_row, @active_column;

    for ($i = 0; $i < $bnst_num; $i++) {
	$active_column[$i] = 0;
    }

    for ($i = 0; $i < ($bnst_num - 1); $i++) {

	if ($bnst_data_type[$i] eq "P") {
	    $para_row = 1;
	} else {
	    $para_row = 0;
	}

	for ($j = $i + 1; $j < $bnst_num; $j++) {

	    if ($j < $bnst_data_dpnd[$i]) {
		if ($active_column[$j] == 2) {
		    if ($para_row == 1) {
			$item[$i][$j] = "╋";
		    } else {
			$item[$i][$j] = "╂";
		    }
		} elsif ($active_column[$j] == 1) {
		    if ($para_row == 1) {
			$item[$i][$j] = "┿";
		    } else {
			$item[$i][$j] = "┼";
		    }
		} else {
		    if ($para_row == 1) {
			$item[$i][$j] = "━";
		    } else {
			$item[$i][$j] = "─";
		    }
		}
	    }
	    elsif ($j == $bnst_data_dpnd[$i]) {
		if ($bnst_data_type[$i] eq "P") {
		    $item[$i][$j] = "Ｐ";
		} elsif ($bnst_data_type[$i] eq "I") {
		    $item[$i][$j] = "Ｉ";
		} elsif ($bnst_data_type[$i] eq "A") {
		    $item[$i][$j] = "Ａ";
		} else {
		    if ($active_column[$j] == 2) {
			$item[$i][$j] = "┨";
		    } elsif ($active_column[$j] == 1) {
			$item[$i][$j] = "┤";
		    } else {
			$item[$i][$j] = "┐";
		    }
		}

		if ($active_column[$j] == 2) {
		    ;		# すでにＰからの太線があればそのまま
		} elsif ($para_row) {
		    $active_column[$j] = 2;
		} else {
		    $active_column[$j] = 1;
		}
	    } else {
		if ($active_column[$j] == 2) {
		    $item[$i][$j] = "┃";
		} elsif ($active_column[$j] == 1) {
		    $item[$i][$j] = "│";
		} else {
		    $item[$i][$j] = "　";
		}
	    }
	}
    }
}

######################################################################
# MAIN
######################################################################

while ( &read_sentence() ) {
    &draw_matrix();
    &draw_all(@mark);
}

######################################################################
# END
######################################################################
