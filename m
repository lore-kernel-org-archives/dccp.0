From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 23:08:12 +0000
Subject: Re: [PATCH 8/11]: Preference list reconciliation
Message-Id: <5640c7e00710011608j66b2aa9ay82b0c5e772f6070e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.29028@strip-the-willow>
In-Reply-To: <200710011518.29028@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Preference list reconciliation
>
> This provides two functions to
>  * reconcile preference lists (with appropriate return codes) and
>  * reorder the preference list if successful reconciliation changed the
>    preferred value.
>
> The patch also removes the old code for processing SP/NN Change options, since
> new code to process these is mostly there already; related references have been
> commented out.
> The code for processing Change options follows in the next patch.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
