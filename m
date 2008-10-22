From: "Leandro Sales" <leandroal@gmail.com>
Date: Wed, 22 Oct 2008 01:37:38 +0000
Subject: Re: Protocol not attached
Message-Id: <5bc4c4570810211837r24d51417y4aaea5c207ae8688@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Oct 21, 2008 at 10:37 PM, Leandro Sales <leandroal@gmail.com> wrote:
> On Tue, Oct 21, 2008 at 3:08 PM, Leandro Sales <leandroal@gmail.com> wrote:
>> On Tue, Oct 21, 2008 at 2:32 PM, Arnaldo Carvalho de Melo
>> <acme@redhat.com> wrote:
>>> Em Tue, Oct 21, 2008 at 11:19:36AM -0300, Leandro Sales escreveu:
>>>> On Mon, Oct 20, 2008 at 10:13 AM, Arnaldo Carvalho de Melo
>>>> <acme@redhat.com> wrote:
>>>> > Em Sat, Oct 18, 2008 at 01:06:28PM +0200, Gerrit Renker escreveu:
>>>> >
>>>> > <SNIP>
>>>> >
>>>> >> Incidentally the new netdev-2.6 has a commit called "Remove CONFIG_KMOD from
>>>> >> net/ (towards removing KMOD entirely)", so perhaps there is something in
>>>> >> progress.
>>>> >
>>>> > Is CONFIG_MODULES present in the config file that produces a kernel that
>>>> > has the problem?
>>>
>>> Well, he has both CONFIG_KMOD and CONFIG_MODULES...
>>>
>>>> > I guess not, Leandro, can you please add it manually, then do a make
>>>> > oldconfig, check that it is still there, then build the kernel?
>>>> >
>>>> > This is the part of the patch Gerrit mentioned
>>>> > (95a5afca4a8d2e1cb77e1d4bc6ff9f718dc32f7a) that could be hitting you.
>>>> >
>>>> >
>>>> > diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
>>>> > index 4809753..8fe931a 100644
>>>> > --- a/net/dccp/ccid.c
>>>> > +++ b/net/dccp/ccid.c
>>>> > @@ -154,7 +154,7 @@ struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx, gfp_t gfp)
>>>> >        struct ccid *ccid = NULL;
>>>> >
>>>> >        ccids_read_lock();
>>>> > -#ifdef CONFIG_KMOD
>>>> > +#ifdef CONFIG_MODULES
>>>> >        if (ccids[id] = NULL) {
>>>> >                /* We only try to load if in process context */
>>>> >                ccids_read_unlock();
>>>> >
>>>> > - Arnaldo
>>>> >
>>>>
>>>> I run the test again. I run git clone --reference, git checkgout
>>>> origin/dccp as usual. It does not show 2.6.27-rc8 in the DCCP tree,
>>>> only 2.6.27. Is that correct?
>>>
>>> I guess that there was when Gerrit branched, can you try using Linus
>>> tree?
>>>
>>> I.e. start bisecting, and it doesn't even needs to be with git, do it
>>> the old way :)
>>>
>>> - Arnaldo
>>>
>>
>> Hello Arnaldo and others,
>>
>> I tested with the stable 2.6.27.2 and it worked. I will try the Linus git now.
>>
>> Leandro.
>>
>
> Using the Linus git iperf run successfully. Then, does we have
> something broken in Gerrit git three?
>
> Leandro.
>


I meant, (...) "Gerrit git tree"
