From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 18 Mar 2011 11:33:03 +0000
Subject: Re: dccp test-tree [RFC] [Patch 2/2] dccp: CCID2 check ack ratio
Message-Id: <20110318113303.GB5508@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1300164797.20638.65.camel@jero-laptop>
In-Reply-To: <1300164797.20638.65.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| This patch causes CCID2 to check the ack ratio after reducing the
| congestion window.
Thanks a lot, it has been integrated with the other changes:
  http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcom=
mitdiff;h=F7bcfc7ddf5c1f61c861c3d2b475df7874833ed3
