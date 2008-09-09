From: David Miller <davem@davemloft.net>
Date: Tue, 09 Sep 2008 00:32:50 +0000
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
Message-Id: <20080908.173250.204419507.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 4 Sep 2008 08:15:11 +0200

> This is an update with regard to Wei's comments. I have re-synched=20
>=20
> 	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[subtree `dccp']
> 	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dsh=
ortlog;h=DCcp
>=20
> Also did some testing with a client that only supports CCID 2/3 talking t=
o a client supporting
> CCID 2/3/4. They could still negotiate and settle for a common CCID.

I pulled and resolved all of the conflicts, but this build warning I'm
now getting from ccid3.h has got to go:

/*
 * The t_delta parameter (RFC 3448, 4.6): delays of less than %USEC_PER_MSE=
C are
 * rounded down to 0, since sk_reset_timer() here uses millisecond granular=
ity.
 * Hence we can use a constant t_delta =3D %USEC_PER_MSEC when HZ >=3D 500.=
 A coarse
 * resolution of HZ < 500 means that the error is below one timer tick (t_g=
ran)
 * when using the constant t_delta  =3D  t_gran / 2  =3D  %USEC_PER_SEC / (=
2 * HZ).
 */
#if (HZ >=3D 500)
# define TFRC_T_DELTA		   USEC_PER_MSEC
#else
# define TFRC_T_DELTA		   (USEC_PER_SEC / (2 * HZ))
#warning Coarse CONFIG_HZ resolution -- higher value recommended for TFRC.
#endif

Don't warn about crap like this, instead convert the code over to hrtimers.

This kernel being built, even with HZ=100, can do nanosecond timers on
my systems, but that's only if you would make proper use of them.
