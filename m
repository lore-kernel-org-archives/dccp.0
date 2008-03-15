From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sat, 15 Mar 2008 15:29:18 +0000
Subject: Re: dccp bugs (Was: Re: panic on 2.6.24rc5)
Message-Id: <200803151629.19242.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Friday 14 of March 2008, Gerrit Renker napisa=B3:
> With regard to the RTT-clamping patch: I have heard no report back from
> Tomasz, but with the revised analysis I am sure that the bug will
> disappear when clamping the RTT to values > 4 microseconds.
Sorry for the delay, I was ill. Both your patches (applied separately) seem=
 to=20
fix the problem in my environment.
--=20
Regards,
Tomasz Grobelny
