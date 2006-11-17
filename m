From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 17 Nov 2006 18:26:23 +0000
Subject: Re: [BUG] DCCP performance stops on CCID3 at times
Message-Id: <200611171826.23545@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611161055.31036.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200611161055.31036.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > I think that a warning message could bring in some light: maybe it is =
the case here that the RTT measurement is just
|  > at rock bottom, always returns 0, =A0and thus always stays at 1.
| =20
|  It was just put in there to stop divide by zeros. It wasn't meant to
|  be a proper fix.
I have added warning messages in latest patch.=20

|  >
|  > There is another thread which I think may be of relevance, incidentall=
y again at the rx_packet_recv function:
|  >
|  > =A0 =A0 =A0 =A0 http://www.mail-archive.com/dccp%40vger.kernel.org/msg=
00118.html
|  >
|  This one has already been fixed. If you look at the code it's changed
|  a fair bit since then. This was a bug which crippled my testing and I
|  was glad to get sorted. I also removed some of the cc_val/window stuff
|  at this point as I figured 80% working was better than 0% working as
|  regards to congestion control...
I take your word for it - when looking yesterday, I noted that new function=
s and variable names
were used, but the structure seemed somewhat similar - but I am not so fami=
liar with the CCID 3 code.
Will do some more code reading.

-- Gerrit
