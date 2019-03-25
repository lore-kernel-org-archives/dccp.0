From: YueHaibing <yuehaibing@huawei.com>
Date: Mon, 25 Mar 2019 02:51:14 +0000
Subject: Re: [PATCH v2] dccp: Fix memleak in __feat_register_sp
Message-Id: <f86a5326-2681-1d8f-094a-4316837f7beb@huawei.com>
List-Id: <dccp.vger.kernel.org>
References: <20190322134348.15048-1-yuehaibing@huawei.com>
In-Reply-To: <20190322134348.15048-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org


On 2019/3/25 8:12, David Miller wrote:
> From: Yue Haibing <yuehaibing@huawei.com>
> Date: Fri, 22 Mar 2019 21:43:48 +0800
>=20
>> From: YueHaibing <yuehaibing@huawei.com>
>>
>> If dccp_feat_push_change fails, we forget free the mem
>> which is alloced by kmemdup in dccp_feat_clone_sp_val.
>>
>> Reported-by: Hulk Robot <hulkci@huawei.com>
>> Fixes: e8ef967a54f4 ("dccp: Registration routines for changing feature v=
alues")
>> Signed-off-by: YueHaibing <yuehaibing@huawei.com>
>> ---
>> v2: kfree 'val --> 'fval'
>=20
> Don't submit any patches for at least 2 days, I am getting really tired of
> changes you don't even COMPILE TEST:
>=20
>   CC [M]  net/dccp/feat.o
> net/dccp/feat.c: In function =A1__feat_register_sp=A2:
> net/dccp/feat.c:742:13: error: invalid type argument of =A1->=A2 (have =
=A1dccp_feat_val=A2 {aka =A1union <anonymous>=A2})
>    kfree(fval->sp.vec);
>      =20

I'm very sorry for this, will self-reflection.

       ^~
>=20
