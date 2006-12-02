From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 02 Dec 2006 12:38:11 +0000
Subject: Re: [PATCH 5/8]: Add protection against invalid parameters
Message-Id: <200612021238.11692@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612011827.01580@strip-the-willow>
In-Reply-To: <200612011827.01580@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 12/2/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  
|  > [DCCP]: Add protection against invalid parameters to TFRC routines
|  >
|  > +       BUG_ON(p >  1000000);           /* p must not exceed 100%   */
|  > +       BUG_ON(p = 0);                 /* f(0) = 0, divide by zero */
|  
|  I know I put the original BUG_ONs in but can we change this to a
|  DCCP_BUG or a WARN - just to prevent the possible issues depending on
|  bottom half context...
I thought about this too and initially both were DCCP_BUG_ON(). However,
this just delays the Kerboom! -- as I have had to learn painfully:
	* case `p > 1000000' leads to accessing illegal memory - kernel panics
	* case `p = 0' leads to division by zero

I have had one kernel Oops because of not making them DCCP_BUG_ON. The good
side of using this is safety: if this condition is met, we will know from console
output, and we will also know that there is serious trouble somewhere else.
