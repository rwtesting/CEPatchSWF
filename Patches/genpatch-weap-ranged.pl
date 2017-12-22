#!/usr/bin/perl
use strict;
use warnings;

use XML::Simple;
use File::Basename qw(basename);

#
# Generate CE patch for @SOURCEFILES:
# - Add missing CE values
# - Add <tools> node (gun melee values, use the same values for all blasters for now).
# - Verbatim copy <verbs> node to new CE <Properties> node.
#   (tried renaming <verbs> to Properties + changes, but <verbs> needs to remain)
#   (can't find a built-in method for copying a node via operations)
#
# Write results to $OUTFILE (overwrite existing).
#
# Warn+Skip if blaster found in source file that we don't have CE data for.
#

# Common values for all guns
my $VERBCLASS = 'CombatExtended.Verb_ShootCE';

# The source (from source mod) files to be used to generate patches.
# The output file will have the same base name, with s/(-REF)?.txt/.xml/, target $OUTDIR.
# (.txt is sometimes used for copied ref/source files so that Rimworld doesn't read them)
my $OUTDIR = "./WeaponDefs_Ranged";
my @SOURCEFILES = qw(
    ../../918227266/Defs/WeaponDefs_Ranged/Blaster_Weps.xml
    ../../918227266/Defs/WeaponDefs_Ranged/InstalledPart_Weps.xml
);

