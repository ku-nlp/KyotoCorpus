#!/usr/bin/env perl

use utf8;
binmode(STDIN, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');

# 毎日新聞で一日の記事の中で重複している文を削除

while ( <STDIN> ) {

    if (/^\# S-ID:([\d\-]+) (全体削除|人手削除):(.+\n)$/) {
	$id = $1;
	$sentence = $3;
	$check{$sentence} = $id;

	print;
    }
    elsif (/^\# S-ID:([\d\-]+)[\n ]/ && !/(全体削除|人手削除)/) {
	$id = $1;
	$all_id = $_;
	$sentence = <STDIN>;

	if ($check{$sentence}) {

	    # 重複していれば，文はID行に出力する

	    chop($all_id);
	    print "$all_id 重複:$check{$sentence}$sentence";
	}
	else {

	    # 重複していなければ通常出力，テーブル追加

	    print $all_id;
	    print $sentence;
	    $check{$sentence} = $id;
	}
    }
    else {
	print;
    }
}
