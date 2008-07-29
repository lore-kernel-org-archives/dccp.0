From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 29 Jul 2008 18:56:22 +0000
Subject: Re: [PATCH 3/7] dccp tfrc: Suppress unavoidable "below resolution" warning
Message-Id: <5640c7e00807291156m2af40714h5bbaa0e7677a6f44@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1217268843-19667-4-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1217268843-19667-4-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Jul 29, 2008 at 6:13 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> In the congestion-avoidance phase a decay of p towards 0 is natural once fewer
> losses are encountered. Hence the warning message "p is below resolution" is
> not necessary, and thus turned into a debug message by this patch.
>
> The TFRC_SMALLEST_P is needed since in theory p never actually reaches 0. When
> no further losses are encountered, the loss interval I_0 grows in length,
> causing p to decrease towards 0, causing X_calc = s/(RTT * f(p)) to increase.
>
> With the given minimum-resolution this congestion avoidance phase stops at some
> fixed value, an approximation formula has been added to the documentation.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
