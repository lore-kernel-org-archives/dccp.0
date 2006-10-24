From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 24 Oct 2006 23:11:13 +0000
Subject: Re: [PATCH 14/17] [DCCP]: Fix logfile overflow by Ian McDonald
Message-Id: <5640c7e00610241611j26a7f3cdyfbd44928c9986ce3@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200610241501.05986@strip-the-willow>
In-Reply-To: <200610241501.05986@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/25/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This bug-fix is a re-sent from today, the patch is by Ian McDonald
> and the original commit message is:
>
> This patch fixes data being spewed into the logs continually. As the code
> stood if there was a large queue and long delays timeo would go down to
> zero and never get reset.
>
> This fixes it by resetting timeo. Put constant into header as well.
>
> Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
> ------------------------------------------------------------------------------

Can you please keep in my signed off lines in my patches please?

Thanks,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
