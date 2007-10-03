From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 22:20:08 +0000
Subject: Re: [PATCH 14/14]: Debugging Feature Negotiation
Message-Id: <5640c7e00710031520l3dc27f22pb7a5af9a9beaec7a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.59142@strip-the-willow>
In-Reply-To: <200710031502.59142@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Debugging Feature Negotiation
>
> Since all feature-negotiation processing now takes place in feat.c, functions for producing
> verbose debugging output can be concentrated there. A number of functions to print out values,
> entry records, and options are provided.
>
> A new macro was defined to not always have the function name in the output line. I have refrained
> from naming it dccp_pr_debug_dog ...
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
