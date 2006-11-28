From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Nov 2006 22:09:02 +0000
Subject: Re: Packet size s Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <5640c7e00611281409v3af8e0e9g205fcb6ee939cd30@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
In-Reply-To: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/29/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> On 11/28/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > > ttcp-r: accept from localhost.ghostprotocols.net
> > > ttcp-t: connect
> > > ttcp-t: 256000 bytes in 22.98 real seconds = 10.88 KB/sec +++
> > > ttcp-t: 1000 I/O calls, msec/call = 23.53, calls/sec = 43.51
> > > ttcp-t: 0.2user 17.0sys 0:22real 75% 0i+0d 0maxrss 0+1pf 0+1000csw
> > > ttcp-r: 256000 bytes in 23.31 real seconds = 10.73 KB/sec +++
> > > ttcp-r: 1001 I/O calls, msec/call = 23.84, calls/sec = 42.95
> > > ttcp-r: 0.1user 5.0sys 0:23real 22% 0i+0d 0maxrss 0+1pf 1001+6csw
> > >
> > Umm.... that performance sucks - were you doing that with netem in
> > middle or something?
>
>
> Nah, this is qemu, my machine was loaded, etc, its just for basic,
> basic testing :-)
>
OK. Still not good. Will test tomorrow and see...

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
