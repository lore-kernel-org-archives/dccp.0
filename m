From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 22 Jan 2009 16:36:10 +0000
Subject: New iperf-dccp uploaded
Message-Id: <20090122163610.GB3758@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have uploaded an updated version of iperf-dccp at
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/zip/iperf-2.0.2_DCCP-patched-CBR-continuous.tar.bz2

The fix includes build errors on more recent glibc versions (2.8.90 and 2.9).
It has been tested to compile on a number of platforms (debian, arch linux, ubuntu).

Individual patches and source:
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/patches/iperf_individual_patches.tar.gz
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/zip/iperf-2.0.2.tar.gz

with UDP-Lite support:
http://www.erg.abdn.ac.uk/users/gerrit/udp-lite/files/udplite_linux.tar.gz

Many thanks to Olivier Mehani who helped with the build errors,
provided test reports on other architectures, and    
also contributed an arch linux build script on
http://aur.archlinux.org/packages.php?ID#297
