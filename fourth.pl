use warnings;
use strict;

my $input = 'fourth.txt';

my $part_1_sum = 0;
open(FH, '<', $input) or die $!;
while(<FH>){
    /Card\s+(\d+)\:((?:\s+\d+)+)\s+\|((?:\s+\d+)+)/;
    my $card = $1;
    my $winning_part = $2;
    my $chosen_part = $3;
    my @winning = $winning_part =~ /(\d+)/g;
    my @chosen_arr = $chosen_part =~ /(\d+)/g;
    my %chosen = map { $_ => 1 } @chosen_arr;
    my %num_wins;
    foreach (@winning) {
        if (exists $chosen{$_}) {
            $num_wins{$_} = 1;
        }
    }
    my $wins = keys %num_wins;
    if ($wins) {
        $part_1_sum += 2**($wins - 1)
    }
}
close(FH);

print "Part 1: $part_1_sum\n";

my %cards;
open(FH, '<', $input) or die $!;
while(<FH>){
    /Card\s+(\d+)\:((?:\s+\d+)+)\s+\|((?:\s+\d+)+)/;
    my $card = $1;
    unless (exists $cards{$card}) {
        $cards{$card} = 1;
    }
    my $winning_part = $2;
    my $chosen_part = $3;
    my @winning = $winning_part =~ /(\d+)/g;
    my @chosen_arr = $chosen_part =~ /(\d+)/g;
    my %chosen = map { $_ => 1 } @chosen_arr;
    my %num_wins;
    foreach (@winning) {
        if (exists $chosen{$_}) {
            $num_wins{$_} = 1;
        }
    }
    my $wins = keys %num_wins;
    if ($wins) {
        for (($card+1)..($card+$wins)) {
            unless (exists $cards{$_}) {
                $cards{$_} = 1;
            }
            my $to_add = $cards{$card};
            $cards{$_} += $to_add;
        }
    }
}
close(FH);

my $part_2_sum = 0;
for my $num_cards (values %cards) {
  $part_2_sum += $num_cards;
}
print "Part 2: $part_2_sum\n";
