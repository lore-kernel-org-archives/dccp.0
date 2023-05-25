From: David Ahern <dsahern@kernel.org>
Date: Thu, 25 May 2023 15:03:02 +0000
Subject: Re: [PATCH net-next v3] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <83d90ef3-67ba-737e-02fb-dbfb7cc8d2de@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230525125503.400797-1-leitao@debian.org>
In-Reply-To: <20230525125503.400797-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On 5/25/23 8:54 AM, Simon Horman wrote:
> On Thu, May 25, 2023 at 04:19:32PM +0200, Eric Dumazet wrote:
>> On Thu, May 25, 2023 at 2:55=E2=80=AFPM Breno Leitao <leitao@debian.org>=
 wrote:
>>>
>>> Most of the ioctls to net protocols operates directly on userspace
>>> argument (arg). Usually doing get_user()/put_user() directly in the
>>> ioctl callback.  This is not flexible, because it is hard to reuse these
>>> functions without passing userspace buffers.
>>>
>>> Change the "struct proto" ioctls to avoid touching userspace memory and
>>> operate on kernel buffers, i.e., all protocol's ioctl callbacks is
>>> adapted to operate on a kernel memory other than on userspace (so, no
>>> more {put,get}_user() and friends being called in the ioctl callback).
>>>
>>
>>  diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
>>> index 862f1719b523..93705d99f862 100644
>>> --- a/include/net/phonet/phonet.h
>>> +++ b/include/net/phonet/phonet.h
>>> @@ -109,4 +109,23 @@ void phonet_sysctl_exit(void);
>>>  int isi_register(void);
>>>  void isi_unregister(void);
>>>
>>> +#ifdef CONFIG_PHONET
>>> +int phonet_sk_ioctl(struct sock *sk, unsigned int cmd, void __user *ar=
g);
>>> +
>>> +static inline bool phonet_is_sk(struct sock *sk)
>>> +{
>>> +       return sk->sk_family =3D PF_PHONET && sk->sk_protocol =3D PN_PR=
OTO_PHONET;
>>> +}
>>> +#else
>>> +static inline bool phonet_is_sk(struct sock *sk)
>>> +{
>>> +       return 0;
>>> +}
>>> +
>>> +static inline int phonet_sk_ioctl(struct sock *sk, unsigned int cmd, v=
oid __user *arg)
>>> +{
>>> +       return 1;
>>> +}
>>> +#endif
>>> +
>>>
>>
>> PHONET can be built as a module, so I guess the compiler would
>> complain if "CONFIG_PHONET=3Dm" ???
>=20
> Yes, indeed it does.
>=20

phonet_sk_ioctl is simple enough to make an inline in which case this
should go in include//linux/phonet.h.
