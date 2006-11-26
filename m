From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 26 Nov 2006 20:59:51 +0000
Subject: Re: [PATCH 7/10]: Avoid `division by zero' errors
Message-Id: <5640c7e00611261259q1cb12f24lb056f9ac604f56c1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611241619.56426@strip-the-willow>
In-Reply-To: <200611241619.56426@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/25/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Avoid `division by zero' errors
>
> Several places of the code divide by the current RTT value. A division-by-zero
> error results if this value is 0.
> To protect against this,
>    * DCCP_BUG_ON conditions are added throughout the tx code;

I can't remember what the definition of DCCP_BUG_ON was in the end.

If it does follow the BUG path then I would like this changed to
DCCP_WARN... so that we don't kill the machine.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
