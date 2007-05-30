From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 30 May 2007 16:00:43 +0000
Subject: Re: [PATCH 1/5] DCCP: Shift ccid3_li_hist
Message-Id: <200705301700.43746@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200705112236.36406.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200705112236.36406.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  > /** tfrc_lh_interval_new  -  Insert new record into the Loss Interval =
database
| =20
|  if it inserts it should be named foo_add or foo_insert, _new, at least
|  in the convention I used in DCCP is just for constructors, just to
|  allocate space and initialize the fields. In other areas of the kernel
|  people use _aloc, like in sock_alloc with the same semantics. Only
|  after the object is created we use something like _add or _insert to
|  put it into some list, hash table, etc.
That is a good point, since the function really does not merely allocate, it
 * tests if a loss interval candidate is really new=20
 * if yes allocates
 * and then updates all dependent variables (length of I_0 and I_mean)
So `_new' will be dropped, if there are no other suggestions, I'll make it =
`_add'.

 =20
|  >  * @lh:            Loss Interval database
| =20
|  And who allocated lh, i.e. what is its constructor? is it embedded
|  into some other struct? like
@lh is the tfrc loss interval database, declared in ccid3.h,

struct ccid3_hc_rx_sock {
        u8                              ccid3hcrx_last_counter:4;
        enum ccid3_hc_rx_states         ccid3hcrx_state:8;
        u32                             ccid3hcrx_bytes_recv;
        u32                             ccid3hcrx_x_recv;
        u32                             ccid3hcrx_rtt;
        ktime_t                         ccid3hcrx_last_feedback;
        struct tfrc_rx_hist             ccid3hcrx_hist;	=09
	struct tfrc_loss_hist           ccid3hcrx_li_hist	/* <=3D here */
	/* ... */
};

Both tfrc_rx_hist (packet_history.h) and tfrc_loss_hist (loss_interval.h) a=
re
part of the structures used/exported by the TFRC module.

|  and then you call tfrc_lh_interval_new(&hcrx->ccid3hcrx_lh, ...) ?
Yes that is right, it is used via the wrapper in the following manner in cc=
id3.c

	/*
         *      Handle pending losses and otherwise check for new loss
         */
        if (tfrc_rx_loss_pending(&hcrx->ccid3hcrx_hist) &&
            tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist,
                                &hcrx->ccid3hcrx_li_hist,
                                skb, ndp, ccid3_first_li, sk) ) {
                do_feedback =3D FBACK_PARAM_CHANGE;
                goto done_receiving;
        }


|  >  * @rh:            Receive history containing a fresh loss event
|  >  * @calc_first_li: Caller-dependent routine to compute length of first=
 interval
|  >  */
|  > int tfrc_lh_interval_new(struct tfrc_loss_hist *lh, struct tfrc_rx_his=
t *rh,
|  >                          u32 (*calc_first_li)(struct sock *), struct s=
ock *sk)
|  >
|  > The price to pay is that the argument for *calc_first_li needs to be c=
arried, too,
|  > but other than that it separates the CCID3 and TFRC interfaces.
| =20
|  What are the reasons for sk to be needed? In the recent patches I kept
|  it just because we still use the ugly dccp_timestamp() interface that
|  needs it, but we have to solve that and at some point I think the best
|  thing is for the dccp_tfrc_lib code to not know a thing about struct
|  sock.
The struct sock is used (as you guessed) to dereference the ccid3_hc_rx_soc=
k:

static u32 ccid3_first_li(struct sock *sk)
{
        struct ccid3_hc_rx_sock *hcrx =3D ccid3_hc_rx_sk(sk);
  	/* ... */
}

And the ccid3_hc_rx_sock knows all the relevant parameters (rtt, bytes_rece=
ived,
when the last feedback was sent, and so on).
So if CCID4 wanted to call the loss interval code, it would just be
	struct ccid4_hc_rx_sock *hcrx =3D ccid4_hc_rx_sk(sk);    =20

(With regard to the timestamps, I have updated most of my patches to migrat=
e to ktime_t,
as per Ian's earlier suggestion.)



|  > This function is not actually used (though visible) in CCID3, the one =
that is called is
| =20
|  Why visible?
In net/dccp/ccids/lib/loss_interval.h it is declared as

 extern int  tfrc_lh_interval_new(struct tfrc_loss_hist *, struct tfrc_rx_h=
ist *,
                                  u32 (*first_li)(struct sock *), struct so=
ck *);

I thought it would make sense to export it in case someone wants to later c=
reate
a different loss handling mechanism. I can drop the declaration if that is =
preferable.

|  Oh, I see, with the same intent as what is in my tree, i.e. Ian's
|  rewritten patches:
| =20
|  http://git.kernel.org/?p=3Dlinux/kernel/git/acme/net-2.6.git;a=3Dblob_pl=
ain;f=3Dnet/dccp/ccids/lib/loss_interval.h;hb=E3370bb96ed004618a9398b609842=
1c7b05ac943
I perused most of your patches this morning when I wrote the email, but did=
n't reply immediately=20
since part of the thoughts overlapped with this email.


|  There are just tree functions, no loss interval
|  constructor/destructor, no loss event constructor/destructor, just
|  three functions:
| =20
|  extern void dccp_li_hist_purge(struct list_head *list);
| =20
|  extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
| =20
|  extern void dccp_li_update_li(struct sock *sk,
|  			      struct list_head *li_hist_list,
|  			      struct list_head *hist_list,
|  			      struct timeval *last_feedback, u16 s,
|  			      u32 bytes_recv, u32 previous_x_recv,
|  			      u64 seq_loss, u8 win_loss);
| =20
|  I guess the distance from what is in this tree right now for where you
|  want to go is not that big, at least conceptually, i.e. right now the
|  loss_event.c code doesn't touches ccid specific private state, the
|  interface was reduced to just three functions.
| =20
You have done a lot of work and managed to boil down some degree of complex=
ity into just
three functions. In my patch set there is of course the overhead of constru=
ctor / destructor
but with that the tfrc_lib could be put into its own, separate module.=20
I am amazed that you were able to do this so fast, separating the code out =
has taken me
several weeks of work. And it does not create overhead: there are in genera=
l more deleted than
added lines in the patch.

|  Looks conceptually sound, proceed :-)
| =20
I will resubmit the patch set as soon as these changes become visible in Da=
vid Miller's tree.
