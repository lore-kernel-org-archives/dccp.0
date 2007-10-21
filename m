From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 21 Oct 2007 01:32:49 +0000
Subject: Re: [PATCH 8/8]: Initialisation assignments of 0 are redundant
Message-Id: <5640c7e00710201832v3a26ff54xb2137d867c1b6824@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/9/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID3]: Initialisation assignments of 0 are redundant
>
> Assigning initial values of `0' is redundant when loading a new CCID structure,
> since in net/dccp/ccid.c the entire CCID structure is zeroed out prior to
> initialisation in ccid_new():
>
>         struct ccid {
>                 struct ccid_operations *ccid_ops;
>                 char                   ccid_priv[0];
>         };
>
>         // ...
>         if (rx) {
>                 memset(ccid + 1, 0, ccid_ops->ccid_hc_rx_obj_size);
>                 if (ccid->ccid_ops->ccid_hc_rx_init != NULL &&
>                     ccid->ccid_ops->ccid_hc_rx_init(ccid, sk) != 0)
>                         goto out_free_ccid;
>         } else {
>                 memset(ccid + 1, 0, ccid_ops->ccid_hc_tx_obj_size);
>                 /* analogous to the rx case */
>         }
>
> This patch therefore removes the redundant assignments. Thanks to Arnaldo for
> the inspiration.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
