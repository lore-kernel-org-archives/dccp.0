From: "Patrick Andrieux" <patrick.andrieux@gmail.com>
Date: Fri, 01 Jun 2007 17:30:46 +0000
Subject: Re: [dccp] Re: problem with CCID3 loss events
Message-Id: <fca78b970706011030r2d7116a2q1aca5b882fc95f6d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <9442.39900.qm@web30009.mail.mud.yahoo.com>
In-Reply-To: <9442.39900.qm@web30009.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi again,

I find out what was the problem. I recompile the latest 2.6.20 kernel
with Ian's patches, and my iperf client doesn't freeze anymore. So I
guess there is something wrong in Dave Miller's tree (I didn't use
Ian's patches).
dccp_probe module doesn't work either with his tree, it seg fault
trying to insert it.

Patrick.



On 31/05/07, Patrick Andrieux <patrick.andrieux@gmail.com> wrote:
> Hi Burak,
>
> I've got some issues doing tests on the same configuration you have.
> I'm using Dave Miller's tree instead of 2.6.20 patched with Ian's patches.
>
> When I run iperf client (DCCP patched) with :
> # iperf -c serverIP -Xdccp -l8 -t60
> my client machine freezes completely after sending a few data.
> This issue appears only when I limit the rate on the netembox. (1024kbits/sec)
>
> Did you ever have this problem ?
>
> Patrick.
>
>
>
> On 24/05/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > On 5/25/07, Burak Gorkemli <burakgmail-dccp@yahoo.com> wrote:
> > > Hi Ian,
> >
> > Hi Burak,
> >
> > Adding DCCP @ vger as I think you mistakenly added DCCP @ ietf to the mailing...
> >
> > > Last but not the least, I have discovered that I am having some trouble with the sizes of the packets sent. When the packet sizes are equal to each other - which is not the actual case in my tests - everything goes fine. However, when they are not, DCCP behaves strangely, it halts for some period of time during the stream - I think due to the mismatch between the sizes of the packets sent and the average packet size used in the TCP equation. I must confess that I am not aggregating smaller packets into larger ones - which is the next thing that I will do - but I was not expecting such a big effect. I will post the test results later, as I implement packet aggregation.
> >
> > CCID3 in Linux keeps a moving average of the packet size. If you look
> > at the TFRC equation  the rate = some numbers / packet size. In effect
> > CCID3 therefore becomes rate limited by packets per second as it does
> > not perform packet aggregation within the protocol (unlike TCP). This
> > would explain your results in this regard.
> >
> > Ian
> > --
> > Web: http://wand.net.nz/~iam4/
> > Blog: http://iansblog.jandi.co.nz
> > WAND Network Research Group
> >
> >
>


-- 
-------
Patrick ANDRIEUX
email : patrick.andrieux@gmail.com
