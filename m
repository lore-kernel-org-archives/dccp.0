From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 18:43:03 +0000
Subject: Re: [PATCH 5/9]: Glue function to support sockopt code
Message-Id: <5640c7e00710011143g2f96da5bm441a7c890b4b3f99@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/29/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Glue function to support sockopt code
>
> This adds a glue function so that change requests can still be made via setsockopt
> calls. This is useful for testing and maybe even from an API point of view.
>
> The test whether the socket is not already connected is made deeper in the function
> call hierarchy - when dccp_feat_register_change is called. This is on purpose, since
> it enables to write further functions on top of the latter function without having
> to test for this condition in each calling function.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
