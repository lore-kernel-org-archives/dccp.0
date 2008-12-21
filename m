From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 21 Dec 2008 00:55:11 +0000
Subject: Re: [RFC] [Patch 4/4] dccp: Integrate the TFRC library (dependency)
Message-Id: <20081221005511.GC5700@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20081220080826.GE3853@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20081220080826.GE3853@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Dec 20, 2008 at 09:08:26AM +0100, Gerrit Renker escreveu:
> dccp: Integrate the TFRC library objects into DCCP
> 
> The TFRC library is a dependency of the CCID-3 (and CCID-4)
> modules. The patch updates the Kconfig menu and Makefiles.
> 
> Note -- This solution is simple, I am sure that it can be
> done better and thus welcome suggestions to improve the
> conditional build statement below.

See below how I was reworking the Makefile and Kconfig files before
fetchmail got to your patch series.

I.e. IP_DCCP_TFRC_LIB is also deleted, and in
net/dccp/ccids/libs/Makefile we do simply:

dccp-$(CONFIG_IP_DCCP_CCID3) += tfrc.o tfrc_equation.o packet_history.o loss_interval.o

- Arnaldo

P.S. It just feels wrong that TCP, that was not designed with multiple
congestion modules in mind have in Linux a plugabble congestion control
infrastructure, one idea that was something that BSD also adopted after
Linux became a more easy platform to try new congestion algorithms.

Now DCCP, that was specifically designed with such infrastructure in
mind will not have such facility :-\

Yes, the locking there used code from other parts of the kernel
(sock_create) and bitrotted while the sock_create code took advantage of
better locking facilities later introduced (RCU), so we could just make
DCCP use that new facilities and not simply remove altogether the
dynamic loading capability.

I mentioned where the old code came from and pointed the cset where it
was transformed into RCU, didn't made the conversion trying to keep the
initial patch as small as possible.
 
diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
index 7aa2a7a..ad6dffd 100644
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -1,7 +1,6 @@
 menuconfig IP_DCCP
 	tristate "The DCCP Protocol (EXPERIMENTAL)"
 	depends on INET && EXPERIMENTAL
-	select IP_DCCP_CCID2
 	---help---
 	  Datagram Congestion Control Protocol (RFC 4340)
 
@@ -25,9 +24,6 @@ config INET_DCCP_DIAG
 	def_tristate y if (IP_DCCP = y && INET_DIAG = y)
 	def_tristate m
 
-config IP_DCCP_ACKVEC
-	bool
-
 source "net/dccp/ccids/Kconfig"
 
 menu "DCCP Kernel Hacking"
diff --git a/net/dccp/Makefile b/net/dccp/Makefile
index f4f8793..e923a4d 100644
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
-dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o
+dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o \
+	  ackvec.o
 
 dccp_ipv4-y := ipv4.o
 
@@ -8,8 +9,6 @@ dccp_ipv4-y := ipv4.o
 obj-$(subst y,$(CONFIG_IP_DCCP),$(CONFIG_IPV6)) += dccp_ipv6.o
 dccp_ipv6-y := ipv6.o
 
-dccp-$(CONFIG_IP_DCCP_ACKVEC) += ackvec.o
-
 obj-$(CONFIG_INET_DCCP_DIAG) += dccp_diag.o
 obj-$(CONFIG_NET_DCCPPROBE) += dccp_probe.o
 
diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index 1227594..96bfa1f 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -1,44 +1,21 @@
 menu "DCCP CCIDs Configuration (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 
