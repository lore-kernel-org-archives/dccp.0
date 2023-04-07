From: David Ahern <dsahern@kernel.org>
Date: Fri, 07 Apr 2023 02:46:38 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <e576f6fe-d1f3-93cd-cb94-c0ae115299d8@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

On 4/6/23 12:16 PM, Willem de Bruijn wrote:
> On Thu, Apr 6, 2023 at 11:59 AM Breno Leitao <leitao@debian.org> wrote:
>>
>> On Thu, Apr 06, 2023 at 11:34:28AM -0400, Willem de Bruijn wrote:
>>> On Thu, Apr 6, 2023 at 10:45 AM Breno Leitao <leitao@debian.org> wrote:
>>>>
>>>> From: Breno Leitao <leit@fb.com>
>>>>
>>>> This patchset creates the initial plumbing for a io_uring command for
>>>> sockets.
>>>>
>>>> For now, create two uring commands for sockets, SOCKET_URING_OP_SIOCOUTQ
>>>> and SOCKET_URING_OP_SIOCINQ. They are similar to ioctl operations
>>>> SIOCOUTQ and SIOCINQ. In fact, the code on the protocol side itself is
>>>> heavily based on the ioctl operations.
>>>
>>> This duplicates all the existing ioctl logic of each protocol.
>>>
>>> Can this just call the existing proto_ops.ioctl internally and translate from/to
>>> io_uring format as needed?
>>
>> This is doable, and we have two options in this case:
>>
>> 1) Create a ioctl core function that does not call `put_user()`, and
>> call it from both the `udp_ioctl` and `udp_uring_cmd`, doing the proper
>> translations. Something as:
>>
>>         int udp_ioctl_core(struct sock *sk, int cmd, unsigned long arg)
>>         {
>>                 int amount;
>>                 switch (cmd) {
>>                 case SIOCOUTQ: {
>>                         amount = sk_wmem_alloc_get(sk);
>>                         break;
>>                 }
>>                 case SIOCINQ: {
>>                         amount = max_t(int, 0, first_packet_length(sk));
>>                         break;
>>                 }
>>                 default:
>>                         return -ENOIOCTLCMD;
>>                 }
>>                 return amount;
>>         }
>>
>>         int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
>>         {
>>                 int amount = udp_ioctl_core(sk, cmd, arg);
>>
>>                 return put_user(amount, (int __user *)arg);
>>         }
>>         EXPORT_SYMBOL(udp_ioctl);
>>
>>
>> 2) Create a function for each "case entry". This seems a bit silly for
>> UDP, but it makes more sense for other protocols. The code will look
>> something like:
>>
>>          int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
>>          {
>>                 switch (cmd) {
>>                 case SIOCOUTQ:
>>                 {
>>                         int amount = udp_ioctl_siocoutq();
>>                         return put_user(amount, (int __user *)arg);
>>                 }
>>                 ...
>>           }
>>
>> What is the best approach?
> 
> A, the issue is that sock->ops->ioctl directly call put_user.
> 
> I was thinking just having sock_uring_cmd call sock->ops->ioctl, like
> sock_do_ioctl.
> 
> But that would require those callbacks to return a negative error or
> positive integer, rather than calling put_user. And then move the
> put_user to sock_do_ioctl. Such a change is at least as much code
> change as your series. Though without the ending up with code
> duplication. It also works only if all ioctls only put_user of integer
> size. That's true for TCP, UDP and RAW, but not sure if true more
> broadly.
> 
> Another approach may be to pass another argument to the ioctl
> callbacks, whether to call put_user or return the integer and let the
> caller take care of the output to user. This could possibly be
> embedded in the a high-order bit of the cmd, so that it fails on ioctl
> callbacks that do not support this mode.
> 
> Of the two approaches you suggest, I find the first preferable.

The first approach sounds better to me and it would be good to avoid
io_uring details in the networking code (ie., cmd->sqe->cmd_op).
