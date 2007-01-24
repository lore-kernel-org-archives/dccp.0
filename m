From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 24 Jan 2007 11:25:18 +0000
Subject: Re: [PATCH 2/7]: Wrap computation of RFC3390-initial rate into separate function
Message-Id: <200701241125.18599@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701231540.51401@strip-the-willow>
In-Reply-To: <200701231540.51401@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 24/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > [CCID 3]: Wrap computation of RFC3390-initial rate into separate function
|  > +static inline u64 rfc3390_initial_rate(struct sock *sk)
|  
|  Apart from in header files which already exist you shouldn't be
|  putting new inline functions in as per a number of discussions on
|  lkml. The reason for this is that gcc now decides itself when to
|  inline code and when not to.
|
I would fully agree with you if the function contained some more statements.
But this one is really meagre, i.e. it would make no difference when placing
it as statement. 

I have read through some of the discussions on inlining and am referring to
http://lwn.net/Articles/166172/
There, Linus Torvalds and Andrew Morton suggest to decide on a case-by-case
analysis. I believe it is good practice to tell the compiler the intention
(and thus have started to use `const' for similar reasons).

Would you be ok with moving that function into ccid3.h instead?
