From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 29 Jul 2008 18:54:48 +0000
Subject: Re: [PATCH 2/7] dccp ccid-3: Simplified handling of TX states
Message-Id: <5640c7e00807291154q56b2d1f0q49b7903f998f86ed@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1217268843-19667-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1217268843-19667-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Jul 29, 2008 at 6:13 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Since CCIDs are only used during the established phase of a connection,
> they have very little internal state; this specifically reduces to:
>
>  * "no packet sent" if and only if s = 0, for the TX packet size s;
>
>  * when the first packet has been sent (i.e. `s' > 0), the question is whether
>   or not feedback has been received:
>   - if a feedback packet is received, "feedback = yes" is set,
>   - if the nofeedback timer expires,  "feedback = no"  is set.
>
> Thus the CCID only needs to remember state about whether or not feedback
> has been received. This is now implemented using a boolean flag, which is
> toggled when a feedback packet arrives or the nofeedback timer expires.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
