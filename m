From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 04:37:54 +0000
Subject: Re: [PATCH 5/10]: Perform SHUT_RD and SHUT_WR on receiving close
Message-Id: <5640c7e00709052137sb40db3eof3039fc6ca88875d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Perform SHUT_RD and SHUT_WR on receiving close
>
> The first change is to close the write-end in addition to the read-end when
> a fin-like segment (Close or CloseReq) is received by DCCP. This accounts
> for the fact that DCCP, in contrast to TCP, does not have a half-close. I
> checked the specification - when a fin-like segment has been sent there is
> no guarantee at all that any further data will be processed.
>
> Thus this patch performs SHUT_WR in addition to the SHUT_RD when a fin-like
> segment is encountered.
>
> The second change is minor; I noted that code appears twice in different
> places and think it makes sense to put this into a self-contained function.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
