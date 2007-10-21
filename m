From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 21 Oct 2007 01:29:20 +0000
Subject: Re: [PATCH 2/6]: Provide fallback RTT value when none is available
Message-Id: <5640c7e00710201829m1503d3a9la2c5936726651b6b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091958.08037@strip-the-willow>
In-Reply-To: <200706091958.08037@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/10/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Provide fallback RTT value when none is available
>
> This implements RFC 4340, section 3.4:
>
>  "Each DCCP implementation thus defines a default round-trip time
>   for use when no estimate is  available.  This parameter should
>   default to not less than 0.2 seconds [...]."
>
> In addition, the upper bound of 4 seconds for an RTT sample has now been reduced,
> to 3 seconds: to match the initial TCP RTO value as specified in [RFC 1122, 4.2.3.1].
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

I signed off on this on June 16th but this seems to have got lost so:

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
