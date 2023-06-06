From: Matthieu Baerts <matthieu.baerts@tessares.net>
Date: Tue, 06 Jun 2023 11:35:20 +0000
Subject: Re: [PATCH net-next v5] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <c709b7d0-6b06-4fc9-a99a-520ec13550ac@tessares.net>
List-Id: <dccp.vger.kernel.org>
References: <20230602163044.1820619-1-leitao@debian.org>
In-Reply-To: <20230602163044.1820619-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Breno,

On 06/06/2023 12:11, Breno Leitao wrote:
> On Sun, Jun 04, 2023 at 11:17:56AM +0200, Willem de Bruijn wrote:
>>> On Sat, Jun 03, 2023 at 10:21:50AM +0200, Willem de Bruijn wrote:
>>>> On Fri, Jun 2, 2023 at 6:31=E2=80=AFPM Breno Leitao <leitao@debian.org=
> wrote:
>>>>> Signed-off-by: Breno Leitao <leitao@debian.org>
>>>>
>>>> Please check the checkpatch output
>>>>
>>>> https://patchwork.hopto.org/static/nipa/753609/13265673/checkpatch/std=
out
>>>
>>> I am checking my current checkpatch before sending the patch, but I am
>>> not seeing the problems above.
>>>
>>> My tree is at 44c026a73be8038 ("Linux 6.4-rc3"), and I am not able to
>>> reproduce the problems above.
>>>
>>>         $ scripts/checkpatch.pl v5/v5-0001-net-ioctl-Use-kernel-memory-=
on-protocol-ioctl-cal.patch
>>>         total: 0 errors, 0 warnings, 0 checks, 806 lines checked
>>>         v5/v5-0001-net-ioctl-Use-kernel-memory-on-protocol-ioctl-cal.pa=
tch has no obvious style problems and is ready for submission.
>>>
>>> Let me investigate what options I am missing when running checkpatch.
>>
>> The reference is to the checkpatch as referenced by patchwork:
>>
>> https://patchwork.kernel.org/project/netdevbpf/patch/20230602163044.1820=
619-1-leitao@debian.org/
>>
>> The 80 character limit is a soft limit. But also note the CHECK
>> statements on whitespace.
>=20
> Right. In order to enable the "CHECK" statments, we need to pass the
> "--subjective" parameter to checpatch.pl
>=20
> That said, I am able to reproduce the same output now, using the
> following command line:
>=20
> 	$ scripts/checkpatch.pl --subjective --max-line-length=80

The different results visible on Patchwork are posted by a CI using
scripts hosted there:

  https://github.com/kuba-moo/nipa

If you are interested to know how checkpatch.pl is executed, you can
have a look there:


https://github.com/kuba-moo/nipa/blob/master/tests/patch/checkpatch/checkpa=
tch.sh#L16

I guess what you need is the "--strict" argument:

>   $ ./scripts/checkpatch.pl --strict --max-line-length=80 \
>       --ignore=3DCOMMIT_LOG_LONG_LINE,MACRO_ARG_REUSE,ALLOC_SIZEOF_STRUCT=
,NO_AUTHOR_SIGN_OFF,GIT_COMMIT_ID,CAMELCASE \
>       -g HEAD

Cheers,
Matt
--=20
Tessares | Belgium | Hybrid Access Solutions
www.tessares.net
