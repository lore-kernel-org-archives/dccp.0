From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 22:02:28 +0000
Subject: Re: [PATCH 11/14]: Auto-load (when supported) CCID plugins for negotiation
Message-Id: <5640c7e00710031502j31be81bdj42e8c7d408167612@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.51979@strip-the-willow>
In-Reply-To: <200710031502.51979@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Auto-load (when supported) CCID plugins for negotiation
>
> This adds auto-loading of CCIDs (when module loading is enabled)
> for the purpose of feature negotiation.
>
> It is done in dccp_feat_init(), which is in process context.
>
> The problem with loading the CCIDs at the end of feature negotiation is
> that then this would be in software interrupt context. Besides, if the host
> advertises CCIDs during negotiation, it should have them available in case
> the peer agrees with one of the advertised CCIDs.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
