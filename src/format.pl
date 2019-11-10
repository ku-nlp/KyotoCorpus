#!/usr/bin/env perl

use utf8;
binmode(STDIN, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');
binmode(STDERR, ':encoding(utf8)');

# コーパスのタイプ
$TYPE = "形態素・構文コーパス";
# $TYPE = "文脈コーパス";

#
# 対象外とする記事，文
#
$neglect_aid{"950101140"} = 1;	# 選手紹介
$neglect_aid{"950110251"} = 1;	# 各地の地震強度
$neglect_aid{"950112293"} = 1;	# 出品者一覧
$neglect_aid{"950118034"} = 1;	# 人名一覧
$neglect_aid{"950118035"} = 1;	# 人名一覧
$neglect_aid{"950118045"} = 1;	# 人名一覧
$neglect_aid{"950118046"} = 1;	# 人名一覧
$neglect_aid{"950118240"} = 1;	# 人名一覧
$neglect_aid{"950118241"} = 1;	# 人名一覧
$neglect_aid{"950118243"} = 1;	# 人名一覧
$neglect_aid{"950118244"} = 1;	# 人名一覧
$neglect_aid{"950118245"} = 1;	# 人名一覧
$neglect_aid{"950118250"} = 1;	# 人名一覧
$neglect_aid{"950118252"} = 1;	# 人名一覧
$neglect_aid{"950118253"} = 1;	# 人名一覧
$neglect_aid{"950118254"} = 1;	# 人名一覧

my ($dirname) = ($0 =~ /^(.*?)[^\/]+$/);
$GIVEUP = $dirname ? "${dirname}giveup.dat" : "giveup.dat";
$OK = $dirname ? "${dirname}ok.dat" : "ok.dat";

@enu = ("０", "１", "２", "３", "４", "５", "６", "７", "８", "９");
$start_flag = 0;

# 引数の処理

$DATE = "";
for ($i = 0; ; $i++) {
    if ($ARGV[$i] =~ /^\-/) {
	if ($ARGV[$i] eq "-all") {
	    $SUBJECT = "全記事";
	} elsif ($ARGV[$i] eq "-ed") {
	    $SUBJECT = "社説";
	} elsif ($ARGV[$i] eq "-exed") {
	    $SUBJECT = "社説以外";
	}
    } else {
	$DATE = $ARGV[$i];
	last;
    }
}
die if (!$DATE || $DATE !~ /^95/); 

######################################################################
#		  毎日新聞CD-ROMデータのフォーマット
######################################################################

#
# giveup.dat があれば読み込み，削除する．
#

if (open(GIVEUP, $GIVEUP)) {
    while ( <GIVEUP> ) {
	if (/^([\d-]+)/) {
	    $neglect_h_sid{$1} = 1;
	}
    }
    close(GIVEUP);
}

#
# ok.dat があれば読み込み，削除する．
#

if (open(OK, '< :encoding(utf8)', $OK)) {
    while ( <OK> ) {
	if (/^(?:\# S-ID:)?([\d-]+)(.*)/) {
	    my ($id, $str) = ($1, $2);
	    $ok_h_sid{$id} = 1;
	    while ($str =~ / 部分削除:(\d+):([^ ]+)/g) {
		$ok_h_check{$id}{$1} = $2;
	    }
	}
    }
    close(OK);
}

while ( <STDIN> ) {

    $whole_article .= $_;

    if (/<\/ENTRY>/) {
	if ($start_flag) {
	    &check_article($aid, $title, $article);
	    # 記事に区切るだけ
	    # print "$aid\n$title\n$article\n\n";
	    # print $whole_article;
	}
	$article = "";
	$whole_article = "";
    } elsif (/<C0>/) {
	/^<C0>(.+)<\/C0>\n/;
	$aid = $1;
	if ($aid =~ /^$DATE/) {
	    $start_flag = 1;
	} else {
	    if ($start_flag) {
		exit;
	    } else {
		;
	    }
	}
    } elsif (/<T1>/) {
	/^<T1>(.+)<\/T1>\n/;
	$title = $1;
    } elsif (/<T2>/) {
	$flag = 1;
    } elsif (/<\/T2>/) {
	$flag = 0;
    } else {
	$article .= $_ if ($start_flag && $flag);
    }
}

######################################################################
# コーパス作成から排除する記事
#
# ・タイトルに次の文字列があるもの
#	［余録］
#	［雑記帳］
#	［社告］
#	［人事］
#	［人物略歴］
#	死去＝
#
# ・本文中に(段落先頭を除いて)スペースを含むもの
#   (スペースの2つ連続を除けば表などはほとんど省けるが，とりあえず簡単の
#    ためスペースが一つでも入れば排除する)
#
# ・段落先頭に"　——"があるもの
#   (インタビュー記事，発言者名，発言全体が括弧に囲まれる可能性などがある
#    ため)
#
######################################################################

sub check_article
{
    local($aid, $title, $article) = @_;
    local($i, $flag);

    $flag = 1;

    if ($neglect_aid{$aid}) {
	$flag = 0;
    }
    elsif ($title =~ 
	/［余録］|［雑記帳］|［社告］|［人事］|［人物略歴］|死去＝|＝の葬儀・告別式/) {
	$flag = 0;
    }
    elsif (($SUBJECT eq "社説" && $title !~ /［社説］/) || 
	   ($SUBJECT eq "社説以外" && $title =~ /［社説］/)) {
	$flag = 0;
    }
    else {
	foreach $i (split(/\n/, $article)) {
	    $flag = 0 if ($i =~ /　——/);
	    $i =~ s/^　//;
	    $flag = 0 if ($i =~ /　/);
	}
    }

    if ($flag == 0) {
	if ($TYPE eq "形態素・構文コーパス") {
	    print STDOUT "# A-ID:$aid 削除\n";
	}
    }
    else {
	if ($TYPE eq "形態素・構文コーパス") {
	    print STDOUT "# A-ID:$aid\n";
	    &breakdown_article($aid, $article, STDOUT);
	}
	elsif ($TYPE eq "文脈コーパス") {
	    $aid =~ /....(.....)/;
	    open(OUT, '> :encoding(utf8)', "$1.txt");
	    &breakdown_article($aid, $article, OUT);
	    close(OUT);
	}
    }
}

######################################################################
# 記事を文単位に分解
#
# ・括弧内以外の"。"
#
# ・"】"
######################################################################

sub breakdown_article
{
    local($aid, $article, $OUT) = @_;
    local($paragraph, $sentence, $level, $last, $scount, $sid, $pcount);
    local($i, @char);

    chop($article);
    $scount = 1;
    $pcount = 1;
    foreach $paragraph (split(/\n/, $article)) {

	if ($TYPE eq "文脈コーパス") {
	    print $OUT "# ($pcount)\n";
	}

	$level = 0;
	$sentence = "";
	
	@char = split(//, $paragraph);

	for ($i = 0; $i < @char; $i++) {
	    if ($char[$i] eq "「" ||
		$char[$i] eq "＜" ||
		$char[$i] eq "（") {
		$level ++;
		# print STDERR "nesting 括弧:$sentence\n" if ($level == 2);
	    } elsif ($char[$i] eq "」" ||
		     $char[$i] eq "＞" ||
		     $char[$i] eq "）") {
		$level --;
		# print STDERR "invalid 括弧？:$paragraph\n" if ($level == -1);
	    }
	    $sentence .= $char[$i];
	    if (($level == 0 && $char[$i] eq "。" ) || 
		($char[$i] eq "】" && $char[$i+1] ne "。")) {
		$sid = sprintf("%s-%03d", $aid, $scount);

		if ($TYPE eq "形態素・構文コーパス") {
		    &check_sentence($sid, $sentence, $OUT);
		}
		elsif ($TYPE eq "文脈コーパス") {
		    $sentence =~ s/^　+//;
		    print $OUT "# $scount\n$sentence\n";
		}
		$scount++;
		$sentence = "";
	    }
	    $last = $char[$i];
	}

	if ($last ne "。" && $last ne "】") {
	    $sid = sprintf("%s-%03d", $aid, $scount);
	    
	    if ($TYPE eq "形態素・構文コーパス") {
		&check_sentence($sid, $sentence, $OUT);
	    }
	    elsif ($TYPE eq "文脈コーパス") {
		$sentence =~ s/^　+//;
		print $OUT "# $scount\n$sentence\n";
	    }
	    $scount++;
	    $sentence = "";
	}

	if ($TYPE eq "形態素・構文コーパス") {
	    print $OUT "# 改段落\n";
	}
	$pcount++;
    }
}

######################################################################
# 文，文内で削除するもの
#
# ・"【"，"◇"，"▽"，"●"，"＜"，"《"で始まる文は全体を削除
#
# ・"。"が内部に5回以上または長さ512バイト以上(多くは引用文)は全体を削除
#
# ・文頭の"　"，"　——";
#
# ・"（…）"の削除，ただし，"（１）"，"（２）"の場合は残す
#
# ・"＝…＝"の削除，ただし間に"，"がくればRESET
#
# ・"＝…(文末)"で，文末に"。"がないか，"…"が"写真。"であれば除削
#
# ・（１）…（２） という箇条書きがあるもの
######################################################################

sub check_sentence
{
    local($sid, $sentence, $OUT) = @_;
    local(@char_array, @check_array, $i, $flag);
    local($enu_num, $paren_start, $paren_level, $paren_str);

    (@char_array) = split(//, $sentence);

    for ($i = 0; $i < @char_array; $i++) {
	$check_array[$i] = 1;
    }

    # 人手削除
    if ($ok_h_sid{$sid}) {
	for my $pos (keys %{$ok_h_check{$sid}}) {
	    for (my $i = $pos; $i < $pos + length($ok_h_check{$sid}{$pos}); $i++) {
		$check_array[$i] = 0;
	    }
	}
	goto SENTENCE_CHECK_OK;
    }

    # 特別に対象外とする文

    if ($neglect_sid{$sid}) {
	print $OUT "# S-ID:$sid 全体削除:$sentence\n";
	return;
    }
    if ($neglect_h_sid{$sid}) {
	print $OUT "# S-ID:$sid 人手削除:$sentence\n";
	return;
    }

    # "【"，"◇"，"▽"，"●"，"＜"，"《"で始まる文は全体を削除

    if ($sentence =~ /^(　)?(【|◇|▽|●|＜|《)/) {
	print $OUT "# S-ID:$sid 全体削除:$sentence\n";
	return;
    }

    # "。"が内部に5回以上または長さ512バイト以上(多くは引用文)は全体を削除

    if ($sentence =~ /^.+。.+。.+。.+。.+。.+/ ||
	length($sentence) >= 256) {
	print $OUT "# S-ID:$sid 全体削除:$sentence\n";
	return;
    }

    # "………"だけの文は全体を削除
    
    if ($sentence =~ /^(…)+$/) {
	print $OUT "# S-ID:$sid 全体削除:$sentence\n";
	return;
    }

  SENTENCE_OK:
    # 文頭の"　"は削除
    $check_array[0] = 0 if ($char_array[0] eq "　");

    # 文頭の"　——"は削除

    if ($sentence =~ "^　——") {
	$check_array[1] = 0;
	$check_array[2] = 0;
    }

    # "（…）"の削除，ただし，"（１）"，"（２）"の場合は残す

    $enu_num = 1;
    $paren_start = -1;
    $paren_level = 0;
    $paren_str = "";
    for ($i = 0; $i < @char_array; $i++) {
	if ($char_array[$i] eq "（") {
	    $paren_start = $i if ($paren_level == 0);
	    $paren_level++;
	} 
	elsif ($char_array[$i] eq "）") {
	    $paren_level--;
	    if ($paren_level == 0) {
		if ($paren_str eq $enu[$enu_num]) {
		    $enu_num++;
		}
		else {
		    for ($j = $paren_start; $j <= $i; $j++) {
			$check_array[$j] = 0;
		    }
		}
	    $paren_start = -1;
	    $paren_str = "";
	    }
	}
	else {
	    $paren_str .= $char_array[$i] if ($paren_level != 0);
	}
    }
    # print STDERR "enu_num(+1) = $enu_num\n" if ($enu_num > 1);

    # "＝…＝"の削除，ただし間に"，"がくればRESET

    $paren_start = -1;
    $paren_level = 0;
    $paren_str = "";
    for ($i = 0; $i < @char_array; $i++) {
	if ($check_array[$j] == 0) {
	    ; # "（…）"の中はスキップ
	} elsif ($char_array[$i] eq "＝") {
	    if ($paren_level == 0) {
		$paren_start = $i; 
		$paren_level++;
	    } 
	    elsif ($paren_level == 1) {
		for ($j = $paren_start; $j <= $i; $j++) {
		    $check_array[$j] = 0;
		}
		$paren_start = -1;
		$paren_level = 0;
		$paren_str = "";
	    }
	}
	elsif ($char_array[$i] eq "、") {
	    if ($paren_level == 1) {

		# "＝…"となっていても，"、"がくればRESET
		# 例 "「中高年の星」＝米長と、若き天才＝羽生"
		# print STDERR "＝…，…＝RESET:$paren_str:$sentence\n";

		$paren_start = -1;
		$paren_level = 0;
		$paren_str = "";
	    }
	}
	else {
	    $paren_str .= $char_array[$i] if ($paren_level == 1);
	}
    }

    # "＝…(文末)"で，文末に"。"がないか，"…"が"写真。"であれば除削

    if ($paren_level == 1) {
	if ($paren_str =~ /^写真/ || $paren_str !~ /。$/) {
	    for ($j = $paren_start; $j < $i; $j++) {
		$check_array[$j] = 0;
	    }
	    # print STDERR "＝…DELETE:$paren_str:$sentence\n";
	} else {
	    # print STDERR "＝…KEEP:$paren_str:$sentence\n";
	}
    }

  SENTENCE_CHECK_OK:
    $flag = 0;
    for ($i = 0; $i < @char_array; $i++) {	
	if ($check_array[$i] == 1) {
	    $flag = 1;
	    last;
	}			# 有効部分がなければ全体削除
    }
    if ($enu_num > 2 && !$ok_h_sid{$sid}) {	# （１）（２）とあれば全体削除
	# print STDERR "# S-ID:$sid 全体削除:$sentence\n";
	$flag = 0;
    }

    if ($flag == 0) {
	print $OUT "# S-ID:$sid 全体削除:$sentence\n";
    } else {
	print $OUT "# S-ID:$sid";

	for ($i = 0; $i < @char_array; $i++) {
	    if ($check_array[$i] == 0) {
		print $OUT " 部分削除:$i:" 
		    if ($i == 0 || $check_array[$i-1] == 1);
		print $OUT $char_array[$i];
	    }
	}
	print $OUT "\n";

	for ($i = 0; $i < @char_array; $i++) {
	    print $OUT $char_array[$i] if ($check_array[$i] == 1);
	}
	print $OUT "\n";
    }
}

######################################################################
#				 END
######################################################################
