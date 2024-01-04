use v6;

grammar WORKFLOW
{
    token TOP { <name> '{' <ternary> '}' }

    token name { <[a..z]>* }
    token ternary { <cond> ':' <goto> ',' [ <ternary> | <final> ] }

    token goto { <name> | 'A' | 'R' }
    token final { <name> | 'A' | 'R' }

    token cond { <field> <comparator> <value> }
    token field    { 'x' | 'm' | 'a' | 's' }
    token comparator { '<' | '>' }
    token value { \d+ }
}

sub parse_input {
    my ($workflows, $ratings) = 'nineteenth.txt'.IO.slurp.split("\n\n");
    my @workflows-parsed = $workflows
        .split("\n")
        .map({WORKFLOW.parse($_)})
        .flatmap({($_<name>, $_<ternary>)});
    my @ratings-parsed = $ratings
        .split("\n")
        .map({m/\{
            x\=$<x>=(\d+)\,
            m\=$<m>=(\d+)\,
            a\=$<a>=(\d+)\,
            s\=$<s>=(\d+)
            \}/.hash});
    Map.new(@workflows-parsed), @ratings-parsed
}

my ($workflows, $ratings) = parse_input;

sub propagate_once($ternary, %rating) {
    my $greater = %rating{$ternary<cond><field>} > $ternary<cond><value>;
    my $less = %rating{$ternary<cond><field>} < $ternary<cond><value>;
    my $compare_greater = $ternary<cond><comparator> eq '>';
    if $compare_greater && $greater || !$compare_greater && $less {
        $ternary<goto>
    } elsif $ternary<ternary> !=== Nil {
        propagate_once($ternary<ternary>, %rating)
    } else {
        $ternary<final>
    };
}

sub propagate($ternary, %rating) {
    my $goto = propagate_once($ternary, %rating);
    if $goto eq 'A' {
        %rating.values.sum
    } elsif  $goto eq 'R' {
        0
    } else  {
        propagate($workflows{$goto}, %rating)
    }
}

say "Part 1: {$ratings.map({propagate($workflows{'in'},$_)}).sum}";

sub get_range($cond, %parent_range, $negated) {
    my $field = %parent_range{$cond<field>};
    my %range = %{%parent_range};
    if $cond<comparator> eq '>' && !$negated || $cond<comparator> eq '<' && $negated  {
        %range{$cond<field>} = (max($field[0], $cond<value> + !$negated),$field[1]);
    } else {
        %range{$cond<field>} = ($field[0], min($field[1], $cond<value> - !$negated));
    }
    %range
}

sub valid_range(%range) {
    sub check($s) {
        %range{$s}[0] <= %range{$s}[1]
    }
    check("x") && check("m") && check("a") && check("s")
}

sub range_volume(%range) {
    sub onedim($s) {
        %range{$s}[1] - %range{$s}[0] + 1
    }
    onedim("x") * onedim("m") * onedim("a") * onedim("s")
}

sub get_nodes($ternary, @nodes, %parent_range) {
    if $ternary<final> !=== Nil {
        @nodes.append((
            ($ternary<goto>, get_range($ternary<cond>, %parent_range, False)),
            ($ternary<final>, get_range($ternary<cond>, %parent_range, True)),
        ))
    } else {
        my %goto_range = get_range($ternary<cond>, %parent_range, False);
        my %ternary_range = get_range($ternary<cond>, %parent_range, True);
        get_nodes($ternary<ternary>, @nodes.append((($ternary<goto>, %goto_range),)), %ternary_range)
    }
}

sub total_valid($name, $range) {
    my @nodes = ($_ if $_[0] !eq 'R' && valid_range($_[1]) for get_nodes($workflows{$name}, [], $range));
    my $accepted_volume = (range_volume($_[1]) if $_[0] eq 'A' for @nodes).sum;
    $accepted_volume + (total_valid($_[0],$_[1]) if $_[0] !eq 'A' for @nodes).sum
}

say "Part 2: {total_valid('in', %(x=>(1,4000),m=>(1,4000),a=>(1,4000),s=>(1,4000)))}";
