From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 22 Sep 2007 20:24:53 +0000
Subject: Re: [PATCH 1/4] CCID4: Provides improvements/organization to the initial entries for CCID 4 and net/
Message-Id: <5640c7e00709221324p6328106bi9d07016033d91714@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709201053h6fbdaea6u72cc406675020715@mail.gmail.com>
In-Reply-To: <5bc4c4570709201053h6fbdaea6u72cc406675020715@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/21/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
> Signed-off-by: Leandro Sales <leandro@embedded.ufcg.edu.br>
>
> Organize the help for ccid-4 menu with a more apropriate description,
> the correct
> URL for CCID-4 draft and remove the code duplication for TFRC by using
> "depends on CCID3 || CCID4" in the IP_DCCP_TFRC_LIB config.
>

Leandro,

We were talking in chat about when to patch a patch. I think in this
case it is better to resubmit as a new patch as for new code like
this, that hasn't gone upstream, other people don't care about our 1
or 2 or 10 attempts to get it right.

How about that for next version of this? (My comments on older version
still apply to this so you will need to resubmit).

Ian

PS I'm not trying to be negative. You and Tommi are doing a great job
and I'm just trying to share from some of the mistakes I made as well
in the past.
