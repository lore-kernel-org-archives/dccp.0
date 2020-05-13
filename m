From: Jakub Sitnicki <jakub@cloudflare.com>
Date: Wed, 13 May 2020 14:50:30 +0000
Subject: Re: [PATCH bpf-next v2 05/17] inet: Run SK_LOOKUP BPF program on socket lookup
Message-Id: <87v9kzubwp.fsf@cloudflare.com>
List-Id: <dccp.vger.kernel.org>
References: <20200511185218.1422406-6-jakub@cloudflare.com>
In-Reply-To: <20200511185218.1422406-6-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

On Wed, May 13, 2020 at 04:21 PM CEST, Lorenz Bauer wrote:
> On Tue, 12 May 2020 at 14:52, Jakub Sitnicki <jakub@cloudflare.com> wrote:

[...]

>> So if IIUC the rough idea here would be like below?
>>
>> - 1st program calls
>>
>>   bpf_sk_assign(ctx, sk1, 0 /*flags*/) -> 0 (OK)
>>
>> - 2nd program calls
>>
>>   bpf_sk_assign(ctx, sk2, 0) -> -EBUSY (already selected)
>>   bpf_sk_assign(ctx, sk2, BPF_EXIST) -> 0 (OK, replace existing)
>>
>> In this case the last program to run has the final say, as opposed to
>> the semantics where DROP/REDIRECT terminates.
>
> Does sk_assign from TC also gain BPF_EXIST semantics? As you know,
> I'm a bit concerned that TC and sk_lookup sk_assign are actually to completely
> separate helpers. This is a good way to figure out if its a good idea to
> overload the name, imo.

I don't have a strong opinion here. We could have a dedicated helper.

Personally I'm not finding it confusing. As a BPF user you know what
program type you're working with (TC vs SK_LOOKUP), and both helper
variants will be documented separately in the bpf-helpers man-page, like
so:

       int bpf_sk_assign(struct sk_buff *skb, struct bpf_sock *sk, u64
       flags)

              Description
                     Helper is overloaded  depending  on  BPF  program
                     type.     This     description     applies     to
                     BPF_PROG_TYPE_SCHED_CLS                       and
                     BPF_PROG_TYPE_SCHED_ACT programs.

                     Assign  the  sk  to  the  skb. When combined with
                     appropriate routing configuration to receive  the
                     packet  towards  the socket, will cause skb to be
                     delivered to the  specified  socket.   Subsequent
                     redirection    of    skb   via    bpf_redirect(),
                     bpf_clone_redirect() or other methods outside  of
                     BPF may interfere with successful delivery to the
                     socket.

                     This operation is  only  valid  from  TC  ingress
                     path.

                     The flags argument must be zero.

              Return 0  on  success,  or  a  negative errno in case of
                     failure.

                     · -EINVAL           Unsupported flags specified.

                     · -ENOENT            Socket  is  unavailable  for
                       assignment.

                     · -ENETUNREACH       Socket is unreachable (wrong
                       netns).

                     ·

                       -EOPNOTSUPP Unsupported operation, for  example
                       a
                              call from outside of TC ingress.

                     · -ESOCKTNOSUPPORT   Socket  type  not  supported
                       (reuseport).

       int bpf_sk_assign(struct bpf_sk_lookup  *ctx,  struct  bpf_sock
       *sk, u64 flags)

              Description
                     Helper  is  overloaded  depending  on BPF program
                     type.     This     description     applies     to
                     BPF_PROG_TYPE_SK_LOOKUP programs.

                     Select the sk as a result of a socket lookup.

                     For  the  operation to succeed passed socket must
                     be compatible with the  packet  description  pro‐
                     vided by the ctx object.

                     L4  protocol (IPPROTO_TCP or IPPROTO_UDP) must be
                     an exact  match.  While  IP  family  (AF_INET  or
                     AF_INET6)  must be compatible, that is IPv6 sock‐
                     ets that are not v6-only can be selected for IPv4
                     packets.

                     Only TCP listeners and UDP sockets, that is sock‐
                     ets which have SOCK_RCU_FREE  flag  set,  can  be
                     selected.

                     The flags argument must be zero.

              Return 0  on  success,  or  a  negative errno in case of
                     failure.

                     -EAFNOSUPPORT is socket  family  (sk->family)  is
                     not compatible with packet family (ctx->family).

                     -EINVAL if unsupported flags were specified.

                     -EPROTOTYPE  if socket L4 protocol (sk->protocol)
                     doesn't match packet protocol (ctx->protocol).

                     -ESOCKTNOSUPPORT if socket does not use RCU free‐
                     ing.

But it would be helpful to hear what others think about it.
