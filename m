From: gerrit@erg.abdn.ac.uk
Date: Wed, 13 Aug 2008 15:04:03 +0000
Subject: Re: [PATCH] dccp: change L/R must have at least one byte in the
Message-Id: <44269.148.187.160.35.1218639843.squirrel@148.187.160.35>
List-Id: <dccp.vger.kernel.org>
References: <20080813125532.GD12888@ghostprotocols.net>
In-Reply-To: <20080813125532.GD12888@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

> dccp: change L/R must have at least one byte in the dccpsf_val field
>
> Thanks to Eugene Teo for reporting this problem.
>
> Signed-off-by: Eugene Teo <eugenete@kernel.sg>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Dave, can you please apply -- this patch is for mainline only.

The dccp_setsockopt_change() function has been fully removed in the
test tree (
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcommi=
tdiff;h=F1b8d02c7cb03e22037e1590d04f9ec8ab2423eb),
due to problems it caused.

Will be in contact regarding this soon.

Gerrit



