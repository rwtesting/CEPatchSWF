#!/usr/bin/perl
use strict;
use warnings;

# pawnkinds, grouped by file (from original mod)
# 1 patch sequence per file for faster load times
my @PAWNKINDS = (
    [ qw(
    PJ_ImpInspector
    PJ_ImpTaxOfficer
    PJ_ImpSoldier
    PJ_ImpTrader
    PJ_Stormtrooper
    PJ_StormtrooperSO
    PJ_ImpCommander
    PJ_ScoutTrooper
    ) ],
    [ qw(
    PJ_RebVillager
    PJ_RebCouncilman
    PJ_RebTrader
    PJ_RebGuard
    PJ_RebSoldier
    PJ_RebLAVSoldier
    PJ_RebNadeSoldier
    PJ_RebPilot
    PJ_RebMerc
    ) ],
    [ qw(
    PJ_ScumSoldier
    PJ_Ruffian
    PJ_ScumBoss
    PJ_BountyHunter
    ) ],
    [ qw(
    SWFactions_WalkerThing
    SWFactions_WalkerKind
    SWFactions_ATATThing
    SWFactions_ATATKind
    ) ],
    [ qw(
    SWFactions_SpeederThing
    SWFactions_SpeederKindImp
    SWFactions_SpeederKindReb
    ) ],

);

my $OUTFILE = "./PawnkindDefs/Pawnkinds-CE-patch.xml";
open(OUTFILE, ">", $OUTFILE) or die("ERR: open/write $OUTFILE: $!\n");
print("Generating patch file: $OUTFILE\n");

print OUTFILE (<<EOF);
<?xml version="1.0" encoding="utf-8" ?>
<Patch>

  <!-- One sequence per xml file from original mod for faster load times.
       Breaks if mod author changes pawnkind-file relationship. -->

EOF

my($pawngroup, $pawnkind, $min, $max);
my $sequence_num = 1;
foreach $pawngroup (@PAWNKINDS)
{
    print OUTFILE (<<EOF);
  <!-- ========== Sequence #$sequence_num ========== -->

  <Operation Class="PatchOperationSequence">
  <success>Always</success>
  <operations>

EOF
    foreach $pawnkind (@$pawngroup)
    {
	$min = $pawnkind =~ /^SWFactions/ ? 100 : 3;  # SWFactions = mech
	$max = $pawnkind =~ /^SWFactions/ ? 100 : 5;  # SWFactions = mech
        print OUTFILE (<<EOF);
  <li Class="PatchOperationAddModExtension">
    <xpath>Defs/PawnKindDef[defName="$pawnkind"]</xpath>
    <value>
      <li Class="CombatExtended.LoadoutPropertiesExtension">
        <primaryMagazineCount>
          <min>$min</min>
          <max>$max</max>
        </primaryMagazineCount>
      </li>
    </value>
  </li>

EOF
    }

    # closer for this sequence
    print OUTFILE (<<EOF);
  </operations>  <!-- end sequence #$sequence_num -->
  </Operation>   <!-- end sequence #$sequence_num -->

EOF
  ++$sequence_num;
}

print OUTFILE (<<EOF);
</Patch>

EOF

close(OUTFILE) or warn("WARN: close $OUTFILE: $!\n");

exit(0);

__END__

