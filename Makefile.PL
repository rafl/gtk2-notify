use strict;
use warnings;
use File::Spec;
use Glib::CodeGen;
use Glib::MakeHelper;
use ExtUtils::Depends;
use ExtUtils::PkgConfig;
use ExtUtils::MakeMaker;

mkdir 'build', 0777;

my %pkg_config = ExtUtils::PkgConfig->find('libnotify');

Glib::CodeGen->parse_maps('notify');
Glib::CodeGen->write_boot(ignore => qr/^Gtk2::Notify$/);

our $notify = ExtUtils::Depends->new('Gtk2::Notify', 'Gtk2');
our @xs_files = <xs/*.xs>;

$notify->add_xs( @xs_files );
$notify->add_typemaps( File::Spec->rel2abs( File::Spec->catfile(qw( build notify.typemap )) ) );
$notify->set_inc( $pkg_config{cflags}.' -Ibuild -Wall -Werror' );
$notify->set_libs( $pkg_config{libs} );
$notify->install( File::Spec->catfile(qw( build notify-autogen.h )) );
$notify->add_pm(
    'pm/Notify.pm' => '$(INST_LIBDIR)/Notify.pm',
);

WriteMakefile(
    NAME                => 'Gtk2::Notify',
    AUTHOR              => 'Florian Ragwitz <rafl@debian.org>',
    VERSION_FROM        => 'pm/Notify.pm',
    ABSTRACT_FROM       => 'pm/Notify.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => '0',
        'Glib'       => '1.093',
    },
    MAN3PODS => {
        'pm/Notify.pm' => '$(INST_MAN3DIR)/Gtk2::Notify.$(MAN3EXT)',
        Glib::MakeHelper->do_pod_files(@xs_files),
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Gtk2-Notify-*' },
    $notify->get_makefile_vars,
);

package MY;

sub postamble {
    return 'POD_SET=$$Glib::GenPod::COPYRIGHT="Copyright (C) 2006 Florian Ragwitz<br><br>'
        . 'This library is free software; you can redistribute it and/or modify it under '
        . 'the terms of the GNU Library General Public License as published by the Free '
        . 'Software Foundation; either version 2 of the License, or (at your option) any '
        . 'later version.<br><br>'
        . 'This library is distributed in the hope that it will be useful, but WITHOUT ANY '
        . 'WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A '
        . 'PARTICULAR PURPOSE.  See the GNU Library General Public License for more details.'
        . '<br><br>'
        . 'You should have received a copy of the GNU Library General Public License along '
        . 'with this library; if not, write to the Free Software Foundation, Inc., 59 '
        . 'Temple Place - Suite 330, Boston, MA  02111-1307  USA.";'
        . Glib::MakeHelper->postamble_clean()
        . Glib::MakeHelper->postamble_docs_full(DEPENDS => $main::notify);
}
