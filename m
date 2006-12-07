From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 07 Dec 2006 21:36:35 +0000
Subject: Re: [Patch 0/12]:
Message-Id: <5640c7e00612071336j1d241e8gf2ed2f99c7ab982d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612072112.10572@strip-the-willow>
In-Reply-To: <200612072112.10572@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/8/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I am almost fully convinced that it is necessary to armour the packet history list
> operations with read/write locks. The reasons:
>
>  * list manipulation is asynchronous, packet_sent/send_packet fill the list, while
>    packet_recv purges
>
>  * send_packet may sleep so that meanwhile new entries are put on top
>
>  * after applying patch 9 I got, for the first time, accurate RTT values [patch 9
>    puts all history work into packet_sent]
>
> It would be good to have further opinions/ideas on this.

I totally agree with this. I had looked into it at one point as I
wondered whether this was part of our problems and at that stage I
didn't as appeared to be OK. It might have changed since then or I
might just have been wrong but none the less it is definitely
worthwhile.

Over time I'd like to see these move to ring buffers as locking around
linked lists ruins concurrency, stalls etc but that is relatively
minor.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
