From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 18:46:40 +0000
Subject: Re: [PATCH 7/9]: Tidy up setsockopt calls
Message-Id: <5640c7e00710011146v4cb79f54n193a96b437c4bac7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/29/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Tidy up setsockopt calls
>
> This splits the setsockopt calls into two groups, depending on whether an integer
> argument (val) is required and whether routines being called do their own locking.
>
> Some options (such as setting the CCID) use u8 rather than int, so that for these
> the test with regard to integer-sizeof can not be used.
>
> The second switch-case statement now only has those statements which need locking
> and which make use of val.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Nice to see reduced locking in some cases.

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
