From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 18:46:40 +0000
Subject: Re: [PATCH 1/14]: Activation of features after negotiation
Message-Id: <5640c7e00710031146j1790145ao45a2e1128832c62@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.28594@strip-the-willow>
In-Reply-To: <200710031502.28594@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Activation of features after negotiation
>
> This patch provides the post-processing of feature negotiation state, after
> the negotiation has completed.
>
> To this purpose, handlers are used and added to the dccp_feat_table. Each handler
> is passed a boolean flag whether the RX or TX side of the feature is meant.
>
> Several handlers are provided already, new handlers can easily be added.
>
> The initialisation is now fully dynamic, i.e. CCIDs are activated only
> after the feature negotiation. The integration of this dynamic activation
> is done in the subsequent patches.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
