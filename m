From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 10 Jun 2006 08:28:39 +0000
Subject: Re: [PATCH 1/1] DCCP Ackvec: fix soft lockup in ackvec handling code
Message-Id: <5640c7e00606100128q72631543idb8f181feeb2a9c9@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_10520_4617327.1149928119560"
List-Id: <dccp.vger.kernel.org>
References: <20060609182649.GA20777@shorty.sorbonet.org>
In-Reply-To: <20060609182649.GA20777@shorty.sorbonet.org>
To: dccp@vger.kernel.org

------=_Part_10520_4617327.1149928119560
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Dave,

I have tested this and wonder whether it can be pushed upstream for
Linus for 2.6.17 if at all possible. I know Arnaldo is the maintainer
but as you are aware he is very busy with other projects at present.

This fix makes CCID2 usable - previously it was unusable for most
users. I had about five users report it as broken to me and this fixes
it for me. I am able to make it crash reproducibly without it and it
doesn't with the patch.

I've also put inline and attached (as gmail mailer mangles sometimes)
the patch redone against Linus' tree as Andrea's patch didn't apply
cleanly for me.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Thanks,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index b5981e5..8c211c5 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -452,6 +452,7 @@ #endif
 					      (unsigned long long)
 					      avr->dccpavr_ack_ackno);
 				dccp_ackvec_throw_record(av, avr);
+				break;
 			}
 			/*
 			 * If it wasn't received, continue scanning... we might


On 6/10/06, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> A soft lockup existed in the handling of ack vector records.  Specifically, when
> a tail of the list of ack vector records was removed, it was possible to end up
> iterating infinitely on an element of the tail.
>
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
>
> ---
>
> diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
> index 2349078..a856d72 100644
> --- a/net/dccp/ackvec.c
> +++ b/net/dccp/ackvec.c
> @@ -453,6 +453,7 @@ #endif
>                                               (unsigned long long)
>                                               avr->dccpavr_ack_ackno);
>                                 dccp_ackvec_throw_record(av, avr);
> +                               break;
>                         }
>                         /*
>                          * If it wasn't received, continue scanning... we might
> -

------=_Part_10520_4617327.1149928119560
Content-Type: text/x-patch; name=ackvecfix.diff; charset=ISO-8859-1
Content-Transfer-Encoding: base64
X-Attachment-Id: f_eo9pfcmf
Content-Disposition: attachment; filename="ackvecfix.diff"

ZGlmZiAtLWdpdCBhL25ldC9kY2NwL2Fja3ZlYy5jIGIvbmV0L2RjY3AvYWNrdmVjLmMKaW5kZXgg
YjU5ODFlNS4uOGMyMTFjNSAxMDA2NDQKLS0tIGEvbmV0L2RjY3AvYWNrdmVjLmMKKysrIGIvbmV0
L2RjY3AvYWNrdmVjLmMKQEAgLTQ1Miw2ICs0NTIsNyBAQCAjZW5kaWYKIAkJCQkJICAgICAgKHVu
c2lnbmVkIGxvbmcgbG9uZykKIAkJCQkJICAgICAgYXZyLT5kY2NwYXZyX2Fja19hY2tubyk7CiAJ
CQkJZGNjcF9hY2t2ZWNfdGhyb3dfcmVjb3JkKGF2LCBhdnIpOworCQkJCWJyZWFrOwogCQkJfQog
CQkJLyoKIAkJCSAqIElmIGl0IHdhc24ndCByZWNlaXZlZCwgY29udGludWUgc2Nhbm5pbmcuLi4g
d2UgbWlnaHQK
------=_Part_10520_4617327.1149928119560--
