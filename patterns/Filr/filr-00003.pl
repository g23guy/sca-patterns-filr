#!/usr/bin/perl

# Title:       Filr Disk Space used by mySQL
# Description: The mysql-bin files using up a lot of free space
# Modified:    2013 Jun 22

##############################################################################
#  Copyright (C) 2013 SUSE LLC
##############################################################################
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

#  Authors/Contributors:
#   Jason Record (jrecord@suse.com)

##############################################################################

##############################################################################
# Module Definition
##############################################################################

use strict;
use warnings;
use SDP::Core;
use SDP::SUSE;
use SDP::Filr;

##############################################################################
# Overriden (eventually or in part) from SDP::Core Module
##############################################################################

@PATTERN_RESULTS = (
	PROPERTY_NAME_CLASS."=Filr",
	PROPERTY_NAME_CATEGORY."=Disk",
	PROPERTY_NAME_COMPONENT."=Capacity",
	PROPERTY_NAME_PATTERN_ID."=$PATTERN_ID",
	PROPERTY_NAME_PRIMARY_LINK."=META_LINK_TID",
	PROPERTY_NAME_OVERALL."=$GSTATUS",
	PROPERTY_NAME_OVERALL_INFO."=None",
	"META_LINK_TID=http://www.suse.com/support/kb/doc.php?id=7012442",
	"META_LINK_BUG=https://bugzilla.novell.com/show_bug.cgi?id=816530"
);




##############################################################################
# Local Function Definitions
##############################################################################

sub getVAPercentFree {
	SDP::Core::printDebug('> getVAPercentFree', 'BEGIN');
	my $RCODE = 0;
	my $TMP;
	my $NOT_FOUND = 1;
	my @MOUNTS = SDP::SUSE::getFileSystems();
	my @MPT_CHECK = qw(/vastorage/mysql /vastorage /);
	foreach my $MOUNT_POINT (@MPT_CHECK) {
		SDP::Core::printDebug('CHECKING', $MOUNT_POINT);
		if ( $NOT_FOUND ) {
			foreach $TMP (@MOUNTS) {
				if ( $TMP->{'MPT'} =~  m/^$MOUNT_POINT/ ) {
					SDP::Core::printDebug(' CONFIRMED', "$MOUNT_POINT == $TMP->{'MPT'} at $TMP->{'USEPCT'}%");
					$RCODE = $TMP->{'USEPCT'};
					$NOT_FOUND = 0;
					last;
				} else {
					SDP::Core::printDebug(' REJECTED', "$MOUNT_POINT <> $TMP->{'MPT'} at $TMP->{'USEPCT'}%");
				}
			}
		}
		last if ( ! $NOT_FOUND );
	}

	if ( $NOT_FOUND ) {
		SDP::Core::updateStatus(STATUS_ERROR, "ERROR: getVAPercentFree(): No volume with /vastorage found");
	}
	SDP::Core::printDebug("< getVAPercentFree", "Returns: $RCODE");
	return $RCODE;
}

##############################################################################
# Main Program Execution
##############################################################################

SDP::Core::processOptions();
	my $FILR_VER = SDP::Filr::getFilrVersion();
	if ( "$FILR_VER" ne '' ) {
		my $LIMIT_USED_CRITICAL = 75; #percent disk space used
		my $LIMIT_USED_WARNING = 10; #percent disk space used
		my $PERCENT_USED = getVAPercentFree();
		if ( $PERCENT_USED >= $LIMIT_USED_CRITICAL ) {
			SDP::Core::updateStatus(STATUS_CRITICAL, "/vastorage at $PERCENT_USED% capacity, consider expire_logs_days in /etc/my.cnf");
		} elsif ( $PERCENT_USED >= $LIMIT_USED_WARNING ) {
			SDP::Core::updateStatus(STATUS_WARNING, "/vastorage at $PERCENT_USED% capacity, consider expire_logs_days in /etc/my.cnf");
		} else {
			SDP::Core::updateStatus(STATUS_ERROR, "/vastorage at $PERCENT_USED% capacity -- within limits");
		}
	} else {
		SDP::Core::updateStatus(STATUS_ERROR, "Novell Filr not installed, skipping disk full test");
	}
SDP::Core::printPatternResults();

exit;


