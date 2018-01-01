#!/usr/bin/perl
use strict;
use warnings;

use lib $ENV{RWPATCHER_LIB};
use RWPatcher::Pawnkinds;

# Generate CE patches for pawnkind files.

my $SOURCEMOD = "Star Wars - Factions";

my @SOURCEFILES = qw(
    ../../918227266/Defs/PawnkindDefs/PawnKinds_Imp.xml
    ../../918227266/Defs/PawnkindDefs/PawnKinds_ImpWalkers.xml
    ../../918227266/Defs/PawnkindDefs/PawnKinds_Rebel.xml
    ../../918227266/Defs/PawnkindDefs/PawnKinds_Scum.xml
    ../../918227266/Defs/PawnkindDefs/PawnKinds_Speeders.xml
);

my %CEDATA = (
    SWFactions_WalkerKind	=> {AmmoMin => 100, AmmoMax => 200},
    SWFactions_ATATKind		=> {AmmoMin => 100, AmmoMax => 200},
    SWFactions_SpeederKindImp	=> {AmmoMin => 100, AmmoMax => 200},
    SWFactions_SpeederKindReb	=> {AmmoMin => 100, AmmoMax => 200},
);

my $patcher;
foreach my $sourcefile (@SOURCEFILES)
{
    $patcher = new RWPatcher::Pawnkinds(
	AmmoMin    => 3,
	AmmoMax    => 5,
	#sourcemod  => $SOURCEMOD,
        sourcefile => $sourcefile,
        cedata     => \%CEDATA,
        expected_parents => [ qw(
            ImpBase
            PJ_RebelPawnBase
            PJ_RebVillager
            PJ_SVBase
	), "" ],
    ) or die("ERR: Failed new RWPatcher::Pawnkinds: $!\n");

    $patcher->generate_patches();
}

exit(0);

__END__

