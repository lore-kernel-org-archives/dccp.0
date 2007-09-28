From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 28 Sep 2007 15:40:04 +0000
Subject: Re: DCCP support in VLC
Message-Id: <200709281640.04322@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709271930.03854.rdenis@simphalempin.com>
In-Reply-To: <200709271930.03854.rdenis@simphalempin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Other than that, and apart from pending DCCP service code support I am happy 
|  to announce that the official VLC development tree now support DCCP 
|  out-of-the-box with RTP.
|
Great! That means that the old hack (which you commented on earlier) on
    http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/#VLC_Patch 
can go in favour of something properly integrated with the VLC code. Many thanks
for looking after this.

I am assuming that this relies on the non-blocking connect you described? If yes,
I shall make sure that the patch to do this is tidied up and submit it early next
week - this needs some more thought.

Excellent news!

|  Manually, on the sender (assuming sender IP is 2001:db8::1):
|  $ vlc -vv /dev/dvd \
|  --sout '#rtp{dccp,mux=ts,portP04}'
|  
|  On the receiver:
|  $ vlc -vv dccp://[2001:db8::1]:5004
|  
|  Or advertized with SAP, on the sender:
|  $ vlc -vv /dev/dvd \
|  --sout '#rtp{dccp,mux=ts,portP04,dst 01:db8::1,sdp=sap,name=MyDVD}'
|  
|  On the receiver, enable SAP service discovery and click MyDVD from the 
|  playlist.
|  
|  
|  We cannot support multiple streams per session, because the live555 library 
|  does not support DCCP at this time. But TS multiplexing works great anyway.
