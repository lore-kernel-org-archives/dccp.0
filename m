From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Mon, 22 Feb 2010 07:00:31 +0000
Subject: Re: dccp-test-tree [Patch 1/1] "UDP-like" CCID sample kernel module
Message-Id: <cb00fa211002212300r2460471ub0932eb3e6c40c05@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20100215060928.GA5350@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20100215060928.GA5350@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Mon, Feb 15, 2010 at 03:09, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This patch is for the dccp test tree at
> =A0git://eden-feed.erg.abdn.ac.uk/dccp_exp [subtree 'dccp']
>
> The actual 'module' is only 5 lines long.
>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<=
<<<
> dccp: sample kernel module, NULL-CCID ("UDP-like")
>
> This implements an experimental CCID which does not do any congestion con=
trol,
> i.e. "UDP-like".
>
> This is an experimental CCID. It is not meant for actual deployment, but
> rather as sample kernel code, providing a worked example of how to add a
> new CCID module.
>
> Since CCID-0 is reserved (RFC 4340, table 5), this experimental NULL CCID=
 uses
> the first available experimental CCID, CCID-248 (RFC 4340, 19.5).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
> =A0include/linux/dccp.h =A0 | =A0 =A07 +++++++
> =A0net/dccp/Makefile =A0 =A0 =A0| =A0 =A01 +
> =A0net/dccp/ccid.c =A0 =A0 =A0 =A0| =A0 =A03 +++
> =A0net/dccp/ccid.h =A0 =A0 =A0 =A0| =A0 =A03 +++
> =A0net/dccp/ccids/Kconfig | =A0 12 ++++++++++++
> =A0net/dccp/ccids/ccid0.c | =A0 27 +++++++++++++++++++++++++++
> =A0net/dccp/feat.c =A0 =A0 =A0 =A0| =A0 17 ++++++++++++++++-
> =A07 files changed, 69 insertions(+), 1 deletion(-)
>
> --- a/include/linux/dccp.h
> +++ b/include/linux/dccp.h
> @@ -177,6 +177,13 @@ enum {
> =A0enum {
> =A0 =A0 =A0 =A0DCCPC_CCID2 =3D 2,
> =A0 =A0 =A0 =A0DCCPC_CCID3 =3D 3,
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* CCIDs 248-255 below are permanently reserved for
> + =A0 =A0 =A0 =A0* experimental and testing use (RFC 4340, 19.5).
> + =A0 =A0 =A0 =A0*/
> +#define DCCPC_TESTING_MIN =A0 =A0 =A0248
> +#define DCCPC_TESTING_MAX =A0 =A0 =A0255
> + =A0 =A0 =A0 DCCPC_CCID_ZERO =3D DCCPC_TESTING_MIN,
> =A0};
>
> =A0/* DCCP features (RFC 4340 section 6.4) */
> --- /dev/null
> +++ b/net/dccp/ccids/ccid0.c
> @@ -0,0 +1,27 @@
> +/*
> + * =A0CCID-ZERO - UDP-like congestion control
> + *
> + * =A0This is a sample kernel module, used for testing and development, =
but not
> + * =A0for actual deployment. The CCID number is taken from the range of =
CCIDs
> + * =A0set apart for testing and experimenting.
> + *
> + * =A0This program is free software; you can redistribute it and/or modi=
fy
> + * =A0it under the terms of the GNU General Public License as published =
by
> + * =A0the Free Software Foundation; either version 2 of the License, or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See the
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public License
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +#include "../ccid.h"
> +
> +struct ccid_operations ccid0_ops =3D {
> + =A0 =A0 =A0 .ccid_id =A0 =A0 =A0 =A0=3D DCCPC_CCID_ZERO,
> + =A0 =A0 =A0 .ccid_name =A0 =A0 =A0=3D "UDP-like transport"
> +};
> --- a/net/dccp/ccid.c
> +++ b/net/dccp/ccid.c
> @@ -19,6 +19,9 @@ static struct ccid_operations *ccids[] > =A0#ifdef CONF=
IG_IP_DCCP_CCID3
> =A0 =A0 =A0 =A0&ccid3_ops,
> =A0#endif
> +#ifdef CONFIG_IP_DCCP_CCID0
> + =A0 =A0 =A0 &ccid0_ops,
> +#endif
> =A0};
>
> =A0static struct ccid_operations *ccid_by_number(const u8 id)
> --- a/net/dccp/ccid.h
> +++ b/net/dccp/ccid.h
> @@ -91,6 +91,9 @@ struct ccid_operations {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 int __user *optlen);
> =A0};
>
> +#ifdef CONFIG_IP_DCCP_CCID0
> +extern struct ccid_operations ccid0_ops;
> +#endif
> =A0extern struct ccid_operations ccid2_ops;
> =A0#ifdef CONFIG_IP_DCCP_CCID3
> =A0extern struct ccid_operations ccid3_ops;
> --- a/net/dccp/feat.c
> +++ b/net/dccp/feat.c
> @@ -620,7 +620,8 @@ static u8 dccp_feat_is_valid_sp_val(u8 f
> =A0{
> =A0 =A0 =A0 =A0switch (feat_num) {
> =A0 =A0 =A0 =A0case DCCPF_CCID:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return val =3D DCCPC_CCID2 || val =3D DCCPC=
_CCID3;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =A0val =3D DCCPC_CCID2 || val =3D DC=
CPC_CCID3 ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (val >=3D DCCPC_TESTING_MIN=
 && val <=3D DCCPC_TESTING_MAX);
> =A0 =A0 =A0 =A0/* Type-check Boolean feature values: */
> =A0 =A0 =A0 =A0case DCCPF_SHORT_SEQNOS:
> =A0 =A0 =A0 =A0case DCCPF_ECN_INCAPABLE:
> @@ -831,6 +832,18 @@ EXPORT_SYMBOL_GPL(dccp_feat_signal_nn_ch
> =A0*/
> =A0static const struct ccid_dependency *dccp_feat_ccid_deps(u8 ccid, bool=
 is_local)
> =A0{
> + =A0 =A0 =A0 static const struct ccid_dependency ccid0_dependencies[2][2=
] =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The UDP-like CCID does not have specia=
l dependencies, but for
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* testing dependencies (e.g. Ack Vectors=
) can be defined below.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 { 0, 0, 0, 0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 { 0, 0, 0, 0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 };
> =A0 =A0 =A0 =A0static const struct ccid_dependency ccid2_dependencies[2][=
2] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * CCID2 mandates Ack Vectors (RFC 4341, 4=
.): as CCID is a TX
> @@ -916,6 +929,8 @@ static const struct ccid_dependency *dcc
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0switch (ccid) {
> + =A0 =A0 =A0 case DCCPC_CCID_ZERO:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ccid0_dependencies[is_local];
> =A0 =A0 =A0 =A0case DCCPC_CCID2:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ccid2_dependencies[is_local];
> =A0 =A0 =A0 =A0case DCCPC_CCID3:
> --- a/net/dccp/ccids/Kconfig
> +++ b/net/dccp/ccids/Kconfig
> @@ -103,4 +103,16 @@ config IP_DCCP_TFRC_LIB
>
> =A0config IP_DCCP_TFRC_DEBUG
> =A0 =A0 =A0 =A0def_bool y if IP_DCCP_CCID3_DEBUG
> +
> +config IP_DCCP_CCID0
> + =A0 =A0 =A0 bool "CCID-ZERO (UDP-Like) sample kernel module"
> + =A0 =A0 =A0 def_bool n
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 This is a sample kernel module to illustrate the integr=
ation of new
> + =A0 =A0 =A0 =A0 CCID kernel modules into CCID. It can also be used for =
performance
> + =A0 =A0 =A0 =A0 testing, but is not meant for deployment since it opera=
tes without
> + =A0 =A0 =A0 =A0 any congestion control. It is a NULL CCID, its identifi=
er is 248.
> +
> + =A0 =A0 =A0 =A0 Say N.
> +
> =A0endmenu
> --- a/net/dccp/Makefile
> +++ b/net/dccp/Makefile
> @@ -7,6 +7,7 @@ dccp-y :=3D ccid.o feat.o input.o minisock
> =A0#
> =A0# CCID-2 is default (RFC 4340, p. 77) and has Ack Vectors as dependency
> =A0dccp-y +=3D ccids/ccid2.o ackvec.o
> +dccp-$(CONFIG_IP_DCCP_CCID0) =A0 +=3D ccids/ccid0.o
> =A0dccp-$(CONFIG_IP_DCCP_CCID3) =A0 +=3D ccids/ccid3.o
> =A0dccp-$(CONFIG_IP_DCCP_TFRC_LIB) +=3D ccids/lib/tfrc.o =A0 =A0 =A0 =A0 =
=A0 =A0\
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ccids=
/lib/tfrc_equation.o =A0 =A0\
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>


Acked-by: Ivo Calado <ivocalado@embedded.ufcg.edu.br>  for ccid4 subtree
