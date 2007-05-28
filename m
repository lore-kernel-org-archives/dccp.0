From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Mon, 28 May 2007 19:49:56 +0000
Subject: Re: [PATCH 1/5] DCCP: Shift ccid3_li_hist
Message-Id: <39e6f6c70705281249x2e98f75cj1c8725c55bcdf92d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200705112236.36406.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200705112236.36406.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 5/11/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> This shifts ccid3_li_hist.
>
> We temporarily export the symbol but remove this in later patch.
>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Ian,

       Finally looking at this, sorry for taking so long. But I have
some issues with this loss intervals code reshuflling.

       The idea of having dccp_tfrc_lib.ko is to have things that are
not  specific to any CCID implementation, so that if some new CCID
uses the TFRC algorithms it would share code with CCID3, etc.

       So it is not really correct for the code in net/dccp/ccids/lib/
to access the half connection internal state, as it really don't know
what is the layout of such internal state.

     In your patches you move ccid3_hc_rx_update_li from
net/dccp/ccids/ccid3.c to net/dccp/ccids/lib/loss_interval.c and then
renamed it to dccp_li_update_li, but this function still uses
ccid3_hc_rx_sk, not good.

     So I'm looking at the intent of the patches and will post here
how I think it should have been done and the sequence of patches
preparing for such change, etc.

- Arnaldo
