#!/usr/bin/perl -w

use Noink2;

my $c = Noink2->new;

$c->register( -version => "1.9.2",
                     -id => "ntest",
                     -name => "Noink2 Test",
                     -author => "Samuel Hart",
                     -copyright => "None, Public Doman" );

my $h = $c->login_user( -username => "root", -password => "poopie" );
print "\n\ngot back $h\n\n";

$h = $c->{UID};
print "$h\n\n";

$c->test;

print "\n\nDid that work?\n";

1;
