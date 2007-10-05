From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 05 Oct 2007 06:44:09 +0000
Subject: Re: [PATCH 3/5]: Support exchange of NN options in (PART)OPEN state
Message-Id: <5640c7e00710042344q156c5890h47cb1202eec3558d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710041501.56582@strip-the-willow>
In-Reply-To: <200710041501.56582@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/5/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Support exchange of NN options in (PART)OPEN state
>
> This patch supports reception of NN options in established state. It is a combination
> of change_recv() and confirm_recv(), specifically geared towards receiving `fast-path'
> NN options. Such options are only accepted in OPEN/PARTOPEN state, and an additional
> test currently limits the use to Ack Ratio (the routine can be used for any NN options,
> but there is currently no use for that).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
