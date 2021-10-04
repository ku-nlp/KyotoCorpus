#!/usr/bin/env perl

use utf8;
binmode(STDIN, ':encoding(shift_jis)');
binmode(STDOUT, ':encoding(utf8)');

$ad{"01"} = "１面";
$ad{"02"} = "２面";
$ad{"03"} = "３面";
$ad{"04"} = "解説";
$ad{"05"} = "社説";
$ad{"07"} = "国際";
$ad{"08"} = "経済";
$ad{"10"} = "特集";
$ad{"12"} = "総合";
$ad{"13"} = "家庭";
$ad{"14"} = "文化";
$ad{"15"} = "読書";
$ad{"16"} = "科学";
$ad{"18"} = "芸能";
$ad{"35"} = "スポーツ";
$ad{"41"} = "社会";

sub zen2han($) {
    $_[0] =~ tr/　！”＃＄％＆’（）＊＋，−．／０-９：；＜＝＞？＠Ａ-Ｚ［￥］＾—　ａ-ｚ｛｜｝￣　/ !-~/;
    $_[0];
}

sub transfer($$) {
    my ( $key, $context ) = @_;
    my $data;

    if ( $key eq 'ID' || $key eq 'C0' || $key eq 'AF' ) {
	$data = zen2han( $context );
    } elsif ( $key eq 'AE' ) {
	$data  = ( $context eq 'Ｙ' ) ? '有' : '無' ;
    } elsif ( $key eq 'S1' ) {
	my $size;
	( $size ) = /.*（全(.*)文字）/;
	$data = zen2han( $size );
    } elsif ( $key eq 'AD' ) {
	$data = $ad{zen2han($context)}
    } else {
	$data = $context;
    }

    $data;
}

sub output {
    my $key;

    print "<ENTRY>\n";

    foreach $key ( 'ID', 'C0', 'AD', 'AE', 'AF', 'T1', 'S1' ) {
	print "<", $key, ">", $keyword{$key}->[0], "</", $key, ">\n";
    }
    foreach $key ( 'S2', 'T2' ) {
	print "<",$key,">\n", join("\n",@{$keyword{$key}}), "\n</",$key,">\n";
    }
    foreach $key ( 'KA','AA','KB','AB' ) {
	print "<",$key,">", join( " ",@{$keyword{$key}} ), "</", $key,">\n";
    }
    print "</ENTRY>\n";
}

$first = 1;

while (<STDIN>) {
    chomp;
    s/\r$//; # 新しいmai1995.txtにはCRが入っているので削除
    ( $tag, $context ) = /＼(.*)＼(.*)/;
    $key = zen2han( $tag );
    $data = transfer( $key, $context );
    if ( $key eq "ID" ) {
	if ( $first == 1 ) {
	    $first = 0;
	} elsif ( $first == 0 ) {
	    output;
	    undef %keyword;
	    $first = -1;
	} else {
	    print "\n";
	    output;
	    undef %keyword;
	}
    }
    $keyword{$key} = [] unless $keyword{$key};
    push @{$keyword{$key}}, $data;
}

output;