# CE Values + ammo for each blaster, from a17 patch by jaeger972
# Add new b18 CE weapon tags and generate patch in b18 format.
my %CEDATA = (

    ##########################
    # FILE: Blaster_Weps.xml #
    ##########################

    PJ_E11Blaster => {
	SightsEfficiency => 1,
	ShotSpread	 => 0.07,
	SwayFactor	 => 1.30,
	Bulk		 => 6.50,
	weaponTags	 => [qw(CE_AI_AssaultWeapon)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',  # was projectileDef in a17

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 24,
	    reloadTime	 => 3,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aimedBurstShotCount => 3,
	    aiUseBurstMode	=> 'TRUE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_DH17Blaster => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.11,
	SwayFactor	 => 1.02,
	Bulk		 => 2.17,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 15,
	    reloadTime	 => 3,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_Scoutblaster => {
	SightsEfficiency => 0.85,
	ShotSpread	 => 0.21,
	SwayFactor	 => 1.32,
	Bulk		 => 2.17,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 16,
	    reloadTime	 => 2,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aimedBurstShotCount => 2,
	    aiUseBurstMode	=> 'TRUE',
	    aiAimMode		=> 'AimedShot',
	},

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',
    },
    PJ_SE14blaster => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.11,
	SwayFactor	 => 1.02,
	Bulk		 => 2.17,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 20,
	    reloadTime	 => 3,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aimedBurstShotCount => 2,
	    aiUseBurstMode	=> 'TRUE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_DL44blaster => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.21,
	SwayFactor	 => 1.32,
	Bulk		 => 3,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 12,
	    reloadTime	 => 3.5,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_DXR6Carb => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.21,
	SwayFactor	 => 1.32,
	Bulk		 => 3,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 14,
	    reloadTime	 => 3.2,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_JawaIon => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.21,
	SwayFactor	 => 1.32,
	Bulk		 => 3,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 18,
	    reloadTime	 => 3.7,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_NymSlug => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.26,
	SwayFactor	 => 1.64,
	Bulk		 => 3,
	weaponTags	 => [qw(CE_OneHandedWeapon CE_AI_AssaultWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_12Gauge_ElectroSlug',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 16,
	    reloadTime	 => 4,
	    ammoSet	 => 'AmmoSet_12Gauge',  # CE shotgun ammoset
	    #ammoSet	 => 'AmmoSet_Nym',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_LauncherP => {
	SightsEfficiency => 0.45,
	ShotSpread	 => 0.35,
	SwayFactor	 => 4.64,
	Bulk		 => 5.50,
	weaponTags	 => [qw(CE_AI_Pistol CE_OneHandedWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_84x246mmR_HEAT',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 8,
	    reloadTime	 => 6,
	    ammoSet	 => 'AmmoSet_84x246mmR',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_T21Rifle => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.11,
	SwayFactor	 => 1.02,
	Bulk		 => 4,
	weaponTags	 => [qw(CE_AI_AssaultWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge_AP',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 18,
	    reloadTime	 => 2.4,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_DC15Rifle => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.31,
	SwayFactor	 => 1.22,
	Bulk		 => 4,
	weaponTags	 => [qw(CE_AI_AssaultWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 20,
	    reloadTime	 => 2.4,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aimedBurstShotCount => 2,
	    aiUseBurstMode	=> 'TRUE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_DLT19Rifle => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.31,
	SwayFactor	 => 1.22,
	Bulk		 => 4,
	weaponTags	 => [qw(MedievalShields_ValidSidearm CE_AI_AssaultWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 24,
	    reloadTime	 => 2.4,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aimedBurstShotCount => 3,
	    aiUseBurstMode	=> 'TRUE',
	    aiAimMode		=> 'AimedShot',
	},
    },
    PJ_EE3Carbine => {
	SightsEfficiency => 0.7,
	ShotSpread	 => 0.08,
	SwayFactor	 => 0.82,
	Bulk		 => 4,
	weaponTags	 => [qw(CE_AI_AssaultWeapon CE_Sidearm)],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 30,
	    reloadTime	 => 1.9,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	    aiAimMode		=> 'AimedShot',
	},
    },

    ################################
    # FILE: InstalledPart_Weps.xml #
    ################################

    PJ_ATST_Blaster => {
	SightsEfficiency => 0.75,
	ShotSpread	 => 0.13,
	SwayFactor	 => 0.89,
	Bulk		 => 5.65,
	weaponTags	 => [],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWBigPlasmaGasCartridge_AP',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 6,
	    reloadTime	 => 3,
	    ammoSet	 => 'AmmoSet_SWBigPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	},
    },
    PJ_ATAT_Blaster => {
	SightsEfficiency => 0.75,
	ShotSpread	 => 0.13,
	SwayFactor	 => 0.89,
	Bulk		 => 5.65,
	weaponTags	 => [],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWBigPlasmaGasCartridge',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 6,
	    reloadTime	 => 3,
	    ammoSet	 => 'AmmoSet_SWBigPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	},
    },
    PJ_Spd_Blaster => {
	SightsEfficiency => 0.75,
	ShotSpread	 => 0.13,
	SwayFactor	 => 0.89,
	Bulk		 => 5.65,
	weaponTags	 => [],

	# verbs => Properties changes
	defaultProjectile => 'Bullet_SWPlasmaGasCartridge_AP',

	# AmmoUser from comps
	AmmoUser => {
            magazineSize => 10,
	    reloadTime	 => 1.2,
	    ammoSet	 => 'AmmoSet_SWPlasmaGasCartridge',
	},

	# FireModes from comps
	FireModes => {
	    aiUseBurstMode	=> 'FALSE',
	},
    },

);

# Process each source file, print to output patch file.
my($sourcefile, $outfile);
foreach $sourcefile (@SOURCEFILES)
{

# Generate output patch file name
($outfile = "$OUTDIR/".basename($sourcefile)) =~ s/(?:-REF)\.[a-z]+$/.xml/i;
print("Source: $sourcefile\nPatch : $outfile\n");

# Open source/output files
my $source =  XMLin($sourcefile, ForceArray => [qw(ThingDef li)])
    or die("ERR: read source xml $sourcefile: $!\n");

open(OUTFILE, ">", $outfile)
    or die("ERR: open/write $outfile: $!\n");

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
my($data, $key, $val);
foreach my $entry ( @{$source->{ThingDef}} )
{
    next unless exists($entry->{defName}) && exists $CEDATA{$entry->{defName}};
    $data = $CEDATA{$entry->{defName}};

    print OUTFILE (<<EOF);
    <!-- ========== $entry->{defName} ========== -->

    <!-- Create tools node if it doesn't exist -->
    <li Class="PatchOperationSequence">
    	<success>Always</success>
    	<operations>
      	    <li Class="PatchOperationTest">
      		<xpath>*/ThingDef[defName="$entry->{defName}"]/tools</xpath>
        	<success>Invert</success>
      	    </li>
      	    <li Class="PatchOperationAdd">
      		<xpath>*/ThingDef[defName="$entry->{defName}"]</xpath>
        	<value>
          	    <tools />
        	</value>
      	    </li>
    	</operations>
    </li>

    <!-- Add tools melee values -->
    <li Class="PatchOperationAdd">
      <xpath>Defs/ThingDef[defName="$entry->{defName}"]/tools</xpath>
      <value>
        <li Class="CombatExtended.ToolCE">
          <label>stock</label>
          <capacities>
            <li>Blunt</li>
          </capacities>
          <power>9</power>
          <cooldownTime>1.8</cooldownTime>
          <commonality>1.5</commonality>
          <armorPenetration>0.11</armorPenetration>
          <linkedBodyPartsGroup>Stock</linkedBodyPartsGroup>
        </li>
        <li Class="CombatExtended.ToolCE">
          <id>barrelblunt</id>
          <label>barrel</label>
          <capacities>
            <li>Blunt</li>
          </capacities>
          <power>10</power>
          <cooldownTime>1.9</cooldownTime>
          <armorPenetration>0.118</armorPenetration>
          <linkedBodyPartsGroup>Barrel</linkedBodyPartsGroup>
        </li>
        <li Class="CombatExtended.ToolCE">
          <id>barrelpoke</id>
          <label>barrel</label>
          <capacities>
            <li>Poke</li>
          </capacities>
          <power>10</power>
          <cooldownTime>1.9</cooldownTime>
          <armorPenetration>0.086</armorPenetration>
          <linkedBodyPartsGroup>Barrel</linkedBodyPartsGroup>
        </li>
      </value>
    </li>

    <!-- CE conversion -->
    <li Class="CombatExtended.PatchOperationMakeGunCECompatible">
      <defName>$entry->{defName}</defName>
      <statBases>
        <Bulk>$data->{Bulk}</Bulk>
        <SightsEfficiency>$data->{SightsEfficiency}</SightsEfficiency>
        <ShotSpread>$data->{ShotSpread}</ShotSpread>
        <SwayFactor>$data->{SwayFactor}</SwayFactor>
      </statBases>
EOF
    # Copy <verbs> node to <Properties> for CE, update verb class
    if (exists $entry->{verbs} )
    {
        print OUTFILE (<<EOF);
      <Properties>
EOF
	while ( ($key,$val) = each %{$entry->{verbs}->{li}->[0]} )
	{
	    # Translate
	    if ($key eq "verbClass")
	    {
	        $val = $VERBCLASS 
	    }
	    elsif ($key eq "defaultProjectile")
	    {
	        $val = $data->{defaultProjectile};
	    }

	    print OUTFILE (<<EOF);
          <$key>$val</$key>
EOF
         
	 }
         print OUTFILE (<<EOF);
      </Properties>
EOF
     }

    # Add weapon tags from both source xml and CE data, if any
    #%union = map {$_ => 1} (exists $entry->{weaponTags} ? @{$entry->{weaponTags}->{li}} : (), exists $data->{weaponTags} ? @{$data->{weaponTags}} : ());
    if (exists $data->{weaponTags})
    {
         print OUTFILE (<<EOF);
      <weaponTags>
EOF
	 foreach $key ( @{$data->{weaponTags}} )
	 {
	     print OUTFILE (<<EOF);
  	   <li>$key</li>
EOF
	 }

         print OUTFILE (<<EOF);
      </weaponTags>
EOF

    # Add AmmoUser (CE only)
    if (exists $data->{AmmoUser})
    {
	print OUTFILE (<<EOF);
      <AmmoUser>
EOF
	while ( ($key,$val) = each %{$data->{AmmoUser}} )
	{
	print OUTFILE (<<EOF);
  	   <$key>$val</$key>
EOF
	}
	print OUTFILE (<<EOF);
      </AmmoUser>
EOF
    }
    else
    {
	print OUTFILE (<<EOF);
      <AmmoUser />
EOF
    }


    # Add FireModes (CE only)
    if (exists $data->{FireModes})
    {
	print OUTFILE (<<EOF);
      <FireModes>
EOF
	while ( ($key,$val) = each %{$data->{FireModes}} )
	{
	print OUTFILE (<<EOF);
  	   <$key>$val</$key>
EOF
	}
	print OUTFILE (<<EOF);
      </FireModes>
EOF
    }
    else
    {
	print OUTFILE (<<EOF);
      <FireModes />
EOF
    }

    # Closer: CombatExtended.PatchOperationMakeGunCECompatible
    print OUTFILE (<<EOF);
    </li>

EOF
    }

    # Assume we don't need to add comps for AmmoUser/FireModes, since CE op should handle that
}

# Closer
print OUTFILE (<<EOF);
  </operations>  <!-- end sequence -->
  </Operation>   <!-- end sequence -->

</Patch>

EOF

}  # end foreach @SOURCEFILES

exit(0);

__END__