-config IP_DCCP_CCID2
-	tristate "CCID2 (TCP-Like) (EXPERIMENTAL)"
-	def_tristate IP_DCCP
-	select IP_DCCP_ACKVEC
-	---help---
-	  CCID 2, TCP-like Congestion Control, denotes Additive Increase,
-	  Multiplicative Decrease (AIMD) congestion control with behavior
-	  modelled directly on TCP, including congestion window, slow start,
-	  timeouts, and so forth [RFC 2581].  CCID 2 achieves maximum
-	  bandwidth over the long term, consistent with the use of end-to-end
-	  congestion control, but halves its congestion window in response to
-	  each congestion event.  This leads to the abrupt rate changes
-	  typical of TCP.  Applications should use CCID 2 if they prefer
-	  maximum bandwidth utilization to steadiness of rate.  This is often
-	  the case for applications that are not playing their data directly
-	  to the user.  For example, a hypothetical application that
-	  transferred files over DCCP, using application-level retransmissions
-	  for lost packets, would prefer CCID 2 to CCID 3.  On-line games may
-	  also prefer CCID 2.  See RFC 4341 for further details.
-
-	  CCID2 is the default CCID used by DCCP.
-
 config IP_DCCP_CCID2_DEBUG
 	  bool "CCID2 debugging messages"
-	  depends on IP_DCCP_CCID2
+	  depends on IP_DCCP
 	  ---help---
 	    Enable CCID2-specific debugging messages.
 
-	    When compiling CCID2 as a module, this debugging output can
+	    When compiling DCCP as a module, this debugging output can
 	    additionally be toggled by setting the ccid2_debug module
 	    parameter to 0 or 1.
 
 	    If in doubt, say N.
 
 config IP_DCCP_CCID3
-	tristate "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
-	def_tristate IP_DCCP
-	select IP_DCCP_TFRC_LIB
+	bool "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
+	def_bool y if (IP_DCCP = y || IP_DCCP = m)
 	---help---
 	  CCID 3 denotes TCP-Friendly Rate Control (TFRC), an equation-based
 	  rate-controlled congestion control mechanism.  TFRC is designed to
@@ -59,10 +36,7 @@ config IP_DCCP_CCID3
 	  This text was extracted from RFC 4340 (sec. 10.2),
 	  http://www.ietf.org/rfc/rfc4340.txt
 	  
-	  To compile this CCID as a module, choose M here: the module will be
-	  called dccp_ccid3.
-
-	  If in doubt, say M.
+	  If in doubt, say N.
 
 config IP_DCCP_CCID3_DEBUG
 	  bool "CCID3 debugging messages"
@@ -107,13 +81,8 @@ config IP_DCCP_CCID3_RTO
 	    is serious network congestion: experimenting with larger values should
 	    therefore not be performed on WANs.
 
-config IP_DCCP_TFRC_LIB
-	tristate
-	default n
-
 config IP_DCCP_TFRC_DEBUG
 	bool
-	depends on IP_DCCP_TFRC_LIB
 	default y if IP_DCCP_CCID3_DEBUG
 
 endmenu
diff --git a/net/dccp/ccids/Makefile b/net/dccp/ccids/Makefile
index 438f20b..4d4b1da 100644
--- a/net/dccp/ccids/Makefile
+++ b/net/dccp/ccids/Makefile
@@ -1,9 +1,4 @@
-obj-$(CONFIG_IP_DCCP_CCID3) += dccp_ccid3.o
-
-dccp_ccid3-y := ccid3.o
-
-obj-$(CONFIG_IP_DCCP_CCID2) += dccp_ccid2.o
-
-dccp_ccid2-y := ccid2.o
-
 obj-y += lib/
+
+dccp-y += ccid2.o
+dccp-$(CONFIG_IP_DCCP_CCID3) += ccid3.o
diff --git a/net/dccp/ccids/lib/Makefile b/net/dccp/ccids/lib/Makefile
index 68c93e3..95ad0d9 100644
--- a/net/dccp/ccids/lib/Makefile
+++ b/net/dccp/ccids/lib/Makefile
@@ -1,3 +1 @@
-obj-$(CONFIG_IP_DCCP_TFRC_LIB) += dccp_tfrc_lib.o
-
-dccp_tfrc_lib-y := tfrc.o tfrc_equation.o packet_history.o loss_interval.o
+dccp-$(CONFIG_IP_DCCP_CCID3) += tfrc.o tfrc_equation.o packet_history.o loss_interval.o
