From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 12:53:35 +0000
Subject: Re: [PATCH] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <200612011253.36045@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611301318.46685@strip-the-willow>
In-Reply-To: <200611301318.46685@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Mark Handley:
|  I agree that running a very small no-feedback timer is a bad idea.
|  But I think that 1 second is probably far too large. =A0The purpose of
|  the nofeedback timer is to slow DCCP down when there is serious
|  network congestion. =A0Waiting 1 second on a LAN would mean sending for
|  thousands of RTTs before starting to slow down. =A0And on wide-area
|  links in places like the UK, it could be 100 RTTs before you slow
|  down, although this would be mitigated a little if the problem was
|  congestion, and a queue built up.
| =20
|  My gut feeling is that there should be a lower bound on the nofeedback
|  timer, but that 100ms would be a more appropriate value. =A0This is
|  motivated by an attempt to compromise between a large value for
|  efficient DCCP implementations, and a small value to avoid disrupting
|  the network for too long when bad stuff is happening. =A0From a human
|  usability point of view, you probably can cope with dropouts in audio
|  of 100ms without it being too bad, but 1 second is too long.
Thanks a lot for this feedback. I will change the patch once again so that =
the
configuration option scales in units of 100 milliseconds - that will give u=
sers
a chance to test at different granularity:
	* 0 means use RFC 3448 as before
	* 1 means 100 milliseconds
	* 10 corresponds to the TCP timeout of 1 sec
	* ...

Gerrit
