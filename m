From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Wed, 30 May 2007 14:07:25 +0000
Subject: Re: [PATCH 1/5] DCCP: Shift ccid3_li_hist
Message-Id: <39e6f6c70705300707j2c6432b1n6a78b3b1047583dd@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200705112236.36406.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200705112236.36406.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On 5/30/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Arnaldo Carvalho de Melo:
> |  The idea of having dccp_tfrc_lib.ko is to have things that are
> |  not specific to any CCID implementation, so that if some new CCID
> |  uses the TFRC algorithms it would share code with CCID3, etc.
> |
> |   So it is not really correct for the code in net/dccp/ccids/lib/
> |  to access the half connection internal state, as it really don't know
> |  what is the layout of such internal state.
> |
> |   In your patches you move ccid3_hc_rx_update_li from
> |  net/dccp/ccids/ccid3.c to net/dccp/ccids/lib/loss_interval.c and then
> |  renamed it to dccp_li_update_li, but this function still uses
> |  ccid3_hc_rx_sk, not good.
> |
> |   So I'm looking at the intent of the patches and will post here
> |  how I think it should have been done and the sequence of patches
> |  preparing for such change, etc.
> I understand your train of thought, since the same issue had bugged me;
> I think I may have a solution for that in my patch set.
>
> The problem is that
>  * TFRC (dccp_tfrc_lib.ko) needs to know the length of the first loss
>    interval (which is computed by ccid3_hc_rx_update_li)
>  * fully agree that the TFRC module should not (need to) know the interna=
ls
>    of the calling module - when CCID4 comes, the same problem will come a=
gain
>
> The choice I have been using was to use a function pointer for calc_first=
_li:
>
> /** tfrc_lh_interval_new  -  Insert new record into the Loss Interval dat=
abase

if it inserts it should be named foo_add or foo_insert, _new, at least
in the convention I used in DCCP is just for constructors, just to
allocate space and initialize the fields. In other areas of the kernel
people use _aloc, like in sock_alloc with the same semantics. Only
after the object is created we use something like _add or _insert to
put it into some list, hash table, etc.

>  * @lh:            Loss Interval database

And who allocated lh, i.e. what is its constructor? is it embedded
into some other struct? like

struct ccid3_hc_rx_sock {
    struct tfrc_loss_hist ccid3hcrx_lh;
.
.
.
};

and then you call tfrc_lh_interval_new(&hcrx->ccid3hcrx_lh, ...) ?

>  * @rh:            Receive history containing a fresh loss event
>  * @calc_first_li: Caller-dependent routine to compute length of first in=
terval
>  */
> int tfrc_lh_interval_new(struct tfrc_loss_hist *lh, struct tfrc_rx_hist *=
rh,
>                          u32 (*calc_first_li)(struct sock *), struct sock=
 *sk)
>
> The price to pay is that the argument for *calc_first_li needs to be carr=
ied, too,
> but other than that it separates the CCID3 and TFRC interfaces.

What are the reasons for sk to be needed? In the recent patches I kept
it just because we still use the ugly dccp_timestamp() interface that
needs it, but we have to solve that and at some point I think the best
thing is for the dccp_tfrc_lib code to not know a thing about struct
sock. But I digress... ok, we need some context in the ccid specific
code, it could be a void pointer that would be casted to, say, struct
ccid3_hc_rx_sock in the ccid3 case. Nah, leave it as sock, from were
we can get the whole context, even if we get to look at the other half
connection internal state somehow, the timestamp case has to be solved
but play no role here.

>
> This function is not actually used (though visible) in CCID3, the one tha=
t is called is

Why visible?

>
> **
>  *  tfrc_rx_handle_loss  -  Loss detection and further processing
>  *  @h:             The non-empty RX history object
>  *  @lh:            Loss Intervals database to update
>  *  @skb:           Currently received packet
>  *  @ndp:           The NDP count belonging to @skb
>  *  @calc_first_li: Caller-dependent computation of first loss interval i=
n @lh
>  *  Chooses action according to pending loss, updates LI database when a =
new
>  *  loss was detected, and does required post-processing. Returns 1 when =
caller
>  *  should send feedback, 0 otherwise.
>  */
> int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
>                         struct tfrc_loss_hist *lh,
>                         struct sk_buff *skb, u32 ndp,
>                         u32 (*calc_first_li)(struct sock *), struct sock =
*sk)
>
> This function is a `wrapper', which will call tfrc_lh_interval_new() when=
 there is a
> loss event (3 duplicate packets received). This is a single-function inte=
rface
> to the TFRC module, covering al the loss processing.

Oh, I see, with the same intent as what is in my tree, i.e. Ian's
rewritten patches:

http://git.kernel.org/?p=3Dlinux/kernel/git/acme/net-2.6.git;a=3Dblob_plain=
;f=3Dnet/dccp/ccids/lib/loss_interval.h;hb=E3370bb96ed004618a9398b6098421c7=
b05ac943

There are just tree functions, no loss interval
constructor/destructor, no loss event constructor/destructor, just
three functions:

extern void dccp_li_hist_purge(struct list_head *list);

extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);

extern void dccp_li_update_li(struct sock *sk,
			      struct list_head *li_hist_list,
			      struct list_head *hist_list,
			      struct timeval *last_feedback, u16 s,
			      u32 bytes_recv, u32 previous_x_recv,
			      u64 seq_loss, u8 win_loss);

I guess the distance from what is in this tree right now for where you
want to go is not that big, at least conceptually, i.e. right now the
loss_event.c code doesn't touches ccid specific private state, the
interface was reduced to just three functions.

> So there is some minor ugliness (two functions with a function pointer an=
d argument),
> but this affords a separation of interfaces.

That is not a problem, look for instance at inet_csk_get_port in
net/ipv4/inet_connection_sock.c, allows the same code to be used by
DCCP and TCP   resolving the separation using the same technique.

Looks conceptually sound, proceed :-)

- Arnaldo
