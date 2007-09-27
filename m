From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 27 Sep 2007 08:08:00 +0000
Subject: Re: tcpdump broken wrt CsCov & CsVal parsing?
Message-Id: <200709270908.00165@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070922144111.GE10051@ghostprotocols.net>
In-Reply-To: <20070922144111.GE10051@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  I checked locally:
|  > =A0* tcpdump 3.9.5 as Debian package with libpcap 0.9.5 has this swap-=
problem=20
|  > =A0* tcpdump 3.9.5 built from tcpdump source, with libpcap 0.9.4 works=
 correct
|  >=20
|  > Can you try tcpdump from source please and check if the problem persis=
ts?
| =20
|  Excellent data point, I should know better and try with upstream before
|  complaining. Ah, and also provide the tcpdump version:
| =20
|  [root@tonchinha ~]# rpm -q tcpdump
|  tcpdump-3.9.7-3.fc8
Have you looked at the source rpm's? I found the old patch, if the followin=
g hunk
applies then quite likely they have forgotten to patch the header file, and=
 the
problem could be solved then (CCval and Cscov were swapped):

--- a/dccp.h
+++ b/dccp.h
@@ -36,8 +36,8 @@ struct dccp_hdr {
 	}		dccph_xtrs;
 };
=20
-#define DCCPH_CCVAL(dh)	(((dh)->dccph_ccval_cscov) & 0x0F)
-#define DCCPH_CSCOV(dh)	(((dh)->dccph_ccval_cscov >> 4) & 0x0F)
+#define DCCPH_CCVAL(dh)	(((dh)->dccph_ccval_cscov >> 4) & 0xF)
+#define DCCPH_CSCOV(dh)	(((dh)->dccph_ccval_cscov) & 0xF)
=20
 #define DCCPH_X(dh)	((dh)->dccph_xtrs.dccph_xtr & 1)
 #define DCCPH_TYPE(dh)	(((dh)->dccph_xtrs.dccph_xtr >> 1) & 0xF)



