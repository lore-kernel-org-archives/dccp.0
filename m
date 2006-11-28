From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Tue, 28 Nov 2006 21:41:50 +0000
Subject: Re: Packet size s Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <39e6f6c70611281341y7307721cqdb73f306912ca85d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
In-Reply-To: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/28/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> On 11/28/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> > On 11/28/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > > > OK, additionally I'm replacing:
> > > >
> > > > +               DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
> > > > +               err = -EINVAL;
> > > >
> > > > By
> > > >
> > > > +               DCCP_WARN("sockopt(PACKET_SIZE) not yet supported\n");
> > > > +               err = -EINVAL;
> > > >
> > > > To better reflect what we've discussed so far.
> > > >
> > > No deprecate it still. My earlier patches split it into two - a tx and
> > > rx packet size.
> >
> > Oh, I see, OK.
>
> Applied the "deprecated" patch, and on top of that another that makes
> it return 0, not -EINVAL, so that the warning is emitted to the system
> logs but the app continues working, reflecting the comment that says
> it is has no effect.

End result :-)

[root@qemu ~]# ttcp-r: buflen%6, nbuf 48, align384/+0,
portP01  dccp(inet)

[root@qemu ~]#
[root@qemu ~]# [  377.670389] CCID: Registered CCID 2 (ccid2)
ttcp-r: socket
/[  377.891025] do_dccp_setsockopt: sockopt(PACKET_SIZE) is
deprecated: fix your app
[root@qemu ~]# ttcp -cacme -l256 -n1000 -t localhost &
[2] 494
[root@qemu ~]# ttcp-t: buflen%6, nbuf00, align384/+0,
portP01  dccp(inet)  -> localhost
ttcp-t: socket
[  382.235316] do_dccp_setsockopt: sockopt(PACKET_SIZE) is deprecated:
fix your app
ttcp-r: accept from localhost.ghostprotocols.net
ttcp-t: connect
ttcp-t: 256000 bytes in 22.98 real seconds = 10.88 KB/sec +++
ttcp-t: 1000 I/O calls, msec/call = 23.53, calls/sec = 43.51
ttcp-t: 0.2user 17.0sys 0:22real 75% 0i+0d 0maxrss 0+1pf 0+1000csw
ttcp-r: 256000 bytes in 23.31 real seconds = 10.73 KB/sec +++
ttcp-r: 1001 I/O calls, msec/call = 23.84, calls/sec = 42.95
ttcp-r: 0.1user 5.0sys 0:23real 22% 0i+0d 0maxrss 0+1pf 1001+6csw
