From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 05 Oct 2007 19:51:34 +0000
Subject: Re: [Announce]: Test tree updated
Message-Id: <5640c7e00710051251n14a47035l6d751afd7e0ec020@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710051043.05455@strip-the-willow>
In-Reply-To: <200710051043.05455@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/5/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> All submitted feature-negotiation patches have been put into the test tree, after scrubbing
> them for superfluous whitespace.
>
>
>
> Ian, there was overlap with your second patch, since one of the test tree patches also removed
> the LISTEN blocks. Below is an rcsdiff of your second patch (I keep all patches under revision
> control as well): a `-+' means that a previous addition was now removed, a `--' means that a
> previous removal is now removed (as with all removals in ccid3.c), single +/- mean that the
> context has changed.
>
Thanks Gerrit. I'll use this next time I dive into my code.
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
