From: Pavel Begunkov <asml.silence@gmail.com>
Date: Mon, 19 Jun 2023 09:28:30 +0000
Subject: Re: [RFC PATCH v2 1/4] net: wire up support for file_operations->uring_cmd()
Message-Id: <d9c9bd5f-b17e-fbd8-5646-4f51b927cc6b@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230614110757.3689731-2-leitao@debian.org>
In-Reply-To: <20230614110757.3689731-2-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/14/23 16:15, David Ahern wrote:
> On 6/14/23 5:07 AM, Breno Leitao wrote:
>> diff --git a/include/linux/net.h b/include/linux/net.h
>> index 8defc8f1d82e..58dea87077af 100644
>> --- a/include/linux/net.h
>> +++ b/include/linux/net.h
>> @@ -182,6 +182,8 @@ struct proto_ops {
>>   	int	 	(*compat_ioctl) (struct socket *sock, unsigned int cmd,
>>   				      unsigned long arg);
>>   #endif
>> +	int		(*uring_cmd)(struct socket *sock, struct io_uring_cmd *cmd,
>> +				     unsigned int issue_flags);
>>   	int		(*gettstamp) (struct socket *sock, void __user *userstamp,
>>   				      bool timeval, bool time32);
>>   	int		(*listen)    (struct socket *sock, int len);
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 62a1b99da349..a49b8b19292b 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -111,6 +111,7 @@ typedef struct {
>>   struct sock;
>>   struct proto;
>>   struct net;
>> +struct io_uring_cmd;
>>   
>>   typedef __u32 __bitwise __portpair;
>>   typedef __u64 __bitwise __addrpair;
>> @@ -1259,6 +1260,9 @@ struct proto {
>>   
>>   	int			(*ioctl)(struct sock *sk, int cmd,
>>   					 int *karg);
>> +	int			(*uring_cmd)(struct sock *sk,
>> +					     struct io_uring_cmd *cmd,
>> +					     unsigned int issue_flags);
>>   	int			(*init)(struct sock *sk);
>>   	void			(*destroy)(struct sock *sk);
>>   	void			(*shutdown)(struct sock *sk, int how);
>> @@ -1934,6 +1938,8 @@ int sock_common_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
>>   			int flags);
>>   int sock_common_setsockopt(struct socket *sock, int level, int optname,
>>   			   sockptr_t optval, unsigned int optlen);
>> +int sock_common_uring_cmd(struct socket *sock, struct io_uring_cmd *cmd,
>> +			  unsigned int issue_flags);
>>   
>>   void sk_common_release(struct sock *sk);
>>   
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 1df7e432fec5..339fa74db60f 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -3668,6 +3668,18 @@ int sock_common_setsockopt(struct socket *sock, int level, int optname,
>>   }
>>   EXPORT_SYMBOL(sock_common_setsockopt);
>>   
>> +int sock_common_uring_cmd(struct socket *sock, struct io_uring_cmd *cmd,
>> +			  unsigned int issue_flags)
>> +{
>> +	struct sock *sk = sock->sk;
>> +
>> +	if (!sk->sk_prot || !sk->sk_prot->uring_cmd)
>> +		return -EOPNOTSUPP;
>> +
>> +	return sk->sk_prot->uring_cmd(sk, cmd, issue_flags);
>> +}
>> +EXPORT_SYMBOL(sock_common_uring_cmd);
>> +
> 
> 
> io_uring is just another in-kernel user of sockets. There is no reason
> for io_uring references to be in core net code. It should be using
> exposed in-kernel APIs and doing any translation of its op codes in
> io_uring/  code.

That callback is all about file dependent operations, just like ioctl.
And as the patch in question is doing socket specific stuff, I think
architecturally it fits well. I also believe Breno wants to extend it
later to support more operations.

Sockets are a large chunk of use cases, it can be implemented as a
separate io_uring request type if nothing else works, but in general
that might not be as scalable.

-- 
Pavel Begunkov
