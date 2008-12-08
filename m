From: David Miller <davem@davemloft.net>
Date: Mon, 08 Dec 2008 09:18:43 +0000
Subject: Re: [PATCH 6/7] dccp: Remove manual influence on NDP Count feature
Message-Id: <20081208.011843.06192839.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1228581657-6724-7-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1228581657-6724-7-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  6 Dec 2008 17:40:56 +0100

> Updating the NDP count feature is handled automatically now:
>  * for CCID-2 it is disabled, since the code does not use NDP counts;
>  * for CCID-3 it is enabled, as NDP counts are used to determine loss lengths.
> 
> Allowing the user to change NDP values leads to unpredictable and failing
> behaviour, since it is then possible to disable NDP counts even when they
> are needed (e.g. in CCID-3).
> 
> This means that only those user settings are sensible that agree with the
> values for Send NDP Count implied by the choice of CCID. But those settings
> are already activated by the feature negotiation (CCID dependency tracking),
> hence this form of support is redundant.
> 
> At startup the initialisation of the NDP count feature uses the default
> value of 0, which is done implicitly by the zeroing-out of the socket when
> it is allocated. If the choice of CCID or feature negotiation enables NDP
> count, this will then be updated via the NDP activation handler.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
