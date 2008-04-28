From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 28 Apr 2008 20:12:02 +0000
Subject: Re: [DCCP] [RFC] [Patchv3 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804282212.03453.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080416083629.GB23157@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080416083629.GB23157@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 28 of April 2008, Gerrit Renker napisa=B3:
> Here is a tidied-up version, the patch sent last week and stored in
>
> 	git://eden-feed.erg.abdn.ac.uk/dccp_exp (tree `qpolicy')
>
> was not very good, the updates are:
>
>  * the skb->priority is now cleared when leaving the DCCP layer;
Ok. I only wonder if this kind of cleanup shouldn't happen in qpolicy speci=
fic=20
function. Such as already non-existant qpolicy_prio_pop(). Note that=20
qpolicy_simple_pop() would not need to clear skb->priority. This kind of=20
function could act as skb deinitializer. And I think qpolicy_*_pop() should=
=20
be added again...

The same question applies to skb initialization. In my opinion it should=20
happen in qpolicy_*_push(). So that dccp_msghdr_parse code should be moved =

there.

This approach would clearly abstract qpolicy subsystem from the rest of dcc=
p=20
code. We would have packet initialization in qpolicy_*_push() and=20
deinitialization in qpolicy_*_pop().

I'll try to write a patch that demonstrates it.

>  * there is now documentation/hints about the use of skb->priority in DCC=
P;
There is something I don't understand in your approach regarding=20
skb->priority. I think I could understand it better it you could sketch how=
=20
in your opinion should an interface look like if packet timeout was to be=20
added.
Would you:
a) pack this data into this u32 identified by DCCP_SCM_PRIORITY. This is wh=
at=20
I thought you meant (but I may be wrong). And something I don't really like.
b) add another parameter type eg. DCCP_SCM_TIMEOUT_MS and use another u32 t=
o=20
pass this parameter. This is something I like much better,
c) something else. Then what is that?

>  * there is one question I have, and that can be reverted:
>    - qpolicy_prio_push() has been replaced by a combination of
>    - qpolicy_prio_full() [which now does the drop-on-queue-full] and
>      qpolicy_simple_push() [which does the FIFO-queueing]
>    This means fewer routines, but if you don't like it, I am ok to revert
> it.
>
I don't care that much about internal implementation. But I don't really li=
ke=20
mixing policies. Especially since when prio policy will have more features =

these functions will have to be separated again. When making any choices I =

always try to think how it will look like when more features are added=20
(especially packet timeouts and getting statistics).
--=20
Regards,
Tomasz Grobelny
