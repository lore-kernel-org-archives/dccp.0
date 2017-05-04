From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 04 May 2017 13:36:37 +0000
Subject: Re: net/dccp: dccp_create_openreq_child freed held lock
Message-Id: <CAAeHK+wSrkrooaK=d6Od85hNNQbTSuPxe55DFFYWEuE5zSqmSw@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CACT4Y+ZOAWRzJH3=xJ1z5bFVCM2-smuVSykziQPhSgkv1k3FBQ@mail.gmail.com>
In-Reply-To: <CACT4Y+ZOAWRzJH3=xJ1z5bFVCM2-smuVSykziQPhSgkv1k3FBQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Mar 1, 2017 at 4:40 PM, Arnaldo Carvalho de Melo
<acme@kernel.org> wrote:
> Em Wed, Mar 01, 2017 at 12:35:10PM -0300, Arnaldo Carvalho de Melo escreveu:
>> Em Wed, Mar 01, 2017 at 10:38:54AM +0100, Dmitry Vyukov escreveu:
>> > Hello,
>> >
>> > I've got the following report while running syzkaller fuzzer on
>> > 86292b33d4b79ee03e2f43ea0381ef85f077c760:
>> >
>> >
>> > It seems that dccp_create_openreq_child needs to unlock the sock if
>> > dccp_feat_activate_values fails.
>>
>> Yeah, can you please use the patch below, that mimics the error paths in
>> sk_clone_new(), from where I think even the comment about it being a raw
>
> Argh, s/sk_clone_new()/sk_clone_lock()/g

Hi Arnaldo,

Could you send the patch?

We haven't seen these reports since we applied it.

Thanks!

>
> - Arnaldo
>
>> copy came, but the bh_unlock_sock() didn't?
>>
>> - Arnaldo
>>
>> diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
>> index 53eddf99e4f6..d20d948a98ed 100644
>> --- a/net/dccp/minisocks.c
>> +++ b/net/dccp/minisocks.c
>> @@ -122,6 +122,7 @@ struct sock *dccp_create_openreq_child(const struct sock *sk,
>>                       /* It is still raw copy of parent, so invalidate
>>                        * destructor and make plain sk_free() */
>>                       newsk->sk_destruct = NULL;
>> +                     bh_unlock_sock(newsk);
>>                       sk_free(newsk);
>>                       return NULL;
>>               }
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
