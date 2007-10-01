From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 03:32:33 +0000
Subject: Re: [PATCH 11/11]: Disable setting timers for feature negotiation
Message-Id: <5640c7e00709302032k5aeb21dcmaffce36225c9bd98@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Disable setting timers for feature negotiation
>
> As a byproduct of restricting feature negotiation to connection setup, the feature-negotiation
> retransmit timer is no longer required. All retransmission is now mapped onto the protocol-level
> retransmission. To avoid interactions with the old code, this patch removes timer handling already.
>
> Implementation details indicating why timers are no longer needed can be found on
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/implementation_notes.html
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
