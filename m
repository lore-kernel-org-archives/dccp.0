From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 12 Nov 2007 09:54:51 +0000
Subject: Iperf IPv6 bug
Message-Id: <20071112095451.GA8782@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Found that iperf does not set the client socket correctly, which is due
to the order of statements in filling in the socket structure. A patch
has been uploaded to

	http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/patches/04_Iperf_IPv6-Support.diff

which is already integrated into the tarball at

	http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/zip/iperf-2.0.2_DCCP-patched-CBR-continuous.tar.bz2

Test run for DCCPv6 server:

	iperf -Vsd

Test run for DCCPv6 client (to dst address `beef::2')

	iperf -V -d -c beef::2 

In IPv6 the layer-3 header reduces the MPS by an additional 20 bytes. For IPv4, iperf uses a `magic number' of 1424
bytes which corresponds to the old way of computing MPS. With the new way (dynamically, after feature negotiation),
the MPS in DCCPv4 can be up to 1440 bytes.
This means that in DCCPv6 the MPS can be maximally 1420 bytes, so that the `magic number' of 1424 bytes is still too
much unless using jumbo frames. Hence the `-l argument' becomes necessary, i.e. for a client on a normal Ethernet link:

	iperf  -V  -d   -l 1420  -c beef::2 
	
-- 
