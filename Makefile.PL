
use 5.008;
use ExtUtils::MakeMaker;
use Cwd;
use File::Spec;
use ExtUtils::Depends;
use ExtUtils::PkgConfig;
use Gtk2::CodeGen;

mkdir 'build', 0777;

my %pkgcfg = ExtUtils::PkgConfig->find ('gtk+-2.0');

Gtk2::CodeGen->parse_maps ('trayicon');
Gtk2::CodeGen->write_boot;

$trayicon = ExtUtils::Depends->new ('Gtk2::TrayIcon', 'Gtk2', 'Glib');
$trayicon->set_inc ($pkgcfg{cflags} . " -DEGG_COMPILATION");
$trayicon->set_libs ($pkgcfg{libs});
$trayicon->add_c("eggtrayicon.c");
$trayicon->add_xs ("TrayIcon.xs");
$trayicon->add_pm ('TrayIcon.pm' => '$(INST_LIBDIR)/TrayIcon.pm');
my $cwd = cwd();
$trayicon->add_typemaps (map {File::Spec->catfile($cwd,$_)} 'build/trayicon.typemap');

# $trayicon->add_headers ('trayicon.h');
# $trayicon->install (qw(trayicon.h build/trayicon-autogen.h));

$trayicon->install (qw(build/trayicon-autogen.h));
$trayicon->save_config ('build/IFiles.pm');

WriteMakefile(
    NAME            => 'Gtk2::TrayIcon',
    VERSION_FROM    => 'TrayIcon.pm', # finds $VERSION
    ABSTRACT_FROM   => 'TrayIcon.pm', # retrieve abstract from module
    XSPROTOARG      => '-noprototypes',
    $trayicon->get_makefile_vars,
    PREREQ_PM       =>  {
    	Gtk2 => 0.96,
    },
);

package MY;

sub postamble
{
	"
realclean ::
	-rm -Rf build
"
}
package MAIN;
# gcc -I. `pkg-config --cflags gtk+-2.0` `pkg-config --libs gtk+-2.0` -DEGG_COMPILATION -DGTK_DISABLE_DEPRECATED -DGDK_DISABLE_DEPRECATED -DG_DISABLE_DEPRECATED -g -O2 -Wall --shared eggtrayicon.c -o eggtrayicon.o
