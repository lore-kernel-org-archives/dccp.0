From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 21:02:30 +0000
Subject: Re: [PATCH 8/14]: Remove manual influence on NDP Count feature
Message-Id: <5640c7e00710031402m5765b349qe6bcdfaaa68dc964@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.45403@strip-the-willow>
In-Reply-To: <200710031502.45403@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Remove manual influence on NDP Count feature
>
> The NDP count feature is handled automatically now by the feature negotiation code:
>  * for CCID2 it is disabled, since the code does not use or even refer to NDP counts;
>  * for CCID3 it is enabled, since NDP counts are used to determine loss lengths (RFC 4342, 6.1).
>
> Allowing the user to change these values leads to unpredictable and failing behaviour, since it
> is then possible to disable NDP counts even when they are needed (e.g. in CCID3). This means that
> only those user settings are sensible that agree with the values for Send NDP Count implied by the
> choice of CCID. But those settings are already activated by the feature negotiation (CCID dependency
> tracking), which means that the user settings are redundant.
>
> I thus think that it is the best choice to remove this sysctl. Leaving it in brings no
> advantages, but opens a door to creating non-operable conditions.
>
> At startup the initialisation of the NDP count feature is with the default value of 0, which is
> done implicitly by the zeroing-out of the socket when it is allocated. If the choice of CCID or
> feature negotiation enables NDP count, this will then be updated via the NDP activation handler.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
