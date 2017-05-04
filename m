From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 04 May 2017 13:54:26 +0000
Subject: Re: net/dccp: dccp_create_openreq_child freed held lock
Message-Id: <CAAeHK+xYWdiy5gktuwk56_7BHYCRNNa5c6vY94gA0i0M+P8T+Q@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CACT4Y+ZOAWRzJH3=xJ1z5bFVCM2-smuVSykziQPhSgkv1k3FBQ@mail.gmail.com>
In-Reply-To: <CACT4Y+ZOAWRzJH3=xJ1z5bFVCM2-smuVSykziQPhSgkv1k3FBQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, May 4, 2017 at 3:53 PM, David Miller <davem@davemloft.net> wrote:
> From: Andrey Konovalov <andreyknvl@google.com>
> Date: Thu, 4 May 2017 15:36:37 +0200
>
>> On Wed, Mar 1, 2017 at 4:40 PM, Arnaldo Carvalho de Melo
>> <acme@kernel.org> wrote:
>>> Em Wed, Mar 01, 2017 at 12:35:10PM -0300, Arnaldo Carvalho de Melo escreveu:
>>>> Em Wed, Mar 01, 2017 at 10:38:54AM +0100, Dmitry Vyukov escreveu:
>>>> > Hello,
>>>> >
>>>> > I've got the following report while running syzkaller fuzzer on
>>>> > 86292b33d4b79ee03e2f43ea0381ef85f077c760:
>>>> >
>>>> >
>>>> > It seems that dccp_create_openreq_child needs to unlock the sock if
>>>> > dccp_feat_activate_values fails.
>>>>
>>>> Yeah, can you please use the patch below, that mimics the error paths in
>>>> sk_clone_new(), from where I think even the comment about it being a raw
>>>
>>> Argh, s/sk_clone_new()/sk_clone_lock()/g
>>
>> Hi Arnaldo,
>>
>> Could you send the patch?
>>
>> We haven't seen these reports since we applied it.
>
> It isn't necessary in the current tree.
>
> Arnaldo created a helper sk_free_unlock_clone() which handles this situation
> properly, and calls it from dccp_create_openreq_child().

OK, great, thanks!
