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
$notify->set_inc( $pkg_config{cflags}.' -Ibuild -Wall' );
$notify->set_libs( $pkg_config{libs} );
$notify->install( File::Spec->catfile(qw( build notify-autogen.h )) );
$notify->add_pm(
    'lib/Notify.pm' => '$(INST_LIBDIR)/Notify.pm',
);

WriteMakefile(
    NAME                => 'Gtk2::Notify',
    AUTHOR              => 'Florian Ragwitz <rafl@debian.org>',
    VERSION_FROM        => 'lib/Notify.pm',
    ABSTRACT_FROM       => 'lib/Notify.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => '0',
        'Glib'       => '1.093',
    },
    MAN3PODS => {
        'lib/Notify.pm' => '$(INST_MAN3DIR)/Gtk2::Notify.$(MAN3EXT)',
        Glib::MakeHelper->do_pod_files(@xs_files),
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Gtk2-Notify-*' },
    $notify->get_makefile_vars,
);

package MY;

sub postamble {
    return Glib::MakeHelper->postamble_clean()
         . Glib::MakeHelper->postamble_docs_full(
             DEPENDS   => $main::notify,
             XS_FILES  => \@main::xs_files,
             COPYRIGHT => 'Copyright (C) 2006-2008 by Florian Ragwitz',
         );
}
