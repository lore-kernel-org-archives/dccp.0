From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Dec 2010 09:44:18 +0000
Subject: Re: Sequence Number Validation Bug Fixes 2/2
Message-Id: <20101228094418.GB4831@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1293393024.22785.1.camel@jero-laptop>
In-Reply-To: <1293393024.22785.1.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Thanks a lot for looking into this.

I think the problem below is similar to or even covered by the bug fix
submitted on 23th November (it is in net-2.6 but may not yet be in mainline=
):

http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcommi=
tdiff;h
c78870220b6e0ac74dd9292bcfa7b18718babd

I will have a look at the other patches, but it maybe "next year" until
able to get back.


Quoting Samuel Jero:
| Currently dccp_check_seqno allows any valid packet to update the
| Greatest Sequence Number Received, even if that packet's sequence number
| is less than the current GSR. This patch adds a check to make sure that
| the new packet's sequence number is greater than GSR.
|=20
| >>>>>>>>>>>>>>>>>>>>>>>>>  Patch Follows <<<<<<<<<<<<<<<<<<<<<<<<<<
| diff --git a/net/dccp/input.c b/net/dccp/input.c
| --- a/net/dccp/input.c
| +++ b/net/dccp/input.c
| @@ -252,7 +253,10 @@ static int dccp_check_seqno(struct sock *sk, struct
| sk_buff *skb)
| if (between48(seqno, lswl, dp->dccps_swh) &&
|     (ackno =3D DCCP_PKT_WITHOUT_ACK_SEQ ||
|      between48(ackno, lawl, dp->dccps_awh))) {
| - dccp_update_gsr(sk, seqno);
| +
| + if(after48(seqno, dp->dccps_gsr)){
| + dccp_update_gsr(sk, seqno);
| + }
|=20
| if (dh->dccph_type !=3D DCCP_PKT_SYNC &&
|     ackno !=3D DCCP_PKT_WITHOUT_ACK_SEQ &&=20

