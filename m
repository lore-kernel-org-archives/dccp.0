From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Fri, 13 Apr 2007 11:56:23 +0000
Subject: Re: [PATCH 07/29] Use skb timestamp for receiver side
Message-Id: <39e6f6c70704130456o2e8fcd80me8682b22cfa40518@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070412211454.GH21292@ghostprotocols.net>
In-Reply-To: <20070412211454.GH21292@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Ian McDonald:

> |  > If for instance you read the documentation accompanying that patch, there is a
> |  > difference between 100 usec ... 1msec between skb_get_timestamp and taking the timestamp
> |  > in the CCID3 receiver. It all adds up.
> |  >
> |  I think we need to look at whether the protocol is right for LANs but
> |  I think if we carry out Eddie's suggestions it may well be right.
> |  Against earlier code a couple of months ago with a couple of my
> |  patches I was achieving around 90 Mbits/sec on iperf which matched TCP
> |  performance and it was stable. It responded gracefully to loss also.

> I have two boxes with Gbit cards here and saw speeds up to 750..820 Mbit.
> It seems that the computation overhead allows it to reach up to 80..90% of the
> link bandwidth (with coarse-granularity problems still unresolved).
>
>
> |  I have not tested lately and tried to replicate but I know that the
> |  state of tree before current patches couldn't do that any more... As
> |  time permits I will redo the work.

> Do you remember when the `bidirectional' patch was reverted? - after that the
> CCID3 sender slowed down again to 75..80 Mbits/sec on a 100Mbit link.
> This comes from the processing overhead, and was the original motivation for
> this patch.

How many connections? Up to now, when I was more involved in DCCP
development, for the sake of testing the correctness of the protocol I
mostly tested with just a few connections, most of the time with just
one, which is OK while we're not yet feeling so good about the overal
correctness of the implementation, and because I mostly reused the TCP
machinery, but for performance we really have to test with many
connections, and in fact in combination with TCP connections, so that
we can see how DCCP affects overal system performance/stability.

> That incidentally was the second `moronic' patch I had submitted (as it limited
> connections to being one-directional). Without Andre's help it would probably still
> be in. This really is the point I was trying to make in the email - I think we need to
> focus more on the code. Here are two cases where the missing review/input came from outside.
>
> I am not claiming to be any special. My hacking skills are rather moderate (i.e. you
> have been warned about them patches :)

Neither me, and everybody commit mistakes, I should have known better
that net_enable_timestamp was not supposed to be enabled for normal
connections, just for things like tcpdump, etc, but in the end I
pushed for Dave trying to move things a bit forward, my bad, we really
have to take into account decisions we make that affects the rest of
the system :-\

- Arnaldo
