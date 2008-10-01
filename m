From: "Leandro Sales" <leandroal@gmail.com>
Date: Wed, 01 Oct 2008 19:43:58 +0000
Subject: Re: Protocol not attached
Message-Id: <5bc4c4570810011243i238ab351t31e8e0f333b273cd@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Oct 1, 2008 at 4:37 PM, Arnaldo Carvalho de Melo
<acme@redhat.com> wrote:
> Em Thu, Oct 02, 2008 at 08:32:20AM +1300, Ian McDonald escreveu:
>> >
>> > Just completing the information. Using 2.6.26 on arm worked.
>> >
>> > Time to use git-bisect then I would guess...
>
> Yes, its possible that this problem is not DCCP specific, perhaps
> affecting SCTP too. I.e. both are loadable modules usually, while TCP is
> always builtin.
>
> - Arnaldo
>

Thanks Arnaldo and Ian.

Then, is it necessary to report this issue in the kernel dev maillist?

Regards,
Leandro.
