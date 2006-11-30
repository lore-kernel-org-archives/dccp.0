From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 30 Nov 2006 22:11:20 +0000
Subject: Re: [DCCP]: Fix BUG in send time calculation
Message-Id: <5640c7e00611301411t234b759fi879646d3777aa1a1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611301541.36467@strip-the-willow>
In-Reply-To: <200611301541.36467@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/1/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> ------------> Commit Message <---------------------------------
> [DCCP]: Fix BUG in retransmission delay calculation
>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

I can confirm this fixes the problem in this case. Performance still
sucks but this fixes one aspect - tested by reverting to my code in
this and comparing. See message to follow.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
