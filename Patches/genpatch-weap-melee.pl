#!/usr/bin/perl
use strict;
use warnings;

use XML::Simple;
use File::Basename qw(basename);

#
# Generate CE patch for $SOURCEFILE:
# - add weapon bulk
# - add armor penetration (tools nodes)
# - add EC attribute to tools node entries
# - add CE weapon tags
# - add melee crit/parry chance as offsets (same as CE patches for core melee weapons)
# ? Do I need to do something with deflection?
#
# Write results to $OUTFILE (overwrite existing).
#
# Warn+Skip if weapon found in $SOURCEFILE that we don't have CE data for.
#
# Armor Penetration
#   - In a17 was per-weapon
#   - In b18 is per tools item
# For b18, we'll set armor pen based on tool capacity and default to a17 value
# only if tool capacity can't be determined/mapped.
#


my $SOURCEFILE = "../../918227266/Defs/WeaponDefs_Melee/PJ_VibroWeps.xml";
my $OUTFILE    = "./WeaponDefs_Melee/PJ_VibroWeps.xml";

# Armor Penetration per tool capacity
# (to start, we'll use similar values from core patch with bonus for vibro capacities)
#
# To be more realistic, AP would be per-weapon and per-capacity.
# For example, a formula for Axe+VibroCut(more), Axe+VibroStab, Staff+VibroCut(less), etc.
# We could also take the a17 values and adjust them by capacity (+stab, -blunt, =cut?).
# Not really needed for this patch.
# (It would be a lot easier w/ less load time to apply a17 AP value to all tools entries)
#
my %AP = (
    #Cut	 => 0.201,	# longsword
    #Stab	 => 0.304,	# longsword
    Blunt	 => 0.087,	# longsword
    PJ_VibroCut	 => 0.231,	# longsword * 1.15
    PJ_VibroStab => 0.350,	# longsword * 1.15
);

# CE Values for each melee weapon, from a17 patch by jaeger972.
my %CEDATA = (
    PJ_Vibroaxe => {
        Bulk		 => 2,
	armorPenetration => 0.3,	# was MeleeWeapon_Penetration in a17
	MeleeCritChance	 => 0.5,	# vanilla gladius
	MeleeParryChance => 0.65,	# vanilla gladius
	weaponTags	 => [qw(CE_Sidearm CE_OneHandedWeapon)],
    },
    PJ_Vibrosword => {
        Bulk		 => 1.5,
	armorPenetration => 0.15,
	MeleeCritChance	 => 1,		# vanilla longsword
	MeleeParryChance => 0.75,	# vanilla longsword
	weaponTags	 => [qw(CE_Sidearm CE_OneHandedWeapon)],
    },
    PJ_Vibrocleaver => {
        Bulk		 => 1.5,
	armorPenetration => 0.15,
	MeleeCritChance	 => 0.5,	# vanilla gladius
	MeleeParryChance => 0.65,	# vanilla gladius
	weaponTags	 => [qw(CE_Sidearm CE_OneHandedWeapon)],
    },
    PJ_VScythe => {
        Bulk		 => 2.5,
	armorPenetration => 0.3,
	MeleeCritChance	 => 1,		# vanilla longsword
	MeleeParryChance => 0.75,	# vanilla longsword
	weaponTags	 => [qw(CE_Sidearm CE_OneHandedWeapon)],
    },
    PJ_Vibrodouble => {
        Bulk		 => 3.5,
	armorPenetration => 0.25,
	MeleeCritChance	 => 1,		# vanilla longsword
	MeleeParryChance => 0.75,	# vanilla longsword
	weaponTags	 => [qw(CE_Sidearm)],
    },
    PJ_StaffX => {
        Bulk		 => 3.5,
	armorPenetration => 0.1,
	MeleeCritChance	 => 0.65,	# vanilla mace
	MeleeParryChance => 0.4,	# vanilla mace
	weaponTags	 => [qw(CE_Sidearm)],
    },
    PJ_TStaff => {  # New in b18, no a17 equivalent.  We'll copy CE values from PJ_StaffX.
        Bulk		 => 3.5,
	armorPenetration => 0.1,
	MeleeCritChance	 => 0.65,	# vanilla mace
	MeleeParryChance => 0.4,	# vanilla mace
	weaponTags	 => [qw(CE_Sidearm)],
    },
);

# Open source/output files
my $source =  XMLin($SOURCEFILE, ForceArray => [qw(ThingDef li)])
    or die("ERR: read source xml $SOURCEFILE: $!\n");
