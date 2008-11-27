From: gerrit@erg.abdn.ac.uk
Date: Thu, 27 Nov 2008 12:02:05 +0000
Subject: Re: System lookup and DCCP plugin for GStreamer
Message-Id: <43757.148.187.160.35.1227787325.squirrel@148.187.160.35>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570811241100ra4f4e79n4e056e9bea76b826@mail.gmail.com>
In-Reply-To: <5bc4c4570811241100ra4f4e79n4e056e9bea76b826@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org


> I have a problem with this example:
> gst-launch -v filesrc location=3Dmusic.mp3 ! mp3parse ! dccpclientsink
> host=3Dlocalhost port=9011 ccid=3D2
>
> gst-launch -v dccpserversrc port=9011 ccid=3D2 ! decodebin ! alsasink
>
Does the same problem happen if the client and server are not on
the same host?
And then where does the load come from -- any chance of using 'strace -p'
to see where it is cycling? Maybe it is an event loop which gets overflooded
since on localhost with a RTT < 10 microseconds the responses come
unexpectedly fast.

If this is the case, it is one more reason to migrate to lower timer
resolution.

Gerrit

