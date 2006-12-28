From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 28 Dec 2006 01:16:12 +0000
Subject: Re: [PATCH 4/5]: DCCP Fix t_nom
Message-Id: <5640c7e00612271716h30354dc4wab07c51cd73d02c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612201548.12544.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201548.12544.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Ian McDonald:
> |  I'll look at this when I get a chance (hopefully today).
>
> I will be out in a minute. I have few more things:
>
>  (a) On
>      http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/3c_CCID3_add_more_debugging_McDonald.diff
>      I made minor changes (to make the format consistent)
>
OK. I've changed my patchset to match.

>  (b) On my `experimental' patch set I have uploaded the following:
>
>      http://www.erg.abdn.ac.uk/users/gerrit/dccp/experimental_patches/EXPERIMENTAL_dummy_receiver.diff
>
>      This short-circuits the feedback loop (when working as an electronics engineer,
>      opening or short-circuiting was the first method of testing something when there
>      was a fault). Using this patch, one can test if the sender `behaves', since the
>      receiver practically does not impose inhibitions.
>
Looks useful.

>  (c) Thought again about dccp_wait_for_ccid -- is it certain that when the packet is ready
>      to be sent (ccid_hc_tx_send_packet returns 0), that it indeed will be sent soon?
>      I might ponder this when on holiday B-)
>
We have timers to take care of this but no guarantee timer will fire
when we want it to. I think it is worthwhile looking to move to
hrtimers at some point in time. We would need to be careful not to
generate something for every packet though as timers every 10 usecs
might not be good on a high speed lan....

-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
