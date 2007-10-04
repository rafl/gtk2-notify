#!/usr/bin/perl

use strict;
use warnings;
use Gtk2 -init;
use Gtk2::Notify -init, $0;
use Data::Dumper;

my $icon_path = '/usr/share/icons/gnome/48x48/stock/generic/stock_example.png';

my $window = Gtk2::Window->new;

my $button = Gtk2::Button->new_from_stock('gtk-ok');
$window->add($button);
$window->show_all;

$window->signal_connect('destroy' => sub {
        Gtk2->main_quit;
});

$button->signal_connect('clicked' => sub {
        my $n = Gtk2::Notify->new('Foo', 'Bar', $icon_path, $button);
        $n->add_action('foo', 'Foo', \&action_cb, 42);
        $n->add_action('bar', 'Bar', \&action_cb, 43);
        $n->show;
});

Gtk2->main;

sub action_cb {
    my ($n, $action, $data) = @_;

    print Dumper(\@_);
}
