From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 26 Sep 2007 09:46:58 +0000
Subject: Re: [PATCH 7/8]: Handle timestamps on Request/Response exchange separately
Message-Id: <200709261046.58887@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.48514@strip-the-willow>
In-Reply-To: <200709251530.48514@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  > This patch addresses the following situation:
|  > =A0=A0=A0=A0=A0=A0* timestamps are recorded on the listening socket;
| =20
|  I noticed this, I think it is unaceptable to do that, therefore the best
|  thing is to combine the two patches, so as not to introduce a problem
|  that is fixed in the following patch.
OK, so we have at least agreement that something needs to be done. Sorry I =
don't understand the=20
above remark: do you refer to the hunk which fixed a pointer assignment (ts=
e =3D ...) and slipped=20
into the wrong patch?

I am happy to combine the two patches if that is what you are asking. I had=
 kept the next patch
("Support inserting options during the 3-way handshake") separate since it =
is mainly concerned
with inserting options, which is called by feature-negotiation (see below f=
or related issue).

 =20
|  > This patch therefore
|  > =A0=A0=A0=A0=A0=A0* makes memory use for timestamps dynamic (to use le=
ss when no timestamps are present);
|  > =A0=A0=A0=A0=A0=A0* separates `handshake timestamps' from `established=
 timestamps';
| =20
|  I didn't understood this one. Care to further explain?=20
Yes - awkward sentence. What I meant (and that becomes only obvious further=
 down in the patch set) is:

 1) First point: if no timestamp is present then there is no memory (apart =
from a pointer) associated=20
    with this. I was concerned that otherwise the request_socks get too big=
 - which is exactly your=20
    comment from below. This is not the end of the story - there is also a =
list_head on request_socks
    to store the feature-negotiation list. Here I had the same concerns: in=
itially I wanted to use a=20
    table for all features, and that would have been a fat use of memory (9=
 features x 2 locations=20
    (local/remote) x 64bit (maximum option size) gives 1152 bytes - which I=
 found utterly inacceptable
    to put on a request_sock. Instead, the feature negotiation uses a list =
which is allocated at most
    once (even when the Request is retransmitted, it is not allocated again=
).
    And for the timestamps I thought it would be good practice to do the sa=
me - if no timestamps are
    present during the handshake, don't allocate memory for them.

 2) Separating `handshake timestamps' from `established timestamps': I don'=
t know where my mind was,
    this just means that timestamps can appear during the handshake (which =
needs special considerations
    on the server) and when the connection is fully established (then it us=
es the sk fields like before).


|  Anyway, I think that adding yet another allocation in a connection lifet=
ime is not good.
Please see below - I can see your point, but other issues are involved also.


|  One of the most pressing things for me after merging all the patches
|  that are pending (THANK YOU! :-) ) is to work on DCCP memory consuption
|  and accounting, the code has to be made more robust :-\
The coming feature negotiation patch set removes lots of kmallocing and kme=
mduping which is frequent in
the current feature negotiation code. I don't know if that is what you mean=
, but I also observed problems
with the cache when I did the tests.

 =20
|  I think that we should just add dreq_{time,echo} to dccp_request_sock
|  and keep dccp_sock as is.
| =20
<snip>
< ...
|  Humm, these minisocks are getting fat... another thing for my TODO list,
That is my concern, too. So what shall we do: add two fields which may not =
be used most of the
time (at the moment only to support an erratum to CCID3), or keep the memor=
y allocation.=20


|  request_sock::ts_recent seems to be used only by the TCP machinery, ripe
|  for the picking....
Is there any use of ts_recent for CCID2 - in an earlier email you pointed o=
ut that CCID2
could do timestamping, and that would be a place to use.

| =20
|  Anyway, I'll move along the patch queue looking for more easily
|  cherrypickable patches.
Please don't at the moment consider the feature negotiation patches for che=
rry picking -
there are more to come; I split them into batches to make reviewing easier =
(and your input
is appreciated).