open(OUTFILE, ">", $OUTFILE)
    or die("Failed to open/write $OUTFILE: $!\n");

# Header
print OUTFILE (<<EOF);
<?xml version="1.0" encoding="utf-8" ?>
<Patch>

    <!-- Warning: This will break if original mod moves weapons into diff files.
         Use a patch sequence for each file to reduce load times. -->

  <Operation Class="PatchOperationSequence">
  <success>Always</success>
  <operations>

EOF

# Step through source xml.
# Generate patch for each known defName/blaster in the same order.
my($weapon, $data, $key, $val, $ref);
foreach my $entry ( @{$source->{ThingDef}} )
{
    next unless exists($entry->{defName}) && exists $CEDATA{$entry->{defName}};
    $weapon = $entry->{defName};
    $data = $CEDATA{$entry->{defName}};

    # Add CE bulk
    print OUTFILE (<<EOF);
        <!-- ========== $weapon ========== -->

	<li Class="PatchOperationAdd">
	    <xpath>Defs/ThingDef[defName="$weapon"]/statBases</xpath>
	    <value>
                <Bulk>$data->{Bulk}</Bulk>
	    </value>
	</li>

EOF

    # Add CE weapon tags
    if (exists $data->{weaponTags})
    {
        print OUTFILE (<<EOF);
        <!-- Insert CE weapon tags. Create node if needed -->
	<li Class="PatchOperationSequence">
  	<success>Always</success>
  	<operations>
    	    <li Class="PatchOperationTest">
      	        <xpath>Defs/ThingDef[defName="$weapon"]/weaponTags</xpath>
      	        <success>Invert</success>
    	    </li>
    	    <li Class="PatchOperationAdd">
      	        <xpath>Defs/ThingDef[defName="$weapon"]</xpath>
      	            <value>
        	        <weaponTags />
      	            </value>
    	    </li>
  	</operations>
	</li>

	<li Class="PatchOperationAdd">
	    <xpath>Defs/ThingDef[defName="$weapon"]/weaponTags</xpath>
	    <value>
EOF
        foreach $key (@{$data->{weaponTags}})
	{
            print OUTFILE (<<EOF);
                <li>$key</li>
EOF
	}

        print OUTFILE (<<EOF);
	    </value>
	</li>

EOF
    }

    # Add CE attribute to tools node entries
    print OUTFILE (<<EOF);
	<!-- Add CE attribute to all tools entries -->
	<li Class="PatchOperationAttributeSet">
	    <xpath>Defs/ThingDef[defName="$weapon"]/tools/li</xpath>
	    <attribute>Class</attribute>
	    <value>CombatExtended.ToolCE</value>
	</li>

EOF
    # Add armor penetration to all tools entries
    if (exists $entry->{tools} && exists $entry->{tools}->{li})
    {
	foreach $ref ( @{$entry->{tools}->{li}} )
	{
            # AP based on capacity (default to a17 value || 0.01)
	    # (default to non-zero so we can check value in-game)
	    $key = $ref->{capacities}->{li}->[0];
	    $val = $key && $AP{$key} ? $AP{$key} : ($data->{armorPenetration} || 0.01);
            print OUTFILE (<<EOF);
	<li Class="PatchOperationAdd">
	    <xpath>Defs/ThingDef[defName="$weapon"]/tools/li[label="$ref->{label}"]</xpath>
	    <value>
		<armorPenetration>$val</armorPenetration>
	    </value>
	</li>

EOF
        }
    }

    # Add crit/parry chances as offsets
    # Add this last so that we can verify in-game that all previous sequence elements
    # were successful (check these attributes on weapons).
    print OUTFILE (<<EOF);
	 <!-- Crit/Parry chances, modeled after CE patches for core melee weapons -->
         <li Class="PatchOperationAdd">
             <xpath>Defs/ThingDef[defName="$weapon"]</xpath>
             <value>
                 <equippedStatOffsets>
                     <MeleeCritChance>$data->{MeleeCritChance}</MeleeCritChance>
                     <MeleeParryChance>$data->{MeleeParryChance}</MeleeParryChance>
                 </equippedStatOffsets>
             </value>
         </li>

EOF
}

# Add armor penetration to all tools node entries

# Closer
print OUTFILE (<<EOF);
  </operations>  <!-- end sequence -->
  </Operation>   <!-- end sequence -->

</Patch>

EOF

close(OUTFILE) or warn("WARN: close $OUTFILE: $!\n");

exit(0);

__END__

