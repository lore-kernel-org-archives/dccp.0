From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 20 Sep 2007 12:37:46 +0000
Subject: Re: [PATCH 1/5] CCID 4: Adds Kconfig, Makefile, and new CCID to include/linux/dccp.h
Message-Id: <200709201337.46933@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070920112021.GB1288@kikai.katei.fi>
In-Reply-To: <20070920112021.GB1288@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  +# The TFRC-SP Library: currently only has CCID 4 as customer
|  +config IP_DCCP_TFRC_SP_LIB
|  +=A0=A0=A0=A0=A0=A0=A0depends on IP_DCCP_CCID4
|  +=A0=A0=A0=A0=A0=A0=A0def_tristate IP_DCCP_CCID4
|  +
|  +config IP_DCCP_TFRC_SP_DEBUG
|  +=A0=A0=A0=A0=A0=A0=A0bool
|  +=A0=A0=A0=A0=A0=A0=A0default y if IP_DCCP_CCID4_DEBUG
|  +
You can delete these lines - they are already enabled through CCID3 configu=
ration option,
or integrate (OR) with the CCID3 dependencies. Since there are dependencies=
 to CCID3,
it may be useful to replace the above by adding=20
	select IP_DCCP_CCID3=20
to the menu of IP_DCCP_CCID4
