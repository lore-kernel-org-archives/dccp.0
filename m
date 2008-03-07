From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 07 Mar 2008 19:23:03 +0000
Subject: Re: packet priorities
Message-Id: <5640c7e00803071123i5e682e56ya1523985d93c60d9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sat, Mar 8, 2008 at 4:49 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>  The only existing approaches I know of are
>   1. Ian's patches which communicate an expiry time to the kernel
>     http://www.wand.net.nz/~iam4/
>     Ian keeps his best-packet-next algorithm as an experimental patch set,
>     but I can see useful points - in particular the idea of passing the
>     expiry time as ancillary data (cmsghdr).

You can use whatever of my code that you want. If I haven't put GPL
license over any of my code then I now hereby release it under GPL v2
or later.

My code is fugly though and only works on CCID3. If you don't
understand fugly see http://www.answers.com/topic/fugly

>   2. There was an early implementation by Lai/Kohler
>     http://www.cs.ucla.edu/~kohler/pubs/lai04efficiency.pdf
>     but this is more of a conceptual model, as it shares memory regions
>     between kernel and user space. The only way I can see of
>     implementing this would be mmap() with additional primitives to
>     protect the shared areas. Maybe there is a smarter way.
>     This used a 2-priority scheme: enqueued packets are either `live'
>     or `dead'; and the application can modify packets it already
>     enqueued.

As part of my last set of work I emulated what Lai/Kohler were trying
to do and implemented it. Code is also on website and is in best
packet next code. I did it entirely in kernel space and what I was
trying to do is documented in my paper that I submitted to NOSSDAV
(also on website).

>  | Would such a patch be accepted in mainline kernel? Of course after discussing
>  | the ideas and implementation details. Thanks in advance for your input,
>  This depends on Arnaldo's decision. From experience, experimental or new
>  features take a little longer, but this should by no means be a discouragement.
>
>  In the meantime, I would be more than happy to allocate space and/or a tree on
>  as part of the test tree,
>  http://www.linux-foundation.org/en/Net:DCCP_Testing#Experimental_DCCP_source_tree
>
>  which would be kept in synch with the netdev tree.
>
The main criteria would be:
- standard packets go through without impact on performance or very, very minor
- not fugly code
- has a good design behind it.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
