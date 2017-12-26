#!/usr/bin/perl
use strict;
use warnings;

use lib "../../_lib";
use RWPatcher::Animals;

#
# SWF Walkers need to be patched as modded animals (add CE armor pen, bodyShape, etc.).
#

# Get entity tool melee bodyparts from mod source xml
    # For each, patch file will be ./<base-dir-name>/<file.xml>
# Source may end with (-REF)?.(txt|xml), which will be replaced with ".xml".
my @SOURCEFILES = qw(
    ../../918227266/Defs/PawnkindDefs/PawnKinds_ImpWalkers.xml
    ../../918227266/Defs/PawnkindDefs/PawnKinds_Speeders.xml
);
my $SOURCEMOD = 'Star Wars - Factions';  # Only patch if this mod is loaded (leave undefined to skip)

# DEFAULT values not in source xml from Dinosauria
my %DEF = (
    bodyShape => "Quadruped",
    MeleeDodgeChance => 0.08,	# Elephant
    MeleeCritChance => 0.79,	# Elephant

    # baseHealthScale: birds=0.8x vanilla, bears=1.2x vanilla (general guide)
    # (dinosauria already seems to keep relative base health per type, so not changing this)
    #baseHealthScale   => 3.6,	# Elephant (Thrumbo = 13, Megasloth = 3.6) <-- no CE changes

    # Armor values exist in vanilla but need to be adjusted for CE
    # (ex. CE Thrumbo is ridiculously tanky).
    #
    ArmorRating_Blunt => 0.21,	# Elephant/Megasloth = 0.1,   Thrumbo = 0.2
    ArmorRating_Sharp => 0.21,	# Elephant/Megasloth = 0.125, Thrumbo = 0.3
);

# Give all walkers the same CE values for now

# hash of values per animal (using values from a17 MF+CE patch)
# required: dodge, crit (not defined in vanilla)
# optional: bodyShape (else default)
# optional: any/all from @ARMORTYPES
# optional: baseHealthScale
my %PATCHABLES = (
    SWFactions_WalkerThing	=> \%DEF,
    SWFactions_ATATThing	=> \%DEF,
    SWFactions_SpeederThing	=> \%DEF,
);

my $patcher = new RWPatcher::Animals(
    #sourcemod   => $SOURCEMOD,
    sourcefiles => \@SOURCEFILES,
    cedata      => \%PATCHABLES,
) or die("ERR: Failed new RWPatcher::Animals: $!\n");

$patcher->expected_parent("BaseWalker"); # patch any element with this parent class

$patcher->generate_patches();

exit(0);

__END__

