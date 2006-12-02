From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 02 Dec 2006 18:37:05 +0000
Subject: Re: [PATCH 5/8]: Add protection against invalid parameters
Message-Id: <5640c7e00612021037vd200247tc586f895df6497ba@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612011827.01580@strip-the-willow>
In-Reply-To: <200612011827.01580@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/3/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Ian McDonald:
> I thought about this too and initially both were DCCP_BUG_ON(). However,
> this just delays the Kerboom! -- as I have had to learn painfully:
>         * case `p > 1000000' leads to accessing illegal memory - kernel panics
>         * case `p = 0' leads to division by zero
>
> I have had one kernel Oops because of not making them DCCP_BUG_ON. The good
> side of using this is safety: if this condition is met, we will know from console
> output, and we will also know that there is serious trouble somewhere else.
>
I definitely want these things to go to the console/logs. I think
DCCP_BUG_ON does do this - how to stop the divide by zero is then to
return from the function at that point so next statement can't get
executed. It doesn't ever halt the system though which is good. The
reason I say this is good as in the back of my mind I am thinking of
people looking for DoS vulnerabilities...

However BUG_ON does work and forces the code to get tidied so the
condition doesn't occur again. So whichever way I'm happy to go ahead
with it.

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
