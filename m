From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed, 07 Jun 2023 12:15:28 +0000
Subject: RE: [PATCH net-next v6] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <648074e0e52d9_143118294e0@willemb.c.googlers.com.notmuch>
List-Id: <dccp.vger.kernel.org>
References: <20230606180045.827659-1-leitao@debian.org>
In-Reply-To: <20230606180045.827659-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Breno Leitao wrote:
> Most of the ioctls to net protocols operates directly on userspace
> argument (arg). Usually doing get_user()/put_user() directly in the
> ioctl callback.  This is not flexible, because it is hard to reuse these
> functions without passing userspace buffers.
> 
> Change the "struct proto" ioctls to avoid touching userspace memory and
> operate on kernel buffers, i.e., all protocol's ioctl callbacks is
> adapted to operate on a kernel memory other than on userspace (so, no
> more {put,get}_user() and friends being called in the ioctl callback).
> 
> This changes the "struct proto" ioctl format in the following way:
> 
>     int                     (*ioctl)(struct sock *sk, int cmd,
> -                                        unsigned long arg);
> +                                        int *karg);
> 
> (Important to say that this patch does not touch the "struct proto_ops"
> protocols)
> 
> So, the "karg" argument, which is passed to the ioctl callback, is a
> pointer allocated to kernel space memory (inside a function wrapper).
> This buffer (karg) may contain input argument (copied from userspace in
> a prep function) and it might return a value/buffer, which is copied
> back to userspace if necessary. There is not one-size-fits-all format
> (that is I am using 'may' above), but basically, there are three type of
> ioctls:
> 
> 1) Do not read from userspace, returns a result to userspace
> 2) Read an input parameter from userspace, and does not return anything
>   to userspace
> 3) Read an input from userspace, and return a buffer to userspace.
> 
> The default case (1) (where no input parameter is given, and an "int" is
> returned to userspace) encompasses more than 90% of the cases, but there
> are two other exceptions. Here is a list of exceptions:
> 
> * Protocol RAW:
>    * cmd = SIOCGETVIFCNT:
>      * input and output = struct sioc_vif_req
>    * cmd = SIOCGETSGCNT
>      * input and output = struct sioc_sg_req
>    * Explanation: for the SIOCGETVIFCNT case, userspace passes the input
>      argument, which is struct sioc_vif_req. Then the callback populates
>      the struct, which is copied back to userspace.
> 
> * Protocol RAW6:
>    * cmd = SIOCGETMIFCNT_IN6
>      * input and output = struct sioc_mif_req6
>    * cmd = SIOCGETSGCNT_IN6
>      * input and output = struct sioc_sg_req6
> 
> * Protocol PHONET:
>   * cmd = SIOCPNADDRESOURCE | SIOCPNDELRESOURCE
>      * input int (4 bytes)
>   * Nothing is copied back to userspace.
> 
> For the exception cases, functions sock_sk_ioctl_inout() will
> copy the userspace input, and copy it back to kernel space.
> 
> The wrapper that prepare the buffer and put the buffer back to user is
> sk_ioctl(), so, instead of calling sk->sk_prot->ioctl(), the callee now
> calls sk_ioctl(), which will handle all cases.
> 
> Signed-off-by: Breno Leitao <leitao@debian.org>

Reviewed-by: Willem de Bruijn <willemb@google.com>
