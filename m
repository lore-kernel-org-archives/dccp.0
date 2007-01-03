From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 11:58:08 +0000
Subject: Re: [PATCH 1/1]: Fix packet tardiness bug in CCID 3
Message-Id: <200701031158.08831@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612212044.42230@strip-the-willow>
In-Reply-To: <200612212044.42230@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Ian,

I really do appreciate your effort and your input has been helpful, but
do you not agree that such a bug needs to be tackled at the root?
Please see below.

|  > [CCID 3]: Fix packet tardiness BUG
|  >
|  > Problem:
|  > --------
|  > =A0Due to packet scheduling in CCID 3, it can happen that the
|  > =A0actual send time of a packet is later than t_now: in this case
|  > =A0t_nom < t_now.
|  > =A0This case brings the entire packet scheduling out of sync, since
|  > =A0the next packet is scheduled at t_nom + t_ipi, and t_nom is in
|  > =A0the past.
|  >
|  > Fix:
|  > ----
|  > =A0Update t_nom to t_now whenever a packet is late due to scheduling
|  > =A0(and then t_nom < t_now). This update takes place in ccid3_hc_tx_
|  > =A0send_packet. In between calls to this function, it is irrelevant
|  > =A0if t_nom < t_now (since it will be caught eventually).
|  >
|  Agree with the problem statement and your fix helps but I think this
|  fix isn't quite right and mine uses a bit too much CPU resource.

| =20
|  The problem with yours is that it resets t_nom whenever it is late
|  rather than just due to t_ipi changing.=20
Sorry, did you read the earlier emails that I sent? The point is that
t_ipi will never cause t_nom to become negative. Let things be what they
may - one thing is clear: the problem of being too late in scheduling must
be accounted for. This is what the patch does.

There is a second issue which is more subtle: there are several functions
which access t_nom asynchronously: packet_sent, packet_recv, no_feedback ti=
mer.
Due to concurrency this means that we have a race condition if we allow
several functions to access t_nom without enforcing mutual exclusion via
locks: the problem is that one function can read an old t_nom, while t_ipi
has just been subtracted .... and so on. I have prepared another patch to
take care of this.


|  The problem like this is that if the packet is late for other reasons=20
|  then we shouldn't slow down following packets as it hurts performance.=20
Ian, which `other reasons' do you mean?: it is logically impossible to crea=
te
a t_nom < t_now other than being too late in scheduling.

Gerrit
