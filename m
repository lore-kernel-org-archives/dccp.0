From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Aug 2009 19:06:58 +0000
Subject: Re: DCCP module insertion issues
Message-Id: <20090825190658.GA4888@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <DD7F6BACE0940D4AA451F8762B4D513C025A6E8A@thot.clb.tcfr.thales>
In-Reply-To: <DD7F6BACE0940D4AA451F8762B4D513C025A6E8A@thot.clb.tcfr.thales>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| Our problem is that whatever the available clocksource used (tsc, acpi_pm=
, pit or jiffies)=20
| we always have an error and the following message in the syslog :
|=20
| Timer too coarse (999 usec), need 10-usec resolution - check your clockso=
urce
|=20
It is not necessarily only a kernel configuration problem. There are a numb=
er of boot command options which also
influence the timer. I have found a useful test to do a "cat /proc/timer_li=
st", on my laptop a ".resolution" of
1 nsecs is reported for both clocks on each core; as 'Clock Event Device', =
"hpet" and "lapic" are reported.

In my .conf, I have such things as
CONFIG_HIGH_RES_TIMERS=3Dy
CONFIG_HPET_TIMER=3Dy
(both are available via 'Processor type and features').

A number of people have stumbled over this, but all have been able to get i=
t working with just minor
configuration changes.=20

Eventually it is planned to get rid of the high-resolution timer support al=
together, but it is a big
change, so it may not be in the immediate future. It is not a good idea to =
disable the warning, it
has been put in after experiencing very strange bugs such as negative RTT v=
alues, see
http://archive.netbsd.se/?ml=3Dlinux-netdev&a 08-07&m=8081317
