From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 22:50:45 +0000
Subject: Re: [PATCH 5/11]: Update insertion routine for feature-negotiation options
Message-Id: <5640c7e00710011550i1340ac4br6073d90dc6c4aa20@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.21775@strip-the-willow>
In-Reply-To: <200710011518.21775@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Update insertion routine for feature-negotiation options
>
> The patch extends existing code:
>  * Confirm options divide into the confirmed value plus an optional preference
>    list for SP values. Previously only the preference list was echoed for SP values,
>    now the confirmed value is added as per RFC 4340, 6.1;
>  * length and sanity checks are added to avoid illegal memory (or NULL) access;
>  * clarified the use of TLV length constant, which does not have anything to do with ECN, but
>    with the fact that Type-Length-Value options whose length is determined by an u8
>    field provide Value space for at most 255 - 2 = 253 bytes due to the Type/Length fields.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
(once one change is put in)

> ---
>  net/dccp/ackvec.c  |    8 ++++----
>  net/dccp/ackvec.h  |    6 +++---
>  net/dccp/feat.h    |    1 +
>  net/dccp/options.c |   39 +++++++++++++++++++++++++++++++--------
>  4 files changed, 39 insertions(+), 15 deletions(-)
>
> --- a/net/dccp/feat.h
> +++ b/net/dccp/feat.h
> @@ -124,4 +124,5 @@ extern void dccp_encode_value_var(const
>  extern u64  dccp_decode_value_var(const u8 *bf, const u8 len);
>
>  extern int  dccp_insert_option_mandatory(struct sk_buff *skb);
> +extern int  dccp_insert_fn_opt(struct sk_buff *skb, u8, u8, u8 *, u8, bool);

declarations in kernel should always have parameter names.
