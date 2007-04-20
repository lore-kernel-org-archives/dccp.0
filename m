From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 20 Apr 2007 09:45:02 +0000
Subject: Re: [dccp] Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <200704201045.03137@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Ian, I would appreciate if in future you would not copy patch
descriptions over from dccp@vger to dccp@ietf.=20

Apart from the fact that I don't like it, this creates the wrong idea among=
=20
people who have little or nothing to do with actual protocol implementation=
=20
- it produces an impression of "let's talk about some implementation bugs".=
=20
(But competent implementation feedback is welcome and solicited on dccp@vge=
r)

Which is the more regrettable since you are right in raising this point
as a general one: it is indeed a limitation of [RFC 3448, 4.6] with regard
to non-realtime OSes. To clarify, the two main issues of this limitation
are summarised below.


I. Uncontrollable speeds
------------------------
Non-realtime OSes schedule processes in discrete timeslices with a granular=
ity
of t_gran =3D 1/HZ. When packets are scheduled using this mechanism, this
naturally limits the maximum packets per second to HZ. =20

There are two speeds involved here: the packet rate `A' of the application
(user-space), and the allowed sending rate `X' determined by the TFRC mecha=
nism
(kernel-space).=20

These speeds are not related to one another. The allowed sending rate X wil=
l, under
normal circumstances, approach the link bandwidth; following the principles=
 of slow
 start. The application sending rate A is fixed or is not.

No major problems arise when it is ensured that A is always below X. Numeri=
cal
example: A2kbps, X=94Mbps (standard 100 Mb Ethernet link speed). When loss =

occurs, X is reduced according to p. As long as X remains above A, the send=
er
can send as before; if X is reduced below A, the sender will be limited.

Now the problem: when the application rate A is above s * HZ, there is a ra=
nge
of speed where the TFRC mechanism is effectively out of control, i.e. reque=
sts
to reduce the sending rate in response to ECN-marked packets or congestion =
events
(ECN-marked or lost packets) will not be followed.

Numerical example: HZ=1000/sec, X=94Mbps, AYMbps, s=1500 bytes. The control=
lable
limit is s * HZ =3D 1500 * 8 * 1000 bps =3D 12Mbps. Assume loss occurs in s=
teady-state
such that X is to be reduced to X_reduced. Then, if=20
                      s * HZ  <  X_reduced <=3D  A,
nothing will happen and the effective speed after computing X_reduced will =
remain at A.=20
This is even more problematic if A is not fixed but could increase above it=
s current rate
So, with regard to the numerical example, nothing will happen if X_reduced =
is between=20
12Mpbs ... 59Mbps, the speed after the congestion occurs will remain at AYM=
bps.

The problem is even more serious when considering that Gigabit NICs are sta=
ndard
in most laptops and desktop PCs, here X will ramp up even higher so that th=
e range
for mayhem is even greater. (Standard Linux even comes with 10 Gbit etherne=
t drivers).

Again: the problem is that TFRC/CCID3 can not control speeds above s * HZ o=
n a non-realtime
operating system. In car manufacturer terms, this is like a car whose accel=
erator is
functional, but switches to top speed, somewhere in its range. Obviously, t=
hey would not
be allowed to sell cars with such a deficiency.=20

A safer solution, therefore, would be to insert a throttle into to limit ap=
plication speeds=20
below s * HZ; to keep applications from stealing bandwidth which they are n=
ot supposed to use.


II. Accumulation of send credits
--------------------------------
This second problem is also conceptual and is described as accumulation of =
send credits.
It has been discussed on this list before, please refer to those threads fo=
r a more
detailed description of how this comes about. The relevant point here is th=
at accumulation
of send credits will also happen  as a natural consequence of using [RFC 34=
48, 4.6] on=20
non-realtime operating systems.=20

The reason is that the use of discrete time slices leads to a quantisation =
problem, where
t_nom is always set earlier than would be required by the exact formula: 0.=
9 msec becomes
0 msec, 1.7 msec becomes 1 msec, 2.8 msec becomes 2 msec and so forth (this=
 assumes HZ=1000,
it is even worse with lower values of HZ).=20

Thus, after a few packets, the sender will be "too early" by the sum total =
of quantisation=20
errors that have so far occurred. In the given numerical example, the sende=
r is skewed by=20
(0.9 + 0.7 + 0.8) msec =3D 2.4 msec, which will be broken into a send credi=
t of 2 msec plus a=20
remainder of 0.4 msec; which might clear at a later stage.=20

In addition, this will lead to speeds which are typically faster than allow=
ed by the exact
value of t_nom: measurements have shown that in the ``linear'' range of spe=
eds below s * HZ,
the real implementation is more than 3 times faster than allowed by the sen=
ding rate X =3D s/t_ipi.


III. Accumulation of inaccuracies
---------------------------------
Due to context switch latencies, interrupt handling, and processing overhea=
d, a scheduling-based
packet pacing will not schedule packets at the exact time, they may be sent=
 slightly earlier or
later. This is another source where send credits can accumulate, but it is =
not fully understood
yet. It would require measurements to see how far off on average the schedu=
ling is. It does seem
however that this problem is less serious than I/II; scheduling inaccuracie=
s might cancel each other
out over the long term.


NOTE: numerical examples serve to illustrate the principle only. Please do =
not interpret this as an=20
      invitation for discussion of numerical examples.

Thanks.

 =20
|  On 4/18/07, Lars Eggert <lars.eggert@nokia.com> wrote:
|  > On 2007-4-18, at 19:16, ext Colin Perkins wrote:
|  > > On 11 Apr 2007, at 23:45, Ian McDonald wrote:
|  > >> On 4/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > >>> There is no way to stop a Linux CCID3 sender from ramping X up to
|  > >>> the link bandwidth of 1 Gbit/sec; but the scheduler can only
|  > >>> control packet pacing up to a rate of s * HZ bytes per second.
|  > >>
|  > >> Let's start to think laterally about this. Many of the problems
|  > >> around
|  > >> CCID3/TFRC implementation seem to be on local LANs and rtt is less
|  > >> than t_gran. We get really badly affected by how we do x_recv etc a=
nd
|  > >> the rate is basically all over the show. We get affected by send
|  > >> credits and numerous other problems.
|  > >
|  > > As a data point, we've seen similar stability issues with our user-
|  > > space TFRC implementation, although at somewhat larger RTTs (order
|  > > of a few milliseconds or less). We're still checking whether these
|  > > are bugs in our code, or issues with TFRC, but this may be a
|  > > broader issue than problems with the Linux DCCP implementation.
|  >
|  > I think Vlad saw similar issues with the KAME code when running over
|  > a local area network. (Vlad?)
|  >
|  > Lars
|  >
|  >
|  >
|  >
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
| =20
| =20
