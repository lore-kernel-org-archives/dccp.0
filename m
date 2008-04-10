From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 10 Apr 2008 08:19:09 +0000
Subject: [Announce]: DCCP Applications Library / iperf Update
Message-Id: <20080410081909.GB19418@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

           DCCP Applications - Update, new version, and fixes

1. iperf
====-
Someone reported problems using iperf on a mainline kernel. I have investigated
this and there shouldn't be any problems since the MPS socket option is part of
the current kernel. On the current netdev-2.6 kernel it works without problems.

Yet had a look through and checked, update is on
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/zip/iperf-2.0.2_DCCP-patched-CBR-continuous.tar.bz2

Note -- Thanks to Ian's support, patches are now being prepared and forwarded 
        to the new iperf project at sourceforge. 
	Hopefully there will be	native DCCP support soon.


2. DCCP Application Library
============= This library tarball comes bundled with the ttcp/sock programs (below). It
 hadn't been updated since last August and so there are quite a few updates.

 I have uploaded a revised variant of the tarball onto
 http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/dccp_applications_lib.tar.gz

 The changes/fixes are:
 * resolved build dependencies so that the build does not require 
   UDP-Lite kernel headers (the build otherwise failed)
 * included a subdirectory `set-up-udplite-support' which contains a
   script to set up UDP-Lite userland support if one would like to do that
 * Makefile now searches for DCCP kernel include files to avoid problems
   due to missing <linux/tfrc.h> and outdated userland headers for DCCP
 * fixed several bugs in the port of Steven's sock program
 * tested all applications to work with/without UDP-Lite support
 * fixed bug in service code parser (using strtok requires using strdup)

 2a. ttcp
 --------
 The ttcp file-transport tool with support for DCCP and IPv6. Here, UDP-Lite
 conditional build support was added, so that the application will build even
 when UDP-Lite is not supported by the host's userland.

 2b. sock
 --------
 W. R. Steven's sock program with support for DCCP and IPv6. Apart from also
 adding conditional build support for UDP-Lite, there were several bug fixes:
 considering DCCP's EAGAIN case, order of socket options and minor clean-ups.

Thanks to everyone who reported bugs and problems.
-- 


The University of Aberdeen is a charity registered in Scotland, No SC013683.

