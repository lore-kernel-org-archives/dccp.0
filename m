From: David Ahern <dsahern@kernel.org>
Date: Thu, 25 May 2023 15:34:12 +0000
Subject: Re: [PATCH net-next v3] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <a1074987-c3ce-56cd-3005-beb5a3c55ef9@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230525125503.400797-1-leitao@debian.org>
In-Reply-To: <20230525125503.400797-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 5/25/23 9:05 AM, Willem de Bruijn wrote:
>> +/* A wrapper around sock ioctls, which copies the data from userspace
>> + * (depending on the protocol/ioctl), and copies back the result to userspace.
>> + * The main motivation for this function is to pass kernel memory to the
>> + * protocol ioctl callbacks, instead of userspace memory.
>> + */
>> +int sk_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
>> +{
>> +       int rc = 1;
>> +
>> +       if (ipmr_is_sk(sk))
>> +               rc = ipmr_sk_ioctl(sk, cmd, arg);
>> +       else if (ip6mr_is_sk(sk))
>> +               rc = ip6mr_sk_ioctl(sk, cmd, arg);
>> +       else if (phonet_is_sk(sk))
>> +               rc = phonet_sk_ioctl(sk, cmd, arg);
> 
> I don't understand what this buys us vs testing the sk_family,
> sk_protocol and cmd here.

To keep protocol specific code out of core files is the reason I
suggested it.

> 
> It introduces even deeper dependencies on the protocol specific
> header files. And the CONFIG issues that result from that. And it
> adds a bunch of wrappers that are only used once.
> 

