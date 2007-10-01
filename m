From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 18:26:07 +0000
Subject: Re: [PATCH 2/9]: Query supported CCIDs
Message-Id: <5640c7e00710011126g750d2at274636362ab5f4ec@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709281630.17307@strip-the-willow>
In-Reply-To: <200709281630.17307@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/29/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Query supported CCIDs
>
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
> CCIDs (e.g. {2, 3}) instead of the default value {2}. This means negotiation will
> not fail if the peer requests to use CCID3 instead of CCID2.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
