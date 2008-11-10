From: David Miller <davem@davemloft.net>
Date: Mon, 10 Nov 2008 21:16:45 +0000
Subject: Re: [PATCH 3/4] dccp: Query supported CCIDs
Message-Id: <20081110.131645.149021023.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1225950014-6337-4-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1225950014-6337-4-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu,  6 Nov 2008 06:40:13 +0100

> This provides a data structure to record which CCIDs are locally supported
> and three accessor functions:
>  - a test function for internal use which is used to validate CCID requests
>    made by the user;
>  - a copy function so that the list can be used for feature-negotiation;
>  - documented getsockopt() support so that the user can query capabilities.
> 
> The data structure is a table which is filled in at compile-time with the
> list of available CCIDs (which in turn depends on the Kconfig choices).
> 
> Using the copy function for cloning the list of supported CCIDs is useful for
> feature negotiation, since the negotiation is now with the full list of available
> CCIDs (e.g. {2, 3}) instead of the default value {2}. This means negotiation
> will not fail if the peer requests to use CCID3 instead of CCID2.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
